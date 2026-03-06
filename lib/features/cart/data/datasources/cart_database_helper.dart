import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartDatabaseHelper {
  static final CartDatabaseHelper instance = CartDatabaseHelper._init();
  static Database? _database;

  CartDatabaseHelper._init();

  Future<Database> get database async {
    // Nếu chạy trên Web, chúng ta không thể dùng sqflite
    if (kIsWeb) {
      throw UnsupportedError("SQLite không hỗ trợ trên trình duyệt Web. Vui lòng chạy trên Android.");
    }

    if (_database != null) return _database!;
    _database = await _initDB('local_mart_cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
  }
}
