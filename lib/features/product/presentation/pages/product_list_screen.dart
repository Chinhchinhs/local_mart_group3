// features/product/presentation/pages/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import '../../../cart/presentation/cart_screen.dart';
import '../bloc/product_bloc.dart';
import 'admin_action_screen.dart';

class ProductListScreen extends StatelessWidget {
  final bool isDeleteMode;

  const ProductListScreen({
    super.key,
    this.isDeleteMode = false,
  });

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().add(LoadProductsEvent());

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
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isDeleteMode) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      }
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(product.imageUrl),
                          ),
                          Text(product.name),
                          Text("${product.price} VND"),
                        ],
                      ),
                    ),
                  ),

                  if (isDeleteMode)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context
                              .read<ProductBloc>()
                              .add(DeleteProductEvent(product.id));
                        },
                      ),
                    ),
                ],
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