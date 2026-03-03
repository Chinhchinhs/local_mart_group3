import 'package:equatable/equatable.dart';

// Bản thiết kế cho 1 món hàng nằm trong giỏ
class CartItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  const CartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1, // khi thêm vào giỏ là 1 món
    required this.imageUrl,
  });

  // copyWith tạo ra một món hàng mới dựa trên món cũ (ví dụ khi tăng số lượng lên 2)
  CartItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Equatable dùng cái này để so sánh.
  // Nếu số lượng (quantity) thay đổi, nó sẽ báo cho Bloc biết để vẽ lại màn hình.
  @override
  List<Object?> get props => [id, name, price, quantity, imageUrl];
}