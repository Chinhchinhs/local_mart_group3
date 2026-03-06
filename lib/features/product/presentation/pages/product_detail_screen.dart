import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/cart_screen.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late List<SideDishEntity> selectedSideDishes;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedSideDishes = [];
  }

  double get sideDishesTotal => selectedSideDishes.fold(0.0, (sum, e) => sum + e.price);

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.product.id,
              child: ProductImage(imageUrl: widget.product.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                      Text(CurrencyFormatter.formatVND(widget.product.price), 
                        style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Mô tả món ăn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product.description, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                  
                  if (widget.product.sideDishes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text("Món ăn kèm (Side dishes)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.product.sideDishes.length,
                      itemBuilder: (context, index) {
                        final dish = widget.product.sideDishes[index];
                        final isSelected = selectedSideDishes.any((e) => e.id == dish.id);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: Colors.orange,
                          title: Text(dish.name),
                          subtitle: Text("+ ${CurrencyFormatter.formatVND(dish.price)}", style: const TextStyle(color: Colors.orange)),
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val!) {
                                selectedSideDishes.add(dish);
                              } else {
                                selectedSideDishes.removeWhere((e) => e.id == dish.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 30),
                  const Text("Ghi chú cho quán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "VD: Không ăn hành, cho ít cay...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tổng cộng", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(CurrencyFormatter.formatVND(totalPrice), 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
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
                  // KHÔNG CỘNG DỒN VÀO TÊN NỮA -> GỬI ĐÚNG TRƯỜNG
                  final cartItem = CartItemEntity(
                    id: widget.product.id, // Dùng ID gốc để Bloc tự gộp nếu trùng Topping/Note
                    name: widget.product.name,
                    price: widget.product.price,
                    imageUrl: widget.product.imageUrl,
                    selectedSideDishes: List.from(selectedSideDishes),
                    note: noteController.text.trim(),
                    quantity: 1,
                  );
                  
                  context.read<CartBloc>().add(AddItemEvent(cartItem));
                  Navigator.pop(context);
                },
                child: const Text("THÊM VÀO GIỎ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
