import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emailController;

  // --- THÔNG TIN MOMO CẬP NHẬT TỪ HÌNH ẢNH CỦA BẠN ---
  final String partnerCode = "MOMO"; 
  final String accessKey = "F8BBA842ECF85"; 
  final String secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz"; 
  final String requestType = "captureMoMoWallet";
  final String momoApiUrl = "https://test-payment.momo.vn/gw_payment/transactionProcessor";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    addressController = TextEditingController(text: widget.address);
    emailController = TextEditingController(text: "customer@example.com");
    _loadSavedUserInfo();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      if (prefs.containsKey('user_name')) nameController.text = prefs.getString('user_name')!;
      if (prefs.containsKey('user_phone')) phoneController.text = prefs.getString('user_phone')!;
      if (prefs.containsKey('user_address')) addressController.text = prefs.getString('user_address')!;
      if (prefs.containsKey('user_email')) emailController.text = prefs.getString('user_email')!;
    });
  }

  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nameController.text);
    await prefs.setString('user_phone', phoneController.text);
    await prefs.setString('user_address', addressController.text);
    await prefs.setString('user_email', emailController.text);
  }

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

  void _processOrderAndSaveHistory() {
    if (!mounted) return;
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
    final String orderId = "LM_${DateTime.now().millisecondsSinceEpoch}";
    final String requestId = orderId;
    final String orderInfo = "LocalMart Payment";
    final String returnUrl = "https://momo.vn";
    final String notifyUrl = "https://momo.vn";
    final String extraData = ""; 

    String rawSignature = "partnerCode=$partnerCode&accessKey=$accessKey&requestId=$requestId&amount=$amount&orderId=$orderId&orderInfo=$orderInfo&returnUrl=$returnUrl&notifyUrl=$notifyUrl&extraData=$extraData";

  double _parseVoucher(String? voucher) {
    if (voucher == null || voucher.isEmpty) return 0.0;
    try {
      return double.parse(voucher.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  /// GỌI API MOMO GATEWAY VỚI CẤU HÌNH MỚI TỪ HÌNH ẢNH
  Future<void> _processMoMoPayment() async {
    final double voucherDiscount = _parseVoucher(widget.voucherCode);
    final int finalPrice = (widget.totalPrice - voucherDiscount).toInt();
    
    final String amount = finalPrice.toString();
    final String orderId = "LM_" + DateTime.now().millisecondsSinceEpoch.toString();
    final String requestId = orderId;
    final String orderInfo = "LocalMart Payment";
    final String returnUrl = "https://momo.vn"; 
    final String notifyUrl = "https://momo.vn"; 
    final String extraData = ""; 

    // TẠO CHỮ KÝ CHUẨN XÁC THEO THỨ TỰ THAM SỐ MOMO V2
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
      if (Navigator.canPop(context)) Navigator.pop(context); 

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['errorCode'] == 0) {
        final String? payUrl = data['payUrl'];
        if (payUrl != null) {
          await launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication);
          _showMoMoConfirmation();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi MoMo: ${data['localMessage']}"), backgroundColor: Colors.red));
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
            child: const Text("ĐÃ XÁC NHẬN")),
        ],
      ),
    );
          _showConfirmationDialog("MoMo Sandbox");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${data['localMessage'] ?? data['message']} (Code: ${data['errorCode']})"), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
    }
  }

  void _navigateToInvoice() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceScreen(
      items: widget.items, 
      totalPrice: widget.totalPrice, 
      name: nameController.text, 
      phone: phoneController.text, 
      address: addressController.text, 
      paymentMethod: selectedMethod, 
      voucherCode: widget.voucherCode, 
      shipperNote: widget.shipperNote,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final double finalPrice = _calculateFinalPrice();
    final double voucherDiscount = _parseVoucher(widget.voucherCode);
    final double finalPrice = widget.totalPrice - voucherDiscount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("PHƯƠNG THỨC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 18)), centerTitle: true, backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Thông tin giao hàng (Nhấn để sửa)"),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05), 
                  borderRadius: BorderRadius.circular(15), 
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.1))
                ),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.withOpacity(0.1))),
                child: Column(
                  children: [
                    _buildEditField(nameController, Icons.person_outline, "Họ và tên"),
                    const SizedBox(height: 10),
                    _buildEditField(phoneController, Icons.phone_outlined, "Số điện thoại", keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    _buildEditField(emailController, Icons.email_outlined, "Địa chỉ Email", keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    _buildEditField(addressController, Icons.location_on_outlined, "Địa chỉ nhận hàng"),
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
                    margin: const EdgeInsets.only(bottom: 8), 
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
                    child: ListTile(
                      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(imageUrl: item.imageUrl, width: 45, height: 45)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: Text("x${item.quantity}"),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty || emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đủ thông tin giao hàng"), backgroundColor: Colors.red));
                      return;
                    }
                    await _saveUserInfo(); 
                    if (selectedMethod == "momo") {
                      _processMoMoPayment(); 
                    } else if (selectedMethod == "bank") {
                      _showQRCodeDialog("bank");
                    } else {
                      _processOrderAndSaveHistory(); 
                    }
                  },
                  child: const Text("XÁC NHẬN THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _processPaymentSuccess();
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

  Widget _buildEditField(TextEditingController controller, IconData icon, String label, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: Colors.orange),
        labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange.withValues(alpha: 0.2))),
        suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 16, color: Colors.grey), onPressed: () => controller.clear()),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange.withOpacity(0.2))),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _buildPaymentOption({required String title, required String value, required IconData icon}) {
    final bool isSelected = selectedMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isSelected ? Colors.orange.withValues(alpha: 0.05) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.orange : Colors.grey.withValues(alpha: 0.1))),
      child: RadioListTile<String>(
        secondary: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.orange : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        value: value, activeColor: Colors.orange, groupValue: selectedMethod, onChanged: (newValue) => setState(() => selectedMethod = newValue!),
      decoration: BoxDecoration(color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.orange : Colors.grey.withOpacity(0.1))),
      child: RadioListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        secondary: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        title: Text(title, softWrap: true, style: TextStyle(color: isSelected ? Colors.orange : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        value: value, activeColor: Colors.orange, groupValue: selectedMethod, onChanged: (newValue) => setState(() => selectedMethod = newValue!),
      ),
    );
  }

  void _showQRCodeDialog(String type) {
    final double voucherDiscount = _parseVoucher(widget.voucherCode);
    final double finalPrice = widget.totalPrice - voucherDiscount;
    String qrPath = 'lib/features/checkout/assets/images/Screenshot 2026-03-07 133324.png';
    showDialog(
      context: context, barrierDismissible: false, 
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(type == "bank" ? "Quét mã QR Ngân hàng" : "Thanh toán MoMo", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), 
                child: type == "bank" 
                  ? Image.asset(qrPath, width: 250, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.qr_code_scanner, size: 100))
                  : Column(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 100, color: Colors.pink[400]),
                        const Text("Ví MoMo", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 15),
            Text("Số tiền: ${_formatCurrency(finalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () { Navigator.pop(context); _processPaymentSuccess(); }, child: const Text("XÁC NHẬN ĐÃ CHUYỂN", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showConfirmationDialog(String method) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận thanh toán"),
        content: Text("Bạn đã hoàn tất chuyển tiền trên ứng dụng $method chưa?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CHƯA")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () { Navigator.pop(context); _processPaymentSuccess(); }, 
            child: const Text("ĐÃ CHUYỂN", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _processPaymentSuccess() {
    showDialog(context: context, builder: (context) => Center(child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle, color: Colors.green, size: 60), const SizedBox(height: 10), const Text("Thanh toán thành công!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))])))));
    Future.delayed(const Duration(milliseconds: 1500), () { 
      Navigator.pop(context); 
      Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceScreen(
        items: widget.items, totalPrice: widget.totalPrice, name: nameController.text, phone: phoneController.text, address: addressController.text, paymentMethod: selectedMethod, voucherCode: widget.voucherCode, shipperNote: widget.shipperNote,
      ))); 
    });
  }
}
