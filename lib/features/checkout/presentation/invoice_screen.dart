import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../product/presentation/widgets/product_image.dart';

class InvoiceScreen extends StatelessWidget {
  final List<CartItemEntity> items;
  final double totalPrice;
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;

  const InvoiceScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
  });

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'card':
        return 'Thanh toán qua thẻ';
      case 'bank':
        return 'Chuyển khoản ngân hàng';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("HÓA ĐƠN CHI TIẾT", 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text(
              "Đặt hàng thành công!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text("Cảm ơn bạn đã mua sắm tại Local Mart", style: TextStyle(color: Colors.grey)),
            const Divider(height: 40),

            _buildSectionTitle("Thông tin khách hàng"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.person_outline, "Tên khách hàng:", name),
                  const SizedBox(height: 10),
                  _infoRow(Icons.phone_outlined, "Số điện thoại:", phone),
                  const SizedBox(height: 10),
                  _infoRow(Icons.location_on_outlined, "Địa chỉ nhận:", address),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionTitle("Chi tiết đơn hàng"),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final sideNames = item.selectedSideDishes.map((s) => s.name).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ProductImage(imageUrl: item.imageUrl, width: 50, height: 50),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sửa lỗi tràn tên sản phẩm ở Invoice
                                Text(item.name, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("${_formatCurrency(item.totalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (sideNames.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 62, top: 4),
                          child: Text("Món phụ: ${sideNames.join(', ')}", 
                            style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                        ),
                      if (item.note.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 62, top: 2),
                          child: Text("Ghi chú: ${item.note}", 
                            style: const TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic)),
                        ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 30),

            // Sửa lỗi tràn tại dòng Phương thức thanh toán
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên để trông đẹp hơn khi xuống dòng
              children: [
                const Text("Phương thức thanh toán:", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getPaymentMethodText(paymentMethod), 
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG THANH TOÁN:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "${_formatCurrency(totalPrice)} VND",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 40),

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
                  context.read<CartBloc>().add(ClearCartEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cảm ơn bạn đã ủng hộ Local Mart! ✅"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("QUAY VỀ TRANG CHỦ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 6),
        // Sửa lỗi tràn thông tin khách hàng nếu địa chỉ quá dài
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }
}
