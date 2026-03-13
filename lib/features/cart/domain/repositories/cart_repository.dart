import '../entities/cart_item_entity.dart';
import '../entities/order_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCart();
  Future<void> saveCart(List<CartItemEntity> cartItems);
  
  // THÊM HÀM CHO ĐƠN HÀNG
  Future<void> placeOrder(OrderEntity order);
  Future<List<OrderEntity>> getOrders(String userId, bool isAdmin);
}
