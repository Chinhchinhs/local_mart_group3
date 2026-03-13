import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final List<SideDishEntity> selectedSideDishes;
  final String note;

  const CartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.imageUrl,
    this.selectedSideDishes = const [],
    this.note = "",
  });

  double get totalPrice {
    double sideDishesPrice = selectedSideDishes.fold(0.0, (sum, item) => sum + item.price);
    return (price + sideDishesPrice) * quantity;
  }

  // THÊM ĐỂ HỖ TRỢ LƯU ĐƠN HÀNG (DẠNG JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'note': note,
      'sideDishes': selectedSideDishes.map((x) => {'id': x.id, 'name': x.name, 'price': x.price}).toList(),
    };
  }

  factory CartItemEntity.fromMap(Map<String, dynamic> map) {
    return CartItemEntity(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
      note: map['note'] ?? "",
      selectedSideDishes: (map['sideDishes'] as List?)?.map((x) => SideDishEntity(
        id: x['id'], name: x['name'], price: x['price']
      )).toList() ?? [],
    );
  }

  CartItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    List<SideDishEntity>? selectedSideDishes,
    String? note,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      selectedSideDishes: selectedSideDishes ?? this.selectedSideDishes,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, name, price, quantity, imageUrl, selectedSideDishes, note];
}
