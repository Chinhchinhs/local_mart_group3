import 'package:collection/collection.dart';
import '../entities/cart_item_entity.dart';

// UseCase: Quy trình nghiệp vụ thêm một món đồ vào giỏ
class AddToCartUseCase {
  List<CartItemEntity> execute(List<CartItemEntity> currentCart, CartItemEntity newItem) {
    // Kiểm tra xem có món nào giống hệt (Tên + Món phụ + Ghi chú) đã tồn tại chưa
    final existingItemIndex = currentCart.indexWhere((item) {
      // 1. So sánh Tên sản phẩm (Thay vì ID split vì dễ bị trùng tiền tố 'static_')
      bool isSameProduct = item.name == newItem.name;
      
      // 2. So sánh danh sách món phụ
      bool isSameSideDishes = const DeepCollectionEquality.unordered().equals(
        item.selectedSideDishes, 
        newItem.selectedSideDishes
      );
      
      // 3. So sánh ghi chú
      bool isSameNote = item.note.trim() == newItem.note.trim();

      return isSameProduct && isSameSideDishes && isSameNote;
    });

    if (existingItemIndex != -1) {
      // Nếu GIỐNG HỆT mọi thứ -> Gộp số lượng
      final updatedCart = List<CartItemEntity>.from(currentCart);
      updatedCart[existingItemIndex] = updatedCart[existingItemIndex].copyWith(
        quantity: updatedCart[existingItemIndex].quantity + newItem.quantity,
      );
      return updatedCart;
    } else {
      // Nếu KHÁC -> Thêm dòng mới
      // Đảm bảo mỗi dòng trong giỏ hàng có một ID duy nhất để không bị lỗi Key trong ListView
      final itemWithUniqueId = newItem.copyWith(
        id: "${newItem.id}_${DateTime.now().millisecondsSinceEpoch}"
      );
      return [...currentCart, itemWithUniqueId];
    }
  }
}
