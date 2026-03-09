import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_state.dart';
import 'edit_product_screen.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product_entity.dart';
import 'dart:io';

class AdminEditListScreen extends StatefulWidget {
  const AdminEditListScreen({super.key});

  @override
  State<AdminEditListScreen> createState() => _AdminEditListScreenState();
}

class _AdminEditListScreenState extends State<AdminEditListScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chọn món để sửa", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                hintText: "Tìm món cần sửa...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
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

          List<ProductEntity> displayProducts = List.from(state.products);
          displayProducts.sort((a, b) => a.name.compareTo(b.name));
          
          if (searchQuery.isNotEmpty) {
            displayProducts.sort((a, b) {
              bool aMatch = a.name.toLowerCase().contains(searchQuery);
              bool bMatch = b.name.toLowerCase().contains(searchQuery);
              if (aMatch && !bMatch) return -1;
              if (!aMatch && bMatch) return 1;
              return a.name.compareTo(b.name);
            });
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              final product = displayProducts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(product.imageUrl), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood)),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(CurrencyFormatter.format(product.price), style: const TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.edit, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
