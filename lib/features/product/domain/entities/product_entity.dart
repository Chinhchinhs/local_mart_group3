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
      // Ép kiểu num sang double để tránh lỗi int/double trong SQLite/JSON
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
  final List<SideDishEntity> sideDishes;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.sideDishes = const [],
  });

  @override
  List<Object?> get props => [id, name, price, description, imageUrl, sideDishes];
}
