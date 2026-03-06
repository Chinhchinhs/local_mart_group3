import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_database_helper.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDatabaseHelper dbHelper;

  CartRepositoryImpl(this.dbHelper);

  @override
  Future<List<CartItemEntity>> getCart() async {
    final db = await dbHelper.database;
    // Lấy dữ liệu từ bảng cartItems
    final List<Map<String, dynamic>> maps = await db.query('cartItems');
    
    // Biến đổi từ Map (SQLite) sang danh sách các Entity
    return maps.map((map) => CartItemModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveCart(List<CartItemEntity> items) async {
    final db = await dbHelper.database;
    
    // Cách làm sạch nhất: Xóa hết bảng cũ rồi lưu đè bảng mới
    await db.delete('cartItems');
    
    for (var item in items) {
      await db.insert(
        'cartItems',
        CartItemModel.fromEntity(item).toMap(),
      );
    }
  }
}
