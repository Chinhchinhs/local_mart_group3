import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import 'package:local_mart/features/product/presentation/widgets/product_image.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onEdit;

  const CartItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        onTap: isSelectionMode 
            ? () => context.read<CartBloc>().add(ToggleItemSelectionEvent(item.id)) 
            : onEdit,
        leading: isSelectionMode
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
            maxLines: 1, overflow: TextOverflow.ellipsis,
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
                child: Text("• ${item.selectedSideDishes.length} món kèm: ${item.selectedSideDishes.map((e) => e.name).join(', ')}", 
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
        trailing: isSelectionMode ? null : _buildQtyControl(context),
      ),
    );
  }

  Widget _buildQtyControl(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove, () => _updateQty(context, -1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          _qtyBtn(Icons.add, () => _updateQty(context, 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 16, color: Colors.orange)),
    );
  }

  void _updateQty(BuildContext context, int delta) {
    if (item.quantity + delta > 0) {
      context.read<CartBloc>().add(UpdateQuantityEvent(item.id, item.quantity + delta));
    } else {
      context.read<CartBloc>().add(RemoveItemEvent(item.id));
    }
  }
}
