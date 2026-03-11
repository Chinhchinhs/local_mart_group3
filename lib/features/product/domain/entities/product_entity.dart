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
  final bool isOutOfStock; // THÊM TRƯỜNG NÀY

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.category = "General",
    this.sideDishes = const [],
    this.isOutOfStock = false, // MẶC ĐỊNH LÀ CÒN MÓN
  });

  ProductEntity copyWith({
    double? price,
    List<SideDishEntity>? sideDishes,
    bool? isOutOfStock, // THÊM VÀO COPYWITH
  }) {
    return ProductEntity(
      id: id,
      name: name,
      price: price ?? this.price,
      description: description,
      imageUrl: imageUrl,
      category: category,
      sideDishes: sideDishes ?? this.sideDishes,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
    );
  }

  @override
  List<Object?> get props => [id, name, price, description, imageUrl, category, sideDishes, isOutOfStock];
}
