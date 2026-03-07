import 'dart:convert';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
    super.category = "General",
    super.sideDishes = const [],
    super.isAvailable = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    // 1. Giải mã danh sách món phụ an toàn
    var sideDishesFromMap = <SideDishEntity>[];
    try {
      if (map['sideDishes'] != null && map['sideDishes'] is String && (map['sideDishes'] as String).isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(map['sideDishes']);
        sideDishesFromMap = decoded.map((e) => SideDishEntity.fromMap(e)).toList();
      }
    } catch (e) {
      print("Lỗi giải mã sideDishes: $e");
    }

    // 2. Chuyển đổi dữ liệu từ SQLite sang Model với các giá trị mặc định an toàn
    return ProductModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? "Không tên",
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      description: map['description']?.toString() ?? "",
      imageUrl: map['imageUrl']?.toString() ?? "",
      category: map['category']?.toString() ?? "General",
      sideDishes: sideDishesFromMap,
      isAvailable: map['isAvailable'] == 1, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'sideDishes': jsonEncode(sideDishes.map((e) => e.toMap()).toList()),
      'isAvailable': isAvailable ? 1 : 0,
    };
  }
}
