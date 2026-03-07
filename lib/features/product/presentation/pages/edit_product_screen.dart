import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/product_bloc.dart';
import '../../domain/entities/product_entity.dart';

class EditProductScreen extends StatefulWidget {
  final ProductEntity product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descCtrl;
  late List<SideDishEntity> sideDishes;
  
  final sideDishNameCtrl = TextEditingController();
  final sideDishPriceCtrl = TextEditingController();

  File? selectedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product.name);
    priceCtrl = TextEditingController(text: widget.product.price.toInt().toString());
    descCtrl = TextEditingController(text: widget.product.description);
    sideDishes = List.from(widget.product.sideDishes);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => selectedImage = File(pickedFile.path));
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
      appBar: AppBar(title: const Text("Chỉnh sửa món ăn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                child: selectedImage != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(selectedImage!, fit: BoxFit.cover))
                  : ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(widget.product.imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 50))),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên món")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giá (VND)")),
            TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Mô tả")),
            
            const SizedBox(height: 30),
            const Text("THÊM MÓN PHỤ MỚI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            Row(
              children: [
                Expanded(child: TextField(controller: sideDishNameCtrl, decoration: const InputDecoration(labelText: "Tên món phụ"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: sideDishPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giá món phụ"))),
                IconButton(onPressed: _addSideDish, icon: const Icon(Icons.add_circle, color: Colors.orange, size: 30)),
              ],
            ),

            const SizedBox(height: 20),
            const Text("DANH SÁCH MÓN PHỤ HIỆN TẠI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 10),
            ...sideDishes.map((dish) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(dish.name),
                subtitle: Text("${dish.price.toInt()} VND"),
                trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => sideDishes.remove(dish))),
              ),
            )).toList(),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final updatedProduct = widget.product.copyWith(
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? widget.product.price,
                  description: descCtrl.text,
                  imageUrl: selectedImage?.path ?? widget.product.imageUrl,
                  sideDishes: sideDishes,
                );
                context.read<ProductBloc>().add(UpdateProductEvent(updatedProduct));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật món ăn thành công!"), backgroundColor: Colors.green));
              },
              child: const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
