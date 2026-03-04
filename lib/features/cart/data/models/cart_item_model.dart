import '../../domain/entities/cart_item_entity.dart';

// Model này kế thừa từ Entity, nhưng có thêm khả năng biến đổi dữ liệu để nói chuyện với SQLite
class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.quantity,
    required super.imageUrl,
  });

  // Chuyển từ Lõi (Entity) sang Model
  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      imageUrl: entity.imageUrl,
    );
  }

  // Chuyển từ dòng dữ liệu của SQLite (Map) sang Model
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
    );
  }

  // Chuyển từ Model thành dòng dữ liệu (Map) để nhét vào bảng SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}