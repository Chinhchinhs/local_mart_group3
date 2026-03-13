import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:local_mart/features/cart/presentation/pages/order_history_screen.dart'; // THÊM IMPORT
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
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(FetchRemoteCategoriesEvent());
    context.read<ProductBloc>().add(LoadProductsEvent());
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isAdmin = authState.status == AuthStatus.admin;
        final bool isLoggedIn = authState.status == AuthStatus.authenticated || isAdmin;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("LocalMart Food", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 24)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: _buildLeadingAction(isLoggedIn, isAdmin, authState.user?.username ?? "admin"),
            actions: [
              if (!widget.isDeleteMode)
                _buildCartIcon(context),
            ],
          ),
          body: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.orange,
                child: _buildBody(state, isAdmin),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(ProductState state, bool isAdmin) {
    if (widget.isDeleteMode) {
      return _buildAdminGridView(state, isAdmin);
    }

    return Column(
      children: [
        _buildSearchField(),
        Expanded(child: _buildUserHomeView(state, isAdmin)),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Tìm kiếm món ngon...",
          prefixIcon: const Icon(Icons.search, color: Colors.orange),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ""); })
            : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildLeadingAction(bool isLoggedIn, bool isAdmin, String userId) {
    if (widget.isDeleteMode) {
      return IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context));
    }

    if (!isLoggedIn) {
      return IconButton(
        icon: const Icon(Icons.person_outline, color: Colors.black),
        onPressed: () => _navigateToLogin(),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, color: Colors.orange, size: 30),
      onSelected: (value) {
        if (value == 'logout') {
          _handleLogout();
        } else if (value == 'admin') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminActionScreen()));
        } else if (value == 'history') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen(userId: userId, isAdmin: isAdmin)));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(isAdmin ? "Chào Admin" : "Chào khách hàng", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        ),
        PopupMenuItem(
          value: 'history',
          child: Row(children: [Icon(Icons.history, color: Colors.blue[700]), const SizedBox(width: 8), Text(isAdmin ? "Quản lý đơn hàng" : "Lịch sử mua hàng")]),
        ),
        if (isAdmin)
          const PopupMenuItem(
            value: 'admin',
            child: Row(children: [Icon(Icons.admin_panel_settings, color: Colors.orange), SizedBox(width: 8), Text("Quản lý Admin")]),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text("Đăng xuất")]),
        ),
      ],
    );
  }

  Widget _buildUserHomeView(ProductState state, bool isAdmin) {
    final localFiltered = state.localProducts.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
    final remoteFiltered = state.currentDisplayProducts.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (_searchQuery.isEmpty) _buildCategoryBar(state),

        if (localFiltered.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Text("Món Ngon Nhà Làm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: localFiltered.length,
              itemBuilder: (context, index) => Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: _buildProductCard(context, state, localFiltered[index], isAdmin, isHorizontal: true),
              ),
            ),
          ),
        ],

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(_searchQuery.isEmpty ? state.selectedCategory : "Kết quả tìm kiếm", 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        
        if (state.isLoading && remoteFiltered.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Colors.orange)))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: remoteFiltered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) => _buildProductCard(context, state, remoteFiltered[index], isAdmin),
          ),
      ],
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
                child: Text(
                  name, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminGridView(ProductState state, bool isAdmin) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.localProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => _buildProductCard(context, state, state.localProducts[index], isAdmin),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductState state, dynamic product, bool isAdmin, {bool isHorizontal = false}) {
    final bool isBestSeller = state.bestSellerProducts.any((p) => p.id == product.id);
    final bool isOutOfStock = product.isOutOfStock;

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
              Opacity(
                opacity: isOutOfStock ? 0.4 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: isOutOfStock ? null : () => Navigator.push(context, MaterialPageRoute(
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
                                  onTap: isOutOfStock ? null : () {
                                    context.read<CartBloc>().add(AddItemEvent(CartItemEntity(
                                      id: product.id, name: product.name, price: product.price, imageUrl: product.imageUrl,
                                    )));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ"), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)));
                                  },
                                  child: Icon(Icons.add_circle, color: isOutOfStock ? Colors.grey : Colors.orange),
                                )
                              else if (isAdmin)
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
              ),
              if (isOutOfStock)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: const Text("HẾT MÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              if (isAdmin)
                Positioned(
                  top: 5, right: 5,
                  child: GestureDetector(
                    onTap: () => context.read<ProductBloc>().add(ToggleOutOfStockEvent(product.id)),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: isOutOfStock ? Colors.red : Colors.green, shape: BoxShape.circle),
                      child: Icon(isOutOfStock ? Icons.do_not_disturb_on : Icons.check_circle, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              if (isBestSeller)
                _buildHotTag(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotTag() {
    return Positioned(
      top: 8, left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
        child: const Row(children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 14),
          SizedBox(width: 2),
          Text("HOT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _showBestSellerDialog(BuildContext context, dynamic product, bool isCurrentlyBestSeller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Best Seller 🔥"),
        content: Text(isCurrentlyBestSeller ? "Gỡ danh hiệu?" : "Gắn danh hiệu Best Seller cho món này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(ToggleBestSellerEvent(product));
              Navigator.pop(ctx);
            },
            child: const Text("Đồng ý"),
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

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _handleLogout() {
    context.read<AuthBloc>().add(LogoutEvent());
  }

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
