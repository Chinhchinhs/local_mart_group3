import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import 'package:local_mart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:local_mart/features/checkout/presentation/checkout_screen.dart';
import '../bloc/cart_bloc.dart';
import 'cart_helper_widgets.dart';

class CartBottomBar extends StatelessWidget {
  final CartState state;
  final String voucherCode;
  final String shipperNote;
  final Function(String) onVoucherChanged;
  final Function(String) onNoteChanged;

  const CartBottomBar({
    super.key,
    required this.state,
    required this.voucherCode,
    required this.shipperNote,
    required this.onVoucherChanged,
    required this.onNoteChanged,
  });

  // HÀM HỖ TRỢ TÍNH GIÁ GIẢM TỪ CHUỖI VOUCHER
  double _getDiscountAmount() {
    if (voucherCode.isEmpty) return 0.0;
    try {
      return double.parse(voucherCode.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!state.isSelectionMode) ...[
              _buildVoucherRow(context),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: OrderNoteField(
                  initialValue: shipperNote,
                  onChanged: onNoteChanged,
                ),
              ),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
            ],
            state.isSelectionMode ? _buildDeleteButton(context) : _buildCheckoutRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherRow(BuildContext context) {
    return InkWell(
      onTap: () => _showVoucherDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.confirmation_num_outlined, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text("Voucher của shop", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(voucherCode.isEmpty ? "Chọn hoặc nhập mã" : voucherCode, 
              style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: Colors.blue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: state.selectedItemIds.isEmpty ? Colors.grey : Colors.red,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: state.selectedItemIds.isEmpty ? null : () => context.read<CartBloc>().add(DeleteSelectedItemsEvent()),
      child: Text("XÓA ${state.selectedItemIds.length} MÓN ĐÃ CHỌN", 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildCheckoutRow(BuildContext context) {
    final double discount = _getDiscountAmount();
    final double finalPrice = state.totalPrice - discount;

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (discount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tạm tính:", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(CurrencyFormatter.format(state.totalPrice), style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Giảm giá:", style: TextStyle(color: Colors.green, fontSize: 11)),
                    Text("-${CurrencyFormatter.format(discount)}", style: const TextStyle(color: Colors.green, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
              ],
              const Text("Tổng cộng", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
              AnimatedPriceText(
                begin: 0, 
                end: discount > 0 ? finalPrice : state.totalPrice, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final bool isLoggedIn = authState.status == AuthStatus.authenticated || authState.status == AuthStatus.admin;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () {
                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng đăng nhập để thanh toán!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                      )
                    );
                    return;
                  }
                  
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      items: state.items,
                      totalPrice: state.totalPrice,
                      voucherCode: voucherCode,
                      shipperNote: shipperNote,
                    )
                  ));
                },
                child: const Text("THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showVoucherDialog(BuildContext context) {
    final textController = TextEditingController(text: voucherCode);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập mã Voucher", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(controller: textController, decoration: const InputDecoration(hintText: "Mã giảm giá...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          TextButton(
            onPressed: () {
              onVoucherChanged(textController.text);
              Navigator.pop(context);
            }, 
            child: const Text("ÁP DỤNG")
          ),
        ],
      ),
    );
  }
}
