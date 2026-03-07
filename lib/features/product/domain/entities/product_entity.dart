import 'package:equatable/equatable.dart';

class SideDishEntity extends Equatable {
  final String id;
  final String name;
  final double price;

  const SideDishEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price};
  }

  factory SideDishEntity.fromMap(Map<String, dynamic> map) {
    return SideDishEntity(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
    );
  }
}

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final List<SideDishEntity> sideDishes;
  final bool isAvailable; // Thêm trường này để quản lý khóa món

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.category = "General",
    this.sideDishes = const [],
    this.isAvailable = true, // Mặc định là có sẵn
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    List<SideDishEntity>? sideDishes,
    bool? isAvailable,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      sideDishes: sideDishes ?? this.sideDishes,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [id, name, price, description, imageUrl, category, sideDishes, isAvailable];
}
