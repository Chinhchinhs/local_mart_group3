import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_state.dart';
import 'product_detail_screen.dart';
import 'admin_delete_detail_screen.dart';
import '../../../cart/presentation/cart_screen.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import 'admin_action_screen.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/mart_search_bar.dart';
import 'dart:io';

class ProductListScreen extends StatefulWidget {
  final bool isDeleteMode;
  final bool isAdminPreview;

  const ProductListScreen({
    super.key,
    this.isDeleteMode = false,
    this.isAdminPreview = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.initial && (widget.isDeleteMode || widget.isAdminPreview)) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ProductListScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("LocalMart Food", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: !widget.isAdminPreview, 
          leading: widget.isDeleteMode || widget.isAdminPreview
              ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))
              : BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoggedIn = state.status == AuthStatus.authenticated || state.status == AuthStatus.admin;
                    return IconButton(
                      icon: Icon(isLoggedIn ? Icons.logout : Icons.person_outline, color: Colors.black),
                      onPressed: () {
                        if (isLoggedIn) {
                          context.read<AuthBloc>().add(LogoutEvent());
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) => _refreshData());
                        }
                      },
                    );
                  },
                ),
          actions: [
            if (!widget.isDeleteMode && !widget.isAdminPreview)
              _buildCartIcon(context),
          ],
          // THANH TÌM KIẾM LUÔN HIỂN THỊ
          bottom: MartSearchBar(
            controller: searchController,
            hintText: "Bạn muốn ăn gì hôm nay?",
            onChanged: (val) => setState(() => searchQuery = val.trim().toLowerCase()),
            onClear: () => setState(() => searchQuery = ""),
          ),
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state.isLoading && state.products.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }
            
            if (state.products.isEmpty) {
              return _buildEmptyView();
            }

            // LOGIC CỐ ĐỊNH VỊ TRÍ VÀ TÌM KIẾM
            List<ProductEntity> displayList = List.from(state.products);
            displayList.sort((a, b) => a.name.compareTo(b.name));
            
            if (searchQuery.isNotEmpty) {
              displayList.sort((a, b) {
                bool aMatch = a.name.toLowerCase().contains(searchQuery);
                bool bMatch = b.name.toLowerCase().contains(searchQuery);
                if (aMatch && !bMatch) return -1;
                if (!aMatch && bMatch) return 1;
                return a.name.compareTo(b.name);
              });
            }

            if (widget.isDeleteMode) {
              return _buildAdminListView(displayList);
            }

            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  childAspectRatio: 0.7, 
                  crossAxisSpacing: 16, 
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final product = displayList[index];
                  return _buildProductCard(product);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    final bool isAvailable = product.isAvailable;
    return GestureDetector(
      onTap: () {
        if (isAvailable || widget.isAdminPreview) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => widget.isAdminPreview 
              ? AdminDeleteDetailScreen(product: product) 
              : ProductDetailScreen(product: product, isReadOnly: widget.isAdminPreview)
          )).then((_) => _refreshData());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(isAvailable ? Colors.transparent : Colors.grey, BlendMode.saturation),
                  child: Opacity(
                    opacity: isAvailable ? 1.0 : 0.7,
                    child: Image.file(File(product.imageUrl), width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.fastfood, color: Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(product.name, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: isAvailable ? Colors.black87 : Colors.grey[600], 
                          decoration: isAvailable ? null : TextDecoration.lineThrough
                        ), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(product.price), 
                        style: TextStyle(
                          color: isAvailable ? Colors.red : Colors.grey[500], 
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                          decoration: isAvailable ? null : TextDecoration.lineThrough
                        )
                      ),
                      const SizedBox(height: 4),
                      if (!isAvailable)
                        const Text("Sản phẩm đang hết", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                      else if (!widget.isDeleteMode && !widget.isAdminPreview)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              context.read<CartBloc>().add(AddItemEvent(CartItemEntity(
                                id: "${product.id}_${DateTime.now().millisecondsSinceEpoch}",
                                name: product.name,
                                price: product.price,
                                imageUrl: product.imageUrl,
                                quantity: 1,
                              )));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Đã thêm ${product.name} vào giỏ"),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Icon(Icons.add_circle, color: Colors.orange, size: 26),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fastfood_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Chưa có món ăn nào", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white), onPressed: _refreshData, child: const Text("Tải lại trang"))
        ],
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.items.isEmpty) return const SizedBox.shrink();
            return Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text("${state.items.length}", style: const TextStyle(color: Colors.white, fontSize: 10))));
          },
        )
      ],
    );
  }

  Widget _buildAdminListView(List<ProductEntity> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final bool isAvailable = product.isAvailable;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDeleteDetailScreen(product: product))).then((_) => _refreshData()),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(isAvailable ? Colors.transparent : Colors.grey, BlendMode.saturation),
                child: Opacity(
                  opacity: isAvailable ? 1.0 : 0.6,
                  child: Image.file(File(product.imageUrl), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood))),
                ),
              ),
            ),
            title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: isAvailable ? Colors.black87 : Colors.grey, decoration: isAvailable ? null : TextDecoration.lineThrough)),
            subtitle: Text(CurrencyFormatter.format(product.price), style: TextStyle(color: isAvailable ? Colors.red : Colors.grey, fontWeight: FontWeight.bold, decoration: isAvailable ? null : TextDecoration.lineThrough)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}
