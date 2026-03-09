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
import '../widgets/product_image.dart'; // Dùng widget này để tự nhận diện Link/File

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
          bottom: MartSearchBar(
            controller: searchController,
            hintText: "Bạn muốn ăn gì hôm nay?",
            onChanged: (val) => setState(() => searchQuery = val.trim().toLowerCase()),
            onClear: () => setState(() => searchQuery = ""),
          ),
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return Column(
              children: [
                // 1. THANH CHỌN DANH MỤC (CHỈ HIỆN KHI KHÔNG PHẢI CHẾ ĐỘ ADMIN)
                if (!widget.isDeleteMode && !widget.isAdminPreview && state.categories.isNotEmpty)
                  _buildCategoryList(state),

                // 2. DANH SÁCH MÓN ĂN
                Expanded(
                  child: state.isLoading && state.products.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                      : _buildMainContent(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryList(ProductState state) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          final isSelected = state.selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => context.read<ProductBloc>().add(ChangeCategoryEvent(cat['name']!)),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                cat['name']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(ProductState state) {
    if (state.products.isEmpty) return _buildEmptyView();

    List<ProductEntity> displayList = List.from(state.products);
    if (searchQuery.isNotEmpty) {
      displayList = displayList.where((p) => p.name.toLowerCase().contains(searchQuery)).toList();
    }

    if (widget.isDeleteMode) return _buildAdminListView(displayList);

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
        itemBuilder: (context, index) => _buildProductCard(displayList[index]),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SỬA LỖI Ở ĐÂY: DÙNG PRODUCTIMAGE THAY VÌ IMAGE.FILE
              Expanded(
                flex: 5,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(isAvailable ? Colors.transparent : Colors.grey, BlendMode.saturation),
                  child: Opacity(
                    opacity: isAvailable ? 1.0 : 0.7,
                    child: ProductImage(imageUrl: product.imageUrl, width: double.infinity, fit: BoxFit.cover),
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
                      Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isAvailable ? Colors.black87 : Colors.grey[600], decoration: isAvailable ? null : TextDecoration.lineThrough), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(product.price), style: TextStyle(color: isAvailable ? Colors.red : Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 14, decoration: isAvailable ? null : TextDecoration.lineThrough)),
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
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ"), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green));
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
              child: ProductImage(imageUrl: product.imageUrl, width: 60, height: 60),
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
