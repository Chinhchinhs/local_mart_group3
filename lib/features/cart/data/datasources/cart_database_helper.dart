import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartDatabaseHelper {
  static final CartDatabaseHelper instance = CartDatabaseHelper._init();
  static Database? _database;

  CartDatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError("SQLite không hỗ trợ Web.");
    if (_database != null) return _database!;
    _database = await _initDB('local_mart_cart_v3.db'); // NÂNG LÊN V3 ĐỂ THÊM CỘT VOUCHER/NOTE
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE cartItems (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      imageUrl TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE orders (
      orderId TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      itemsJson TEXT NOT NULL,
      totalPrice REAL NOT NULL,
      orderDate TEXT NOT NULL,
      voucherCode TEXT,
      shipperNote TEXT
    )
    ''');
  }
}
