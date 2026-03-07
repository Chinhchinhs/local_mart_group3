import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import 'package:local_mart/features/product/presentation/widgets/product_image.dart';
import 'package:local_mart/features/product/presentation/bloc/product_bloc.dart';
import 'package:local_mart/features/product/presentation/bloc/product_state.dart';
import '../domain/entities/cart_item_entity.dart';
import 'bloc/cart_bloc.dart';
import '../../checkout/presentation/checkout_screen.dart';
import 'pages/edit_cart_item_screen.dart';

// WIDGET HỖ TRỢ HIỆU ỨNG SỐ NHẢY
class AnimatedPriceText extends StatefulWidget {
  final double begin;
  final double end;
  final TextStyle style;

  const AnimatedPriceText({
    super.key, 
    required this.begin, 
    required this.end, 
    required this.style
  });

  @override
  State<AnimatedPriceText> createState() => _AnimatedPriceTextState();
}

class _AnimatedPriceTextState extends State<AnimatedPriceText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween<double>(begin: widget.begin, end: widget.end).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _animation = Tween<double>(begin: oldWidget.end, end: widget.end).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          CurrencyFormatter.formatVND(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}

// WIDGET GHI CHÚ RIÊNG BIỆT ĐỂ KHÔNG LAG KHI GÕ
class OrderNoteField extends StatefulWidget {
  const OrderNoteField({super.key});

  @override
  State<OrderNoteField> createState() => _OrderNoteFieldState();
}

