import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_state.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product_entity.dart';
import 'dart:io';

class AdminLockListScreen extends StatefulWidget {
  const AdminLockListScreen({super.key});

  @override
  State<AdminLockListScreen> createState() => _AdminLockListScreenState();
}

class _AdminLockListScreenState extends State<AdminLockListScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Khóa món (Hết hàng)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: "Tìm kiếm món ăn...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                suffixIcon: searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      searchController.clear();
                      setState(() => searchQuery = "");
                    })
                  : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.products.isEmpty) return const Center(child: Text("Chưa có món ăn nào"));

          // 1. CHUẨN HÓA DANH SÁCH: Sắp xếp cố định theo Tên để không bị nhảy vị trí
          List<ProductEntity> displayProducts = List.from(state.products);
          displayProducts.sort((a, b) => a.name.compareTo(b.name));
          
          // 2. LOGIC TÌM KIẾM: Ưu tiên món khớp lên đầu nhưng vẫn giữ thứ tự cố định cho các món khác
          if (searchQuery.isNotEmpty) {
            displayProducts.sort((a, b) {
              bool aMatch = a.name.toLowerCase().contains(searchQuery);
              bool bMatch = b.name.toLowerCase().contains(searchQuery);
              if (aMatch && !bMatch) return -1;
              if (!aMatch && bMatch) return 1;
              return a.name.compareTo(b.name); // Nếu cả 2 cùng khớp hoặc cùng không khớp thì xếp theo tên
            });
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              final product = displayProducts[index];
              final bool isAvailable = product.isAvailable;

              return Card(
                key: ValueKey(product.id), // Cực kỳ quan trọng để Card không bị load lại
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isAvailable ? Colors.transparent : Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: Opacity(
                          opacity: isAvailable ? 1.0 : 0.6,
                          child: Image.file(
                            File(product.imageUrl), 
                            width: 60, height: 60, 
                            fit: BoxFit.cover, 
                            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      product.name, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.black87 : Colors.grey[600],
                        decoration: isAvailable ? null : TextDecoration.lineThrough,
                      )
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isAvailable ? "Đang kinh doanh" : "Đã tạm dừng bán", 
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red, 
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        )
                      ),
                    ),
                    trailing: Switch(
                      value: isAvailable,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: (val) {
                        final updated = product.copyWith(isAvailable: val);
                        context.read<ProductBloc>().add(UpdateProductEvent(updated));
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
