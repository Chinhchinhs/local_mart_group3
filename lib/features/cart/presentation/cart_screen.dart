import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/cart_item_entity.dart';
import 'bloc/cart_bloc.dart';
import '../../checkout/presentation/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng LocalMart', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(state.isSelectionMode ? Icons.close : Icons.checklist_rtl),
                tooltip: state.isSelectionMode ? 'Hủy chọn' : 'Chọn nhiều để xóa',
                onPressed: () {
                  context.read<CartBloc>().add(ToggleSelectionModeEvent());
                },
              );
            },
          )
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80),
                  SizedBox(height: 16),
                  Text('Giỏ hàng của bạn đang trống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Hãy thêm sản phẩm để tiếp tục mua sắm nhé!', style: TextStyle(fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: state.isSelectionMode
                        ? Checkbox(
                      value: state.selectedItemIds.contains(item.id),
                      onChanged: (bool? value) {
                        context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id));
                      },
                    )
                        : Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.fastfood, size: 36),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Giá: ${item.price} VND', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    trailing: state.isSelectionMode
                        ? null
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => context.read<CartBloc>().add(UpdateQuantityEvent(item.id, item.quantity - 1)),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => context.read<CartBloc>().add(UpdateQuantityEvent(item.id, item.quantity + 1)),
                        ),
                      ],
                    ),
                    onTap: state.isSelectionMode
                        ? () => context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id))
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          // Nếu giỏ hàng trống, ta có thể ẩn hẳn thanh BottomBar hoặc giữ lại ,
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

                child: state.isSelectionMode
                // trạng thái đang chọn để xóa
                    ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.selectedItemIds.isEmpty ? Colors.grey.shade400 : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.delete_forever, size: 24),
                    label: Text('XÓA ${state.selectedItemIds.length} MÓN ĐÃ CHỌN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: state.selectedItemIds.isEmpty
                        ? null
                        : () => context.read<CartBloc>().add(DeleteSelectedItemsEvent()),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tổng thanh toán:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${state.totalPrice} VND',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      onPressed: state.items.isEmpty
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(
                              items: state.items,
                              totalPrice: state.totalPrice,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        state.items.isEmpty
                            ? "CHƯA CÓ SẢN PHẨM"
                            : "MUA HÀNG",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}