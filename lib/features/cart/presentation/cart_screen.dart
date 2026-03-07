import 'dart:io'; // CHỈ THÊM DÒNG NÀY ĐỂ HẾT LỖI BUILD
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import 'package:local_mart/features/product/presentation/bloc/product_bloc.dart';
import 'package:local_mart/features/product/presentation/bloc/product_state.dart';
import '../domain/entities/cart_item_entity.dart';
import 'bloc/cart_bloc.dart';
import '../../checkout/presentation/checkout_screen.dart';

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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              final isSelected = state.selectedItemIds.contains(item.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  onTap: () {
                    if (state.isSelectionMode) {
                      context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id));
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
                        child: SizedBox(width: 70, height: 70, child: Image.file(File(item.imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood))),
                      ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(item.price), 
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      if (item.selectedSideDishes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("• ${item.selectedSideDishes.length} món phụ đã chọn", 
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
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
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
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: state.isSelectionMode
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.selectedItemIds.isEmpty ? Colors.grey : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: state.selectedItemIds.isEmpty ? null : () => context.read<CartBloc>().add(DeleteSelectedItemsEvent()),
                    child: Text("XÓA ${state.selectedItemIds.length} MÓN ĐÃ CHỌN", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tổng cộng", style: TextStyle(color: Colors.grey)),
                          Text(CurrencyFormatter.format(state.totalPrice), 
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CheckoutScreen(items: state.items, totalPrice: state.totalPrice)
                        )),
                        child: const Text("THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
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

  void _updateQty(BuildContext context, CartItemEntity item, int delta) {
    if (item.quantity + delta > 0) {
      context.read<CartBloc>().add(UpdateQuantityEvent(item.id, item.quantity + delta));
    }
  }
}
