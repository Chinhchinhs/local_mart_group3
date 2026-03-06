import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart'; // Đã sửa đường dẫn import đúng

class CartItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final List<SideDishEntity> selectedSideDishes; // Món phụ đã chọn
  final String note; // Ghi chú của khách

  const CartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.imageUrl,
    this.selectedSideDishes = const [],
    this.note = "",
  });

  // Tính tổng giá (Giá gốc + Tổng giá món phụ) * Số lượng
  double get totalPrice {
    double sideDishesPrice = selectedSideDishes.fold(0.0, (sum, item) => sum + item.price);
    return (price + sideDishesPrice) * quantity;
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