class _OrderNoteFieldState extends State<OrderNoteField> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        icon: Icon(Icons.note_alt_outlined, size: 18, color: Colors.grey),
        hintText: "Ghi chú cho shipper...",
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GIỎ HÀNG', 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 24, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(state.isSelectionMode ? Icons.close : Icons.delete_sweep_outlined, 
                  color: state.isSelectionMode ? Colors.red : Colors.blue, size: 28),
                onPressed: () => context.read<CartBloc>().add(ToggleSelectionModeEvent()),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return _buildEmptyCart(context);

          return Column(
            children: [
              _buildFreeShipProgress(state.totalPrice),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: state.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return _buildRecommendations(context);
                    }

                    final item = state.items[index];
                    final isSelected = state.selectedItemIds.contains(item.id);

                    return Dismissible(
                      key: Key('cart_${item.id}'),
                      direction: state.isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 25),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.delete_forever, color: Colors.white, size: 35),
                      ),
                      onDismissed: (direction) {
                        context.read<CartBloc>().add(RemoveItemEvent(item.id));
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showUndoSnackBar(context, item);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          onTap: () {
                            if (state.isSelectionMode) {
                              context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id));
                            } else {
                              _navigateToEdit(context, item);
                            }
                          },
                          leading: state.isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                activeColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (_) => context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id)),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(width: 70, height: 70, child: ProductImage(imageUrl: item.imageUrl, fit: BoxFit.cover)),
                              ),
                          title: Text(item.name, 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(CurrencyFormatter.formatVND(item.totalPrice), 
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                              
                              if (item.selectedSideDishes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text("• ${item.selectedSideDishes.length} món phụ: ${item.selectedSideDishes.map((e) => e.name).join(', ')}", 
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                ),
                              if (item.note.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text("📝 ${item.note}", 
                                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.orange)),
                                ),
                            ],
                          ),
                          trailing: state.isSelectionMode 
                            ? null 
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _qtyBtn(Icons.remove, () => _updateQty(context, item, -1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    _qtyBtn(Icons.add, () => _updateQty(context, item, 1)),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildFreeShipProgress(double totalPrice) {
    const double threshold = 200000;
    double progress = totalPrice / threshold;
    if (progress > 1.0) progress = 1.0;
    double remaining = threshold - totalPrice;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  totalPrice >= threshold 
                    ? "Bạn đã được MIỄN PHÍ vận chuyển! 🎉" 
                    : "Mua thêm ${CurrencyFormatter.formatVND(remaining)} để được Freeship",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final List<Map<String, dynamic>> staticItems = [
      {'name': 'Nước ngọt', 'price': 15000.0, 'icon': Icons.local_drink, 'id': 'static_soda'},
      {'name': 'Nước suối', 'price': 10000.0, 'icon': Icons.water_drop, 'id': 'static_water'},
      {'name': 'Khoai tây', 'price': 25000.0, 'icon': Icons.fastfood, 'id': 'static_fries'},
      {'name': 'Khăn lạnh', 'price': 2000.0, 'icon': Icons.dry_cleaning, 'id': 'static_tissue'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          child: Text("Mọi người thường mua cùng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: staticItems.length,
            itemBuilder: (context, index) {
              final item = staticItems[index];
              return _recommendCard(context, item['name'], item['price'], item['icon'], item['id']);
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _recommendCard(BuildContext context, String name, double price, IconData icon, String id) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12, bottom: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.orange, size: 30),
          const SizedBox(height: 10),
          Text(name, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.formatVND(price), 
            style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              final cartItem = CartItemEntity(
                id: id + DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                price: price,
                imageUrl: "", 
                quantity: 1,
              );
              context.read<CartBloc>().add(AddItemEvent(cartItem));
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Đã thêm $name"), duration: const Duration(seconds: 1)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text("Giỏ hàng trống", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      // ĐIỀU KIỆN BUILD QUAN TRỌNG ĐỂ XÓA ĐƯỢC NHIỀU MÓN
      buildWhen: (previous, current) => 
          previous.totalPrice != current.totalPrice || 
          previous.isSelectionMode != current.isSelectionMode ||
          previous.selectedItemIds.length != current.selectedItemIds.length,
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, -5))],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!state.isSelectionMode) ...[
                  // VOUCHER TĨNH
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chọn Voucher")));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Row(
                        children: [
                          Icon(Icons.confirmation_num_outlined, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text("Voucher của shop", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text("Chọn hoặc nhập mã", style: TextStyle(color: Colors.blue, fontSize: 12)),
                          Icon(Icons.chevron_right, color: Colors.blue, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // GHI CHÚ TĨNH
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: OrderNoteField(),
                  ),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),
                ],

                state.isSelectionMode
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.selectedItemIds.isEmpty ? Colors.grey : Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: state.selectedItemIds.isEmpty ? null : () => context.read<CartBloc>().add(DeleteSelectedItemsEvent()),
                      child: Text("XÓA ${state.selectedItemIds.length} MÓN ĐÃ CHỌN", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tổng cộng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              AnimatedPriceText(
                                begin: 0, 
                                end: state.totalPrice, 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CheckoutScreen(items: state.items, totalPrice: state.totalPrice)
                            )),
                            child: const Text("THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 16, color: Colors.orange)),
    );
  }

  void _navigateToEdit(BuildContext context, CartItemEntity item) {
    final productState = context.read<ProductBloc>().state;
    final allProducts = [...productState.remoteProducts, ...productState.localProducts];
    final originalProduct = allProducts.firstWhere(
      (p) => p.name == item.name,
      orElse: () => productState.remoteProducts.isNotEmpty ? productState.remoteProducts.first : allProducts.first
    );

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EditCartItemScreen(
        item: item, 
        allAvailableSideDishes: originalProduct.sideDishes
      )
    ));
  }

  void _updateQty(BuildContext context, CartItemEntity item, int delta) {
    if (item.quantity + delta > 0) {
      context.read<CartBloc>().add(UpdateQuantityEvent(item.id, item.quantity + delta));
    }
  }

  void _showUndoSnackBar(BuildContext context, CartItemEntity item) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    
    messenger.showSnackBar(
      SnackBar(
        content: Text("Đã xóa ${item.name}"),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16), 
        action: SnackBarAction(
          label: "HOÀN TÁC",
          textColor: Colors.orange,
          onPressed: () {
            messenger.clearSnackBars();
            context.read<CartBloc>().add(AddItemEvent(item));
          },
        ),
      ),
    );

    Timer(const Duration(seconds: 5), () {
      try { messenger.clearSnackBars(); } catch (_) {}
    });
  }
}
