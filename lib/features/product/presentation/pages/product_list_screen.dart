import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import 'product_detail_screen.dart';
import 'admin_delete_detail_screen.dart'; // Màn hình xóa chi tiết của Admin
import '../../../cart/presentation/cart_screen.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import 'admin_action_screen.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';
import '../../../../core/utils/currency_formatter.dart';
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
  static bool isAdmin = false;
  static bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("LocalMart Food", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.isDeleteMode 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))
          : IconButton(
              icon: Icon(isUserLoggedIn || isAdmin ? Icons.logout : Icons.person_outline, color: Colors.black),
              onPressed: () {
                if (isUserLoggedIn || isAdmin) {
                  _handleLogout();
                } else {
                  _navigateToLogin();
                }
              },
            ),
        actions: [
          if (!widget.isDeleteMode)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state.items.isEmpty) return const SizedBox.shrink();
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text("${state.items.length}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    );
                  },
                )
              ],
            ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.orange));
          if (state.products.isEmpty) return const Center(child: Text("Chưa có món ăn nào"));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // ĐIỀU HƯỚNG THÔNG MINH
                                if (widget.isDeleteMode) {
                                  // Nếu đang ở trang xóa của Admin -> vào trang xóa chi tiết
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDeleteDetailScreen(product: product)));
                                } else {
                                  // Nếu đang ở trang chủ khách hàng -> vào trang chi tiết mua hàng
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
                                }
                              },
                              child: Hero(
                                tag: product.id,
                                child: Image.file(
                                  File(product.imageUrl),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 50, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(CurrencyFormatter.format(product.price), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: widget.isDeleteMode
                            ? FloatingActionButton.small(
                                heroTag: "del_${product.id}",
                                backgroundColor: Colors.red,
                                child: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _confirmDelete(context, product.id, product.name),
                              )
                            : FloatingActionButton.small(
                                heroTag: "add_${product.id}",
                                backgroundColor: Colors.orange,
                                child: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  context.read<CartBloc>().add(AddItemEvent(CartItemEntity(
                                    id: product.id,
                                    name: product.name,
                                    price: product.price,
                                    imageUrl: product.imageUrl,
                                  )));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Đã thêm ${product.name} vào giỏ"),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                },
                              ),
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

  void _navigateToLogin() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (result != null && result is Map) {
      setState(() {
        isAdmin = result['isAdmin'] ?? false;
        isUserLoggedIn = true;
      });
      if (isAdmin) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminActionScreen()));
      }
    }
  }

  void _handleLogout() {
    setState(() {
      isAdmin = false;
      isUserLoggedIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đăng xuất")));
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa món '$name' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(id));
              Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
