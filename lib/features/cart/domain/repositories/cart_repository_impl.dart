import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/cart_repository.dart';


class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItemEntity>> getCart() async {
    final models = await localDataSource.getCart();
    return models; 
  }

  @override
  Future<void> saveCart(List<CartItemEntity> cartItems) async {
    final models = cartItems.map((entity) => CartItemModel.fromEntity(entity)).toList();
    await localDataSource.saveCart(models);
  }

  @override
  Future<void> placeOrder(OrderEntity order) async {
    await localDataSource.placeOrder(order);
  }

  @override
  Future<List<OrderEntity>> getOrders(String userId, bool isAdmin) async {
    return await localDataSource.getOrders(userId, isAdmin);
  }
}
