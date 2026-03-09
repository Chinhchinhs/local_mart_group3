import 'dart:convert';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
    super.sideDishes = const [],
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    var sideDishesFromMap = <SideDishEntity>[];
    if (map['sideDishes'] != null && map['sideDishes'] is String) {
      final List<dynamic> decoded = jsonDecode(map['sideDishes']);
      sideDishesFromMap = decoded.map((e) => SideDishEntity.fromMap(e)).toList();
    }

    return ProductModel(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      description: map['description'],
      imageUrl: map['imageUrl'],
      sideDishes: sideDishesFromMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'sideDishes': jsonEncode(sideDishes.map((e) => e.toMap()).toList()),
    };
  }
}
