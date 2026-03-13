import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // HÀM TÍNH TOÁN GIÁ SAU KHI GIẢM VOUCHER
  double _calculateFinalPrice() {
    if (widget.voucherCode == null || widget.voucherCode!.isEmpty) return widget.totalPrice;
    try {
      // Lấy số từ chuỗi voucher (VD: "200.000" -> 200000)
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
        title: const Text("Quét mã QR để thanh toán", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Vui lòng quét mã QR dưới đây để thực hiện chuyển khoản.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            const Icon(Icons.qr_code_2, size: 150, color: Colors.black),
            const SizedBox(height: 15),
            Text("Số tiền: ${_formatCurrency(finalPrice)} VND",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _processOrderAndNavigate();
            },
            child: const Text("XÁC NHẬN ĐÃ CHUYỂN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processOrderAndNavigate() {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user?.username ?? "admin";
    final double finalPrice = _calculateFinalPrice();
    
    // TRUYỀN GIÁ ĐÃ KHẤU TRỪ VÀO BLOC ĐỂ LƯU LỊCH SỬ CHÍNH XÁC
    context.read<CartBloc>().add(PlaceOrderEvent(
      userId, 
      voucherCode: widget.voucherCode, 
      shipperNote: widget.shipperNote,
      finalPrice: finalPrice, // GIÁ ĐÃ GIẢM
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
      Navigator.pop(context);
      _navigateToInvoice();
    });
  }

  void _navigateToInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceScreen(
          items: widget.items,
          totalPrice: widget.totalPrice,
          name: widget.name,
          phone: widget.phone,
          address: widget.address,
          paymentMethod: selectedMethod,
          voucherCode: widget.voucherCode,
          shipperNote: widget.shipperNote,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double finalPrice = _calculateFinalPrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PHƯƠNG THỨC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 18)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black),
      ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.person_outline, widget.name),
                    const SizedBox(height: 8),
                    _infoRow(Icons.phone_outlined, widget.phone),
                    const SizedBox(height: 8),
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
                  return ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(imageUrl: item.imageUrl, width: 40, height: 40)),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: Text("x${item.quantity}"),
                  );
                },
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("Chọn phương thức"),
              _buildPaymentOption(title: "Thanh toán khi nhận hàng (COD)", value: "cash", icon: Icons.money),
              _buildPaymentOption(title: "Thanh toán qua thẻ", value: "card", icon: Icons.credit_card),
              _buildPaymentOption(title: "Chuyển khoản ngân hàng", value: "bank", icon: Icons.account_balance),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (selectedMethod == "bank") {
                      _showQRCodeDialog();
                    } else {
                      _processOrderAndNavigate();
                    }
                  },
                  child: const Text("XÁC NHẬN THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 18, color: Colors.orange), const SizedBox(width: 8), Text(text)]);
  }

  Widget _buildPaymentOption({required String title, required String value, required IconData icon}) {
    final bool isSelected = selectedMethod == value;
    return RadioListTile(
      secondary: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
      title: Text(title),
      value: value, groupValue: selectedMethod, activeColor: Colors.orange,
      onChanged: (newValue) => setState(() => selectedMethod = newValue!),
    );
  }
}
