import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';

class ProductLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'products_v7.db'); // Dùng file mới hoàn toàn để tránh lỗi cũ

    return await openDatabase(
      path,
      version: 1, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT,
            imageUrl TEXT,
            sideDishes TEXT,
            category TEXT,
            isAvailable INTEGER DEFAULT 1
          )
        ''');
      },
    );
  }

  Future<void> init() async {
    await database;
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    print("--- [SQLITE] ĐÃ TẢI ${result.length} MÓN ĂN ---");
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return ProductModel.fromMap(result.first);
    return null;
  }

  Future<void> addProduct(ProductModel product) async {
    final db = await database;
    final row = product.toMap();
    print("--- [SQLITE] ĐANG LƯU MÓN: ${product.name} ---");
    await db.insert(
      'products', 
      row, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
    print("--- [SQLITE] LƯU THÀNH CÔNG ---");
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
