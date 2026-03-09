import 'package:flutter/material.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../product/presentation/widgets/product_image.dart';
import 'payment_screen.dart';

/// Màn hình Xác nhận đơn hàng: 
/// Hiển thị thông tin khách hàng, chi tiết món ăn, Voucher và tính toán giá tạm thời.
class CheckoutScreen extends StatelessWidget {
  final List<CartItemEntity> items; // Danh sách món từ giỏ hàng
  final double totalPrice; // Giá gốc chưa giảm
  final String? voucherCode; // Mã giảm giá truyền từ giỏ hàng
  final String? shipperNote; // Lời nhắn cho shipper từ giỏ hàng
  
  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    this.voucherCode,
    this.shipperNote,
  });

  /// Hàm định dạng tiền tệ (VD: 60000 -> 60.000 VND)
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Hàm xử lý chuỗi Voucher để lấy giá trị số (VD: "200.000" -> 200000)
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
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    // Logic tính toán hiển thị
    final double voucherDiscount = _parseVoucher(voucherCode);
    final double finalPrice = totalPrice - voucherDiscount;

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

            // Danh sách sản phẩm trong đơn hàng
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final sideNames = item.selectedSideDishes.map((s) => s.name).toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.name, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("${_formatCurrency(item.totalPrice)} VND", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                            Text("SL: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            // Hiển thị món phụ (nếu có)
                            if (sideNames.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text("Món phụ: ${sideNames.join(', ')}", 
                                    style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                              ),
                            // Hiển thị ghi chú món ăn (nếu có)
                            if (item.note.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text("📝 ${item.note}", 
                                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Khối hiển thị Voucher và Ghi chú giao hàng
            if ((voucherCode != null && voucherCode!.isNotEmpty) || (shipperNote != null && shipperNote!.isNotEmpty))
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    if (voucherCode != null && voucherCode!.isNotEmpty)
                      _buildExtraInfo(Icons.confirmation_number_outlined, "Voucher shop:", voucherCode!),
                    if (voucherCode != null && voucherCode!.isNotEmpty && shipperNote != null && shipperNote!.isNotEmpty)
                      const Divider(height: 16),
                    if (shipperNote != null && shipperNote!.isNotEmpty)
                      _buildExtraInfo(Icons.delivery_dining_outlined, "Ghi chú shipper:", shipperNote!),
                  ],
                ),
              ),

            const Divider(height: 40),
            
            // Bảng tóm tắt chi phí
            _buildPriceRow("Tạm tính:", _formatCurrency(totalPrice), color: Colors.grey[600]!),
            if (voucherDiscount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildPriceRow("Giảm giá Voucher:", "- ${_formatCurrency(voucherDiscount)} VND", color: Colors.green),
              ),
            
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
            
            // Nút điều hướng sang màn hình Thanh toán
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  foregroundColor: Colors.white,
                  elevation: 0,
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
                        totalPrice: totalPrice, // Chú ý: Truyền giá gốc để tránh trừ voucher 2 lần
                        name: nameController.text,
                        phone: phoneController.text,
                        address: addressController.text,
                        voucherCode: voucherCode,
                        shipperNote: shipperNote,
                      ),
                    ),
                  );
                },
                child: const Text("TIẾP TỤC THANH TOÁN", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget xây dựng các ô nhập liệu đồng bộ màu sắc
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.orange),
      ),
    );
  }

  /// Widget hiển thị các dòng thông tin bổ sung (Voucher/Shipper)
  Widget _buildExtraInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }

  /// Widget hiển thị các dòng giá tiền
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
