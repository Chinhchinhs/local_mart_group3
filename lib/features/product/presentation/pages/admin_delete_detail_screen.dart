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
  // Sử dụng một biến local để quản lý danh sách món phụ tạm thời nhằm cập nhật UI tức thì
  late ProductEntity currentProduct;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
  }

  void _deleteSideDish(int index) {
    // 1. Cập nhật giao diện ngay lập tức (Xóa món phụ khỏi danh sách hiện tại)
    setState(() {
      final newList = List<SideDishEntity>.from(currentProduct.sideDishes);
      newList.removeAt(index);
      
      currentProduct = ProductEntity(
        id: currentProduct.id,
        name: currentProduct.name,
        price: currentProduct.price,
        description: currentProduct.description,
        imageUrl: currentProduct.imageUrl,
        sideDishes: newList,
      );
    });

    // 2. Gửi lệnh cập nhật xuống Bloc (Sử dụng AddProductEvent để thay thế dữ liệu cũ trong SQLite)
    context.read<ProductBloc>().add(AddProductEvent(currentProduct));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa món phụ thành công"), backgroundColor: Colors.orange, duration: Duration(milliseconds: 500)),
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
            const Text("DANH SÁCH MÓN PHỤ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
