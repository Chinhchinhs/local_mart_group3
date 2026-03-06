import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';

class AdminActionScreen extends StatelessWidget {
  const AdminActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductScreen(),
                  ),
                );
              },
              child: const Text("Thêm sản phẩm"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(isDeleteMode: true),
                  ),
                );
              },
              child: const Text("Xóa sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }
}