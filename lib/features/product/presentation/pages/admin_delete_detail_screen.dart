import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/features/cart/presentation/bloc/cart_bloc.dart'; // THÊM IMPORT
import '../bloc/product_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';

class AdminDeleteDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const AdminDeleteDetailScreen({super.key, required this.product});

  @override
  State<AdminDeleteDetailScreen> createState() => _AdminDeleteDetailScreenState();
}

class _AdminDeleteDetailScreenState extends State<AdminDeleteDetailScreen> {
  late ProductEntity currentProduct;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
  }

  // --- HÀM ĐỒNG BỘ GIỎ HÀNG SAU KHI SỬA ---
  void _syncWithCart() {
    // Gọi Event đồng bộ hóa giỏ hàng ngay lập tức
    context.read<CartBloc>().add(SyncCartOnProductUpdateEvent(currentProduct));
  }

  void _addSideDish() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm món phụ mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên món phụ")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Giá tiền"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final newDish = SideDishEntity(
                  id: "SD_${DateTime.now().millisecondsSinceEpoch}",
                  name: nameController.text,
                  price: double.parse(priceController.text),
                );

                setState(() {
                  final newList = List<SideDishEntity>.from(currentProduct.sideDishes)..add(newDish);
                  currentProduct = currentProduct.copyWith(sideDishes: newList);
                });

                // Lưu vào SQLite Sản phẩm
                context.read<ProductBloc>().add(AddProductEvent(currentProduct));
                // Đồng bộ giỏ hàng (Mặc dù thêm món phụ không làm giảm giá, nhưng vẫn đồng bộ để logic nhất quán)
                _syncWithCart();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm món phụ thành công"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  void _deleteSideDish(int index) {
    setState(() {
      final newList = List<SideDishEntity>.from(currentProduct.sideDishes);
      newList.removeAt(index);
      currentProduct = currentProduct.copyWith(sideDishes: newList);
    });

    // 1. Cập nhật dữ liệu gốc của món ăn
    context.read<ProductBloc>().add(AddProductEvent(currentProduct));
    
    // 2. QUAN TRỌNG: Đồng bộ giỏ hàng ngay lập tức để cập nhật giá tiền cho User
    _syncWithCart();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa món phụ và cập nhật lại giỏ hàng"), backgroundColor: Colors.orange, duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý chi tiết món")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(currentProduct.imageUrl), height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(currentProduct.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(CurrencyFormatter.format(currentProduct.price), style: const TextStyle(fontSize: 18, color: Colors.orange)),
            
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("DANH SÁCH MÓN PHỤ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addSideDish,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  label: const Text("THÊM MỚI", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            if (currentProduct.sideDishes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("Món này không còn món phụ nào", style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentProduct.sideDishes.length,
                itemBuilder: (context, index) {
                  final dish = currentProduct.sideDishes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(dish.name),
                      subtitle: Text(CurrencyFormatter.format(dish.price)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteSideDish(index),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmDeleteAll(),
              icon: const Icon(Icons.delete_forever),
              label: const Text("XÓA TOÀN BỘ MÓN ĂN NÀY", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có chắc muốn xóa vĩnh viễn món '${currentProduct.name}' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(currentProduct.id));
              Navigator.pop(context); 
              Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
