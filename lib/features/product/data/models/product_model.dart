import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
  });

  // Chuyển từ dòng dữ liệu của SQLite (Map) sang Model
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      // Dùng (as num).toDouble() là "chân ái" tuyệt đối cho SQLite
      price: (map['price'] as num).toDouble(),
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }

  // Hàm này giúp đóng gói dữ liệu để lưu xuống SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}