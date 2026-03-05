// features/product/presentation/pages/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
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
          children: [
            Image.network(product.imageUrl),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 22)),
            Text("${product.price} VND"),
            const SizedBox(height: 16),
            Text(product.description),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
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
                        const SnackBar(content: Text("Added to cart")),
                      );
                    },
                    child: const Text("Add to Cart"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Payment"),
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