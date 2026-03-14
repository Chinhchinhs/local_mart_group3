import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_mart/features/auth/presentation/bloc/auth_bloc.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../product/presentation/widgets/product_image.dart';
import 'invoice_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItemEntity> items;
  final double totalPrice;
  final String name;
  final String phone;
  final String address;
  final String? voucherCode;
  final String? shipperNote;

  const PaymentScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    required this.name,
    required this.phone,
    required this.address,
    this.voucherCode,
    this.shipperNote,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "cash";

  // --- THÔNG TIN MOMO CẬP NHẬT ---
  final String partnerCode = "MOMO"; 
  final String accessKey = "F8BBA842ECF85"; 
  final String secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz"; 
  final String requestType = "captureMoMoWallet";
  final String momoApiUrl = "https://test-payment.momo.vn/gw_payment/transactionProcessor";

  // SỬA LẠI BASEURL CHUẨN
  final String baseUrl = "https://dacolleta-moveably-sima.ngrok-free.dev"; 

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  double _calculateFinalPrice() {
    if (widget.voucherCode == null || widget.voucherCode!.isEmpty) return widget.totalPrice;
    try {
      double discount = double.parse(widget.voucherCode!.replaceAll(RegExp(r'[^0-9]'), ''));
      double finalPrice = widget.totalPrice - discount;
      return finalPrice < 0 ? 0 : finalPrice;
    } catch (e) {
      return widget.totalPrice;
    }
  }

  void _processOrderAndSaveHistory() {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user?.username ?? "admin";
    final double finalPrice = _calculateFinalPrice();
    
    context.read<CartBloc>().add(PlaceOrderEvent(
      userId, 
      voucherCode: widget.voucherCode, 
      shipperNote: widget.shipperNote,
      finalPrice: finalPrice,
    ));

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 10),
                Text("Thanh toán thành công!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.pop(context); 
      _navigateToInvoice();
    });
  }

  Future<void> _processMoMoPayment() async {
    final double finalPrice = _calculateFinalPrice();
    final String amount = finalPrice.toInt().toString();
    final String orderId = "LM_" + DateTime.now().millisecondsSinceEpoch.toString();
    final String requestId = orderId;
    final String orderInfo = "LocalMart Payment";
    
    final String returnUrl = "$baseUrl/Checkout/PaymentCallBack"; 
    final String notifyUrl = "$baseUrl/Checkout/MomoNotify"; 
    final String extraData = ""; 

    String rawSignature = "partnerCode=$partnerCode&accessKey=$accessKey&requestId=$requestId&amount=$amount&orderId=$orderId&orderInfo=$orderInfo&returnUrl=$returnUrl&notifyUrl=$notifyUrl&extraData=$extraData";

    var key = utf8.encode(secretKey);
    var bytes = utf8.encode(rawSignature);
    var hmacSha256 = Hmac(sha256, key);
    var signature = hmacSha256.convert(bytes).toString();

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.orange)));

    try {
      final response = await http.post(
        Uri.parse(momoApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "partnerCode": partnerCode,
          "accessKey": accessKey,
          "requestId": requestId,
          "amount": amount,
          "orderId": orderId,
          "orderInfo": orderInfo,
          "returnUrl": returnUrl,
          "notifyUrl": notifyUrl,
          "extraData": extraData,
          "requestType": requestType,
          "signature": signature,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      Navigator.pop(context); 

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['errorCode'] == 0) {
        final String? payUrl = data['payUrl'];
        if (payUrl != null) {
          await launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication);
          _showMoMoConfirmation();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${data['localMessage'] ?? data['message']} (Code: ${data['errorCode']})"), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 15),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: "ĐÓNG", textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
    }
  }

  void _showMoMoConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận MoMo"),
        content: const Text("Bạn đã hoàn tất thanh toán trên ứng dụng MoMo chưa?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CHƯA")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () { 
              Navigator.pop(context); 
              _processOrderAndSaveHistory(); 
            }, 
            child: const Text("ĐÃ XÁC NHẬN", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showQRCodeDialog() {
    final double finalPrice = _calculateFinalPrice();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Quét mã QR Ngân hàng", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('lib/features/checkout/assets/images/Screenshot 2026-03-07 133324.png', width: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_scanner, size: 100)),
              ),
            ),
            const SizedBox(height: 15),
            Text("Số tiền: ${_formatCurrency(finalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              _processOrderAndSaveHistory();
            },
            child: const Text("XÁC NHẬN ĐÃ CHUYỂN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToInvoice() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceScreen(
      items: widget.items, 
      totalPrice: widget.totalPrice, 
      name: widget.name, 
      phone: widget.phone, 
      address: widget.address, 
      paymentMethod: selectedMethod, 
      voucherCode: widget.voucherCode, 
      shipperNote: widget.shipperNote,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final double finalPrice = _calculateFinalPrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("PHƯƠNG THỨC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 18)), centerTitle: true, backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Thông tin giao hàng"),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.withOpacity(0.1))),
                child: Column(
                  children: [
                    _infoRow(Icons.person_outline, widget.name),
                    const SizedBox(height: 10),
                    _infoRow(Icons.phone_outlined, widget.phone),
                    const SizedBox(height: 10),
                    _infoRow(Icons.location_on_outlined, widget.address),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng thanh toán:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${_formatCurrency(finalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("Sản phẩm đã chọn"),
              ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(imageUrl: item.imageUrl, width: 50, height: 50)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Text("${_formatCurrency(item.totalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("Chọn phương thức"),
              _buildPaymentOption(title: "Thanh toán khi nhận hàng (COD)", value: "cash", icon: Icons.money),
              _buildPaymentOption(title: "Thanh toán qua thẻ", value: "card", icon: Icons.credit_card),
              _buildPaymentOption(title: "Chuyển khoản ngân hàng", value: "bank", icon: Icons.account_balance),
              _buildPaymentOption(title: "Ví điện tử MoMo", value: "momo", icon: Icons.account_balance_wallet),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (selectedMethod == "momo") {
                      _processMoMoPayment(); 
                    } else if (selectedMethod == "bank") {
                      _showQRCodeDialog();
                    } else {
                      _processOrderAndSaveHistory();
                    }
                  },
                  child: const Text("XÁC NHẬN THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildPaymentOption({required String title, required String value, required IconData icon}) {
    final bool isSelected = selectedMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.orange : Colors.grey.withOpacity(0.1))),
      child: RadioListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        secondary: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        title: Text(title, softWrap: true, style: TextStyle(color: isSelected ? Colors.orange : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        value: value, activeColor: Colors.orange, groupValue: selectedMethod, onChanged: (newValue) => setState(() => selectedMethod = newValue!),
      ),
    );
  }
}
