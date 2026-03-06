import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/cart_screen.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late List<Map<String, dynamic>> selectedSideDishes;
  final noteController = TextEditingController(); // Controller cho Ghi chú

  @override
  void initState() {
    super.initState();
    selectedSideDishes = widget.product.sideDishes.map((dish) {
      return {
        "id": dish.id,
        "name": dish.name,
        "price": dish.price,
        "selected": false
      };
    }).toList();
  }

  double get sideDishesTotal => selectedSideDishes
      .where((e) => e["selected"] == true)
      .fold(0.0, (sum, e) => sum + e["price"]);

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.product.price + sideDishesTotal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text("${state.items.length}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // Tránh đè lên BottomSheet
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.product.id,
              child: Image.file(
                File(widget.product.imageUrl),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 100, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        CurrencyFormatter.format(widget.product.price),
                        style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Mô tả món ăn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product.description, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                  
                  // PHẦN MÓN PHỤ
                  if (selectedSideDishes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text("Món ăn kèm (Side dishes)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedSideDishes.length,
                      itemBuilder: (context, index) {
                        final dish = selectedSideDishes[index];
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: Colors.orange,
                          title: Text(dish["name"]),
                          subtitle: Text("+ ${CurrencyFormatter.format(dish["price"])}", style: const TextStyle(color: Colors.orange)),
                          value: dish["selected"],
                          onChanged: (val) {
                            setState(() {
                              dish["selected"] = val;
                            });
                          },
                        );
                      },
                    ),
                  ],

                  // PHẦN GHI CHÚ CHO QUÁN
                  const SizedBox(height: 30),
                  const Text("Ghi chú cho quán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "VD: Không ăn hành, cho ít cay...",
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tổng thanh toán", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(CurrencyFormatter.format(totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // 1. Lấy danh sách món phụ đã chọn
                String dishNames = selectedSideDishes
                    .where((e) => e["selected"] == true)
                    .map((e) => e["name"])
                    .join(", ");
                
                // 2. Lấy ghi chú của khách
                String note = noteController.text.trim();
                
                // 3. Xây dựng tên hiển thị mới (Tên món + Món phụ + Ghi chú)
                String displayName = widget.product.name;
                if (dishNames.isNotEmpty) displayName += " ($dishNames)";
                if (note.isNotEmpty) displayName += "\n📝 Ghi chú: $note";
                
                final cartItem = CartItemEntity(
                  // ID duy nhất để tránh gộp các món có ghi chú khác nhau
                  id: widget.product.id + DateTime.now().millisecondsSinceEpoch.toString(),
                  name: displayName,
                  price: totalPrice,
                  imageUrl: widget.product.imageUrl,
                );
                
                context.read<CartBloc>().add(AddItemEvent(cartItem));
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm vào giỏ hàng!"), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                );
              },
              child: const Text("THÊM VÀO GIỎ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
