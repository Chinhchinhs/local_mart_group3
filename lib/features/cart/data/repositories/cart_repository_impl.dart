import 'dart:convert';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_database_helper.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDatabaseHelper dbHelper;

  CartRepositoryImpl(this.dbHelper);

  @override
  Future<List<CartItemEntity>> getCart() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cartItems');
    return maps.map((map) => CartItemModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveCart(List<CartItemEntity> items) async {
    final db = await dbHelper.database;
    await db.delete('cartItems');
    for (var item in items) {
      await db.insert('cartItems', CartItemModel.fromEntity(item).toMap());
    }
  }

  // --- THỰC THI HÀM ĐẶT HÀNG ---
  @override
  Future<void> placeOrder(OrderEntity order) async {
    final db = await dbHelper.database;
    await db.insert('orders', order.toMap());
    // Xóa giỏ hàng sau khi đặt thành công
    await db.delete('cartItems');
  }

  // --- THỰC THI HÀM LẤY LỊCH SỬ (PHÂN QUYỀN) ---
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
