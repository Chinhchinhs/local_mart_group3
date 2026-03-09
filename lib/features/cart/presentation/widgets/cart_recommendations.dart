import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';

class CartRecommendations extends StatelessWidget {
  const CartRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
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
}
