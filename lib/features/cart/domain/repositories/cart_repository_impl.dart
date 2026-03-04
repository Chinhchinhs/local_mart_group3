import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';


class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItemEntity>> getCart() async {
    // Nhờ Thợ đào vàng lấy đồ từ SQLite lên
    final models = await localDataSource.getCart();
    return models; // Vì Model đã kế thừa Entity nên trả về trực tiếp được luôn
  }

  @override
  Future<void> saveCart(List<CartItemEntity> cartItems) async {
    // Ép Entity về dạng Model để SQLite hiểu được
    final models = cartItems.map((entity) => CartItemModel.fromEntity(entity)).toList();
    // Giao cho Thợ đào vàng cất đi
    await localDataSource.saveCart(models);
  }
}