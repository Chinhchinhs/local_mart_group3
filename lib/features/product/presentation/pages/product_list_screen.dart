import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import 'product_detail_screen.dart';
import 'admin_delete_detail_screen.dart';
import '../../../cart/presentation/cart_screen.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import 'admin_action_screen.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/product_image.dart';
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
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(FetchRemoteCategoriesEvent());
    context.read<ProductBloc>().add(LoadProductsEvent());
    // Đợi một chút để tạo cảm giác mượt mà khi refresh
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("LocalMart Food", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: widget.isDeleteMode 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))
          : IconButton(
              icon: Icon(isUserLoggedIn || isAdmin ? Icons.logout : Icons.person_outline, color: Colors.black),
              onPressed: () => isUserLoggedIn || isAdmin ? _handleLogout() : _navigateToLogin(),
            ),
        actions: [
          if (!widget.isDeleteMode)
            _buildCartIcon(context),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (widget.isDeleteMode) {
            return _buildAdminGridView(state);
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.orange,
            child: _buildUserHomeView(state),
          );
        },
      ),
    );
  }

  Widget _buildUserHomeView(ProductState state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // Đảm bảo luôn có thể vuốt để refresh
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryBar(state),

          // 2. Món ngon nhà làm (Local)
          if (state.localProducts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Text("Món Ngon Nhà Làm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.localProducts.length,
                itemBuilder: (context, index) => Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildProductCard(context, state, state.localProducts[index], isHorizontal: true),
                ),
              ),
            ),
          ],

          // 3. Thực đơn
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(state.selectedCategory, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          
          if (state.isLoading && state.remoteProducts.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Colors.orange)))
          else if (state.selectedCategory == "Best Seller" && state.bestSellerProducts.isEmpty)
             const Center(
               child: Padding(
                 padding: EdgeInsets.all(40),
                 child: Column(
                   children: [
                     Icon(Icons.local_fire_department_outlined, size: 60, color: Colors.grey),
                     SizedBox(height: 10),
                     Text("Admin chưa chọn món bán chạy nào", style: TextStyle(color: Colors.grey)),
                   ],
                 ),
               ),
             )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.remoteProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) => _buildProductCard(context, state, state.remoteProducts[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(ProductState state) {
    if (state.categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final String name = category['name']!;
          final String img = category['image']!;
          final isSelected = state.selectedCategory == name;
          final bool isBestSellerCard = name == "Best Seller";

          return GestureDetector(
            onTap: () {
              context.read<ProductBloc>().add(FetchRemoteProductsEvent(category: name));
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(img),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(isSelected ? 0.2 : 0.5), 
                    BlendMode.darken
                  ),
                ),
                border: isSelected ? Border.all(color: Colors.orange, width: 3) : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isBestSellerCard)
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                    Text(
                      name, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 13,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminGridView(ProductState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.localProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => _buildProductCard(context, state, state.localProducts[index]),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductState state, dynamic product, {bool isHorizontal = false}) {
    final bool isBestSeller = state.bestSellerProducts.any((p) => p.id == product.id);

    return GestureDetector(
      onLongPress: isAdmin ? () => _showBestSellerDialog(context, product, isBestSeller) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: isBestSeller ? Colors.orange.withOpacity(0.3) : Colors.grey[100]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => widget.isDeleteMode ? AdminDeleteDetailScreen(product: product) : ProductDetailScreen(product: product)
                      )),
                      child: Hero(tag: product.id + (isHorizontal ? "_horiz" : ""), 
                        child: ProductImage(imageUrl: product.imageUrl, width: double.infinity, fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(CurrencyFormatter.format(product.price), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                            if (!widget.isDeleteMode)
                              GestureDetector(
                                onTap: () {
                                  context.read<CartBloc>().add(AddItemEvent(CartItemEntity(
                                    id: product.id, name: product.name, price: product.price, imageUrl: product.imageUrl,
                                  )));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ"), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)));
                                },
                                child: const Icon(Icons.add_circle, color: Colors.orange),
                              )
                            else
                              GestureDetector(
                                onTap: () => _confirmDelete(context, product.id, product.name),
                                child: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isBestSeller)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                        SizedBox(width: 2),
                        Text("HOT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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

  void _showBestSellerDialog(BuildContext context, dynamic product, bool isCurrentlyBestSeller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: isCurrentlyBestSeller ? Colors.grey : Colors.orange),
            const SizedBox(width: 10),
            const Text("Best Seller"),
          ],
        ),
        content: Text(isCurrentlyBestSeller 
          ? "Bạn muốn gỡ danh hiệu Best Seller cho món '${product.name}'?"
          : "Bạn muốn gắn danh hiệu Best Seller (🔥) cho món '${product.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              context.read<ProductBloc>().add(ToggleBestSellerEvent(product));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isCurrentlyBestSeller ? "Đã gỡ danh hiệu" : "Đã thêm vào Best Seller 🔥"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.items.isEmpty) return const SizedBox.shrink();
            return Positioned(right: 8, top: 8, child: Container(
              padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text("${state.items.length}", style: const TextStyle(color: Colors.white, fontSize: 10)),
            ));
          },
        )
      ],
    );
  }

  void _navigateToLogin() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (result != null && result is Map) {
      setState(() { isAdmin = result['isAdmin'] ?? false; isUserLoggedIn = true; });
      if (isAdmin) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminActionScreen()));
    }
  }

  void _handleLogout() { setState(() { isAdmin = false; isUserLoggedIn = false; }); }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Xóa món '$name' khỏi thực đơn?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(onPressed: () { context.read<ProductBloc>().add(DeleteProductEvent(id)); Navigator.pop(context); },
            child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
