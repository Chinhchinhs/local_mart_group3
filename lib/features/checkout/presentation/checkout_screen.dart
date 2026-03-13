import 'package:flutter/material.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../product/presentation/widgets/product_image.dart';
import 'payment_screen.dart';

/// Màn hình Xác nhận đơn hàng: 
/// Hiển thị thông tin người mua, chi tiết món ăn và tổng kết chi phí trước khi thanh toán.
class CheckoutScreen extends StatelessWidget {
  final List<CartItemEntity> items; 
  final double totalPrice; 
  final String? voucherCode; 
  final String? shipperNote; 
  
  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    this.voucherCode,
    this.shipperNote,
  });

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  double _parseVoucher(String? voucher) {
    if (voucher == null || voucher.isEmpty) return 0.0;
    try {
      return double.parse(voucher.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double voucherDiscount = _parseVoucher(voucherCode);
    final double finalPrice = totalPrice - voucherDiscount;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("XÁC NHẬN ĐƠN HÀNG", 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thông tin người mua", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildTextField(nameController, "Họ và tên", Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(phoneController, "Số điện thoại", Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(addressController, "Địa chỉ nhận hàng", Icons.location_on_outlined),
            
            const SizedBox(height: 30),
            const Text("Chi tiết đơn hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ProductImage(imageUrl: item.imageUrl, width: 60, height: 60),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      Text("${_formatCurrency(item.totalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),

            // Khối hiển thị Voucher và Ghi chú shipper
            if ((voucherCode != null && voucherCode!.isNotEmpty) || (shipperNote != null && shipperNote!.isNotEmpty))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    if (voucherCode != null && voucherCode!.isNotEmpty)
                      _buildExtraRow(Icons.confirmation_number_outlined, "Voucher shop:", voucherCode!),
                    if (voucherCode != null && voucherCode!.isNotEmpty && shipperNote != null && shipperNote!.isNotEmpty)
                      const Divider(height: 16),
                    if (shipperNote != null && shipperNote!.isNotEmpty)
                      _buildExtraRow(Icons.delivery_dining_outlined, "Ghi chú shipper:", shipperNote!),
                  ],
                ),
              ),

            const Divider(height: 30),
            _buildPriceRow("Tạm tính:", _formatCurrency(totalPrice), color: Colors.grey[600]!),
            if (voucherDiscount > 0)
              _buildPriceRow("Giảm giá Voucher:", "- ${_formatCurrency(voucherDiscount)} VND", color: Colors.green),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng cộng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${_formatCurrency(finalPrice)} VND",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin"), backgroundColor: Colors.red));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        items: items,
                        totalPrice: totalPrice, 
                        name: nameController.text,
                        phone: phoneController.text,
                        address: addressController.text,
                        voucherCode: voucherCode,
                        shipperNote: shipperNote,
                      ),
                    ),
                  );
                },
                child: const Text("TIẾP TỤC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.orange),
      ),
    );
  }

  Widget _buildExtraRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
