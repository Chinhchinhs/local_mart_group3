import '../entities/cart_item_entity.dart';

// UseCase: Quy trình nghiệp vụ thêm một món đồ vào giỏ
class AddToCartUseCase {
  // Tạm thời UseCase snày ẽ nhận danh sách giỏ hiện tại và món mới,
  // sau đó trả về danh sách mới đã được cập nhật.
  List<CartItemEntity> execute(List<CartItemEntity> currentCart, CartItemEntity newItem) {

    // Kiểm tra xem món này đã có trong giỏ chưa
    final index = currentCart.indexWhere((item) => item.id == newItem.id);

    if (index != -1) {
      // Nếu có rồi thì tăng số lượng lên
      final updatedCart = List<CartItemEntity>.from(currentCart);
      updatedCart[index] = updatedCart[index].copyWith(
        quantity: updatedCart[index].quantity + 1,
      );
      return updatedCart;
    } else {
      // Nếu chưa có thì thêm mới vào danh sách
      return [...currentCart, newItem];
    }
  }
}