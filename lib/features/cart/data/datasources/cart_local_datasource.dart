import '../models/cart_item_model.dart';
import '../../domain/entities/order_entity.dart'; // ĐÃ SỬA ĐƯỜNG DẪN IMPORT CHUẨN
import 'cart_database_helper.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> cartItems);
  Future<void> placeOrder(OrderEntity order);
  Future<List<OrderEntity>> getOrders(String userId, bool isAdmin);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final CartDatabaseHelper dbHelper;

  CartLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<CartItemModel>> getCart() async {
    final db = await dbHelper.database;
    final maps = await db.query('cartItems');
    return maps.isNotEmpty ? maps.map((map) => CartItemModel.fromMap(map)).toList() : [];
  }

  @override
  Future<void> saveCart(List<CartItemModel> cartItems) async {
    final db = await dbHelper.database;
    await db.delete('cartItems');
    final batch = db.batch();
    for (var item in cartItems) {
      batch.insert('cartItems', item.toMap());
    }
    await batch.commit();
  }

  @override
  Future<void> placeOrder(OrderEntity order) async {
    final db = await dbHelper.database;
    await db.insert('orders', order.toMap());
    await db.delete('cartItems');
  }

  @override
  Future<List<OrderEntity>> getOrders(String userId, bool isAdmin) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> maps;
    
    if (isAdmin) {
      maps = await db.query('orders', orderBy: 'orderDate DESC');
    } else {
      maps = await db.query('orders', where: 'userId = ?', whereArgs: [userId], orderBy: 'orderDate DESC');
    }
    
    return maps.map((e) => OrderEntity.fromMap(e)).toList();
  }
}
