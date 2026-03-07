import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _deleteSideDish(int index) {
    setState(() {
      final newList = List<SideDishEntity>.from(currentProduct.sideDishes);
      newList.removeAt(index);
      
      currentProduct = currentProduct.copyWith(sideDishes: newList);
    });

    context.read<ProductBloc>().add(AddProductEvent(currentProduct));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa món phụ thành công"), backgroundColor: Colors.orange, duration: Duration(milliseconds: 500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Quản lý chi tiết món", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(currentProduct.imageUrl), height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 220, color: Colors.grey[100], child: const Icon(Icons.fastfood, size: 80, color: Colors.grey))),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(currentProduct.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                Text(CurrencyFormatter.format(currentProduct.price), style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            
            // BỔ SUNG PHẦN MÔ TẢ MÓN ĂN
            const Text("Mô tả món ăn:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              currentProduct.description.isNotEmpty ? currentProduct.description : "(Không có mô tả)",
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
            
            const Divider(height: 40, thickness: 1),
            const Text("DANH SÁCH MÓN PHỤ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
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
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                    child: ListTile(
                      title: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(CurrencyFormatter.format(dish.price), style: const TextStyle(color: Colors.orange, fontSize: 12)),
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
                elevation: 0,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận xóa món"),
        content: Text("Bạn có chắc muốn xóa vĩnh viễn món '${currentProduct.name}' khỏi thực đơn không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(currentProduct.id));
              Navigator.pop(context); 
              Navigator.pop(context);
            },
            child: const Text("Xóa vĩnh viễn", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
