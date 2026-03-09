import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  
  // SideDishEntity nằm trong product_entity.dart đã được import ở trên
  List<SideDishEntity> sideDishes = [];
  final sideDishNameCtrl = TextEditingController();
  final sideDishPriceCtrl = TextEditingController();

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addSideDish() {
    if (sideDishNameCtrl.text.isNotEmpty && sideDishPriceCtrl.text.isNotEmpty) {
      setState(() {
        sideDishes.add(SideDishEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: sideDishNameCtrl.text,
          price: double.tryParse(sideDishPriceCtrl.text) ?? 0.0,
        ));
        sideDishNameCtrl.clear();
        sideDishPriceCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm món mới")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên món ăn")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giá (VND)")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả")),
            const SizedBox(height: 20),

            const Text("Hình ảnh món ăn", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add_a_photo, size: 40), Text("Nhấn để chọn ảnh")],
                      ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Thêm món phụ kèm theo", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: TextField(controller: sideDishNameCtrl, decoration: const InputDecoration(labelText: "Tên món phụ"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: sideDishPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giá món phụ"))),
                IconButton(onPressed: _addSideDish, icon: const Icon(Icons.add_circle, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: sideDishes.map((dish) => Chip(
                label: Text("${dish.name} (+${dish.price.toInt()}đ)"),
                onDeleted: () => setState(() => sideDishes.remove(dish)),
              )).toList(),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đủ tên, giá và ảnh")));
                  return;
                }

                final product = ProductEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0.0,
                  description: descCtrl.text,
                  imageUrl: selectedImage!.path,
                  sideDishes: List.from(sideDishes),
                );

                context.read<ProductBloc>().add(AddProductEvent(product));
                Navigator.pop(context);
              },
              child: const Text("LƯU MÓN ĂN", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
