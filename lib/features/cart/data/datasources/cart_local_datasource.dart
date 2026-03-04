import '../models/cart_item_model.dart';
import 'cart_database_helper.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> cartItems);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final CartDatabaseHelper dbHelper;

  CartLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<CartItemModel>> getCart() async {
    final db = await dbHelper.database;
    // Đọc toàn bộ dữ liệu trong bảng cartItems
    final maps = await db.query('cartItems');

    // Chuyển đổi các dòng dữ liệu (Map) thành Model để app hiểu được
    if (maps.isNotEmpty) {
      return maps.map((map) => CartItemModel.fromMap(map)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> saveCart(List<CartItemModel> cartItems) async {
    final db = await dbHelper.database;

    // Quét sạch bảng cũ
    await db.delete('cartItems');

    // Nhét toàn bộ giỏ hàng mới vào lại (Dùng batch để chạy nhiều lệnh insert cùng lúc cho mượt)
    final batch = db.batch();
    for (var item in cartItems) {
      batch.insert('cartItems', item.toMap());
    }
    await batch.commit();
  }
}