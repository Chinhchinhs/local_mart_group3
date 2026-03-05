import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import 'package:local_mart/features/product/presentation/widgets/product_image.dart';
import '../domain/entities/cart_item_entity.dart';
import 'bloc/cart_bloc.dart';
import '../../checkout/presentation/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhạt cho app chuyên nghiệp
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(state.isSelectionMode ? Icons.close : Icons.checklist_rtl, color: Colors.blue),
                onPressed: () => context.read<CartBloc>().add(ToggleSelectionModeEvent()),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text('Giỏ hàng của bạn đang trống', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('TIẾP TỤC MUA SẮM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              final isSelected = state.selectedItemIds.contains(item.id);

              return Dismissible(
                key: Key('cart_${item.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20), // ĐÃ SỬA: Dùng EdgeInsets.only
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                ),
                onDismissed: (direction) {
                  _handleDeleteItem(context, item);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: state.isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              activeColor: Colors.blue,
                              onChanged: (_) => context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id)),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: ProductImage(imageUrl: item.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${CurrencyFormatter.formatVND(item.price)} VND', 
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: state.isSelectionMode
                          ? null
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
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
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsegit ts.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: state.isSelectionMode
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.selectedItemIds.isEmpty ? Colors.grey[300] : Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: state.selectedItemIds.isEmpty 
                          ? null 
                          : () => context.read<CartBloc>().add(DeleteSelectedItemsEvent()),
                      child: Text('XÓA ${state.selectedItemIds.length} SẢN PHẨM', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tổng thanh toán', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                '${CurrencyFormatter.formatVND(state.totalPrice)} VND',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 5,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(items: state.items, totalPrice: state.totalPrice),
                                ),
                              );
                            },
                            child: const Text('MUA HÀNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 18),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
    );
  }

  void _updateQty(BuildContext context, CartItemEntity item, int delta) {
    if (item.quantity + delta <= 0) {
      _showDeleteConfirm(context, item);
    } else {
      context.read<CartBloc>().add(UpdateQuantityEvent(item.id, item.quantity + delta));
    }
  }

  void _handleDeleteItem(BuildContext context, CartItemEntity item) {
    context.read<CartBloc>().add(RemoveItemEvent(item.id));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${item.name}'),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: Colors.yellow,
          onPressed: () => context.read<CartBloc>().add(AddItemEvent(item)),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, CartItemEntity item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc muốn bỏ ${item.name} khỏi giỏ hàng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('KHÔNG')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleDeleteItem(context, item);
            },
            child: const Text('XÓA', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
