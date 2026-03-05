import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../checkout/presentation/checkout_screen.dart';
import '../../domain/entities/product_entity.dart';



class ProductDetailScreen extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dùng Image.file thay vì Image.network
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(product.imageUrl),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${product.price} VND",
              style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            const Text(
              "Mô tả sản phẩm:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final cartItem = CartItemEntity(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        imageUrl: product.imageUrl,
                      );
                      context.read<CartBloc>().add(
                        AddItemEvent(cartItem),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã thêm vào giỏ hàng thành công!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    label: const Text("Add to Cart"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag), // Đổi icon cho hợp với "Mua ngay"
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // 1. Đóng gói món hàng hiện tại thành 1 CartItem
                      final singleItem = CartItemEntity(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        imageUrl: product.imageUrl,
                        // quantity: 1, // Mở comment dòng này nếu CartItemEntity của bạn có yêu cầu biến quantity
                      );

                      // 2. Chuyển sang màn hình Xác nhận đơn hàng (CheckoutScreen)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            items: [singleItem], // Truyền danh sách chứa 1 món đồ này
                            totalPrice: product.price, // Tổng tiền chính là giá của món này
                          ),
                        ),
                      );
                    },
                    label: const Text("Mua ngay"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}