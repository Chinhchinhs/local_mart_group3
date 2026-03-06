import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/presentation/widgets/product_image.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';

class EditCartItemScreen extends StatefulWidget {
  final CartItemEntity item;
  final List<SideDishEntity> allAvailableSideDishes;

  const EditCartItemScreen({
    super.key, 
    required this.item, 
    required this.allAvailableSideDishes,
  });

  @override
  State<EditCartItemScreen> createState() => _EditCartItemScreenState();
}

class _EditCartItemScreenState extends State<EditCartItemScreen> {
  late List<SideDishEntity> selectedSideDishes;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    // Copy danh sách món phụ đã chọn từ item cũ
    selectedSideDishes = List.from(widget.item.selectedSideDishes);
    noteController = TextEditingController(text: widget.item.note);
  }

  double get currentItemPrice {
    double sidePrice = selectedSideDishes.fold(0, (sum, e) => sum + e.price);
    return widget.item.price + sidePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("TÙY CHỈNH MÓN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh sản phẩm lớn
            Hero(
              tag: widget.item.id,
              child: ProductImage(imageUrl: widget.item.imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(CurrencyFormatter.formatVND(widget.item.price), 
                    style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),

                  // 2. Chọn món phụ (Checkbox)
                  const Text("MÓN PHỤ ĂN KÈM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (widget.allAvailableSideDishes.isEmpty)
                    const Text("Món này không có món phụ", style: TextStyle(color: Colors.grey))
                  else
                    ...widget.allAvailableSideDishes.map((side) {
                      final isSelected = selectedSideDishes.any((e) => e.id == side.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange.withValues(alpha: 0.05) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? Colors.orange : Colors.transparent),
                        ),
                        child: CheckboxListTile(
                          title: Text(side.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Text("+ ${CurrencyFormatter.formatVND(side.price)}"),
                          value: isSelected,
                          activeColor: Colors.orange,
                          onChanged: (val) {
                            setState(() {
                              if (val!) {
                                selectedSideDishes.add(side);
                              } else {
                                selectedSideDishes.removeWhere((e) => e.id == side.id);
                              }
                            });
                          },
                        ),
                      );
                    }),

                  const SizedBox(height: 30),

                  // 3. Nhập ghi chú
                  const Text("GHI CHÚ RIÊNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Ví dụ: Ít cay, không hành...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 100), // Khoảng trống để không bị đè bởi BottomBar
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              // GỬI EVENT CẬP NHẬT (Kèm logic tách món đã viết trong Bloc)
              context.read<CartBloc>().add(UpdateItemDetailsEvent(
                oldItemId: widget.item.id,
                newSideDishes: selectedSideDishes,
                newNote: noteController.text,
                newPrice: widget.item.price,
              ));
              Navigator.pop(context);
            },
            child: Text("CẬP NHẬT - ${CurrencyFormatter.formatVND(currentItemPrice * widget.item.quantity)}", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
