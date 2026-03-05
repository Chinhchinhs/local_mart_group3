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
  // Danh sách các món phụ đã được chọn
  late List<Map<String, dynamic>> selectedSideDishes;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách món phụ từ dữ liệu của sản phẩm
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
                  
                  // HIỂN THỊ MÓN PHỤ NẾU CÓ
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
                  ] else ...[
                    const SizedBox(height: 24),
                    const Text("(Không có món phụ kèm theo)", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 100),
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
                String dishNames = selectedSideDishes
                    .where((e) => e["selected"] == true)
                    .map((e) => e["name"])
                    .join(", ");
                
                final cartItem = CartItemEntity(
                  id: widget.product.id + (dishNames.isNotEmpty ? "_$dishNames" : ""),
                  name: widget.product.name + (dishNames.isNotEmpty ? " ($dishNames)" : ""),
                  price: totalPrice,
                  imageUrl: widget.product.imageUrl,
                );
                
                context.read<CartBloc>().add(AddItemEvent(cartItem));
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm vào giỏ hàng!"), backgroundColor: Colors.green),
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
