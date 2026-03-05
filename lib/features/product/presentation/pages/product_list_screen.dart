import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import 'product_detail_screen.dart';
import '../../../cart/presentation/cart_screen.dart';
import 'admin_action_screen.dart';
import 'dart:io';
import '../bloc/product_state.dart';

class ProductListScreen extends StatefulWidget {
  final bool isDeleteMode;

  const ProductListScreen({
    super.key,
    this.isDeleteMode = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("LocalMart"),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            _showAdminLogin(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.products.isEmpty) {
            return const Center(child: Text("Chưa có sản phẩm"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];

              // 🔥 Đã bọc InkWell và Navigator.push ở đây
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.file(
                          File(product.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("${product.price} VND", style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAdminLogin(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Admin Login"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Password"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text == "admin123") {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminActionScreen(),
                  ),
                );
              }
            },
            child: const Text("Login"),
          )
        ],
      ),
    );
  }
}