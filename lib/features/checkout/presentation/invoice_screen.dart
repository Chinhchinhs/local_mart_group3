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
      appBar: AppBar(
        title: const Text("HÓA ĐƠN CHI TIẾT"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text(
              "Đặt hàng thành công!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Text("Cảm ơn bạn đã mua sắm tại Local Mart"),
            const Divider(height: 40),

            _buildSectionTitle("Thông tin khách hàng"),
            Card(
              elevation: 0,
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person, "Tên:", name),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, "SĐT:", phone),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, "Địa chỉ:", address),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Chi tiết đơn hàng"),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ProductImage(imageUrl: item.imageUrl, width: 40, height: 40),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text("SL: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text("${_formatCurrency(item.price * item.quantity)} VND"),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Phương thức:", style: TextStyle(color: Colors.grey)),
                Text(_getPaymentMethodText(paymentMethod), style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng thanh toán:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "${_formatCurrency(totalPrice)} VND",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  context.read<CartBloc>().add(ClearCartEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đơn hàng đã được ghi nhận thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("QUAY VỀ TRANG CHỦ", style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 4),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}
