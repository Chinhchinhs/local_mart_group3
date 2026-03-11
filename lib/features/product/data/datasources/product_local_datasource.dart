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
    final path = join(await getDatabasesPath(), 'local_mart_final.db'); // ĐỔI TÊN LẦN CUỐI CHO CHUẨN

    return await openDatabase(
      path,
      version: 1, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT,
            price REAL,
            description TEXT,
            imageUrl TEXT,
            sideDishes TEXT,
            isOutOfStock INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE best_sellers(
            id TEXT PRIMARY KEY,
            name TEXT,
            price REAL,
            description TEXT,
            imageUrl TEXT,
            sideDishes TEXT,
            isOutOfStock INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE out_of_stock_ids(
            id TEXT PRIMARY KEY
          )
        ''');
      },
    );
  }

  Future<void> init() async {
    await database;
  }

  Future<void> toggleOutOfStock(String id) async {
    final db = await database;
    // Cập nhật cả 2 nơi: Bảng ID riêng và trực tiếp trong bảng products (nếu có)
    final List<Map<String, dynamic>> maps = await db.query('out_of_stock_ids', where: 'id = ?', whereArgs: [id]);
    
    int newValue = 0;
    if (maps.isNotEmpty) {
      await db.delete('out_of_stock_ids', where: 'id = ?', whereArgs: [id]);
      newValue = 0;
    } else {
      await db.insert('out_of_stock_ids', {'id': id});
      newValue = 1;
    }

    // Cập nhật trạng thái trực tiếp vào bảng món ăn nhà làm
    await db.update('products', {'isOutOfStock': newValue}, where: 'id = ?', whereArgs: [id]);
    await db.update('best_sellers', {'isOutOfStock': newValue}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getOutOfStockIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('out_of_stock_ids');
    return List.generate(maps.length, (i) => maps[i]['id'] as String);
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
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
    // Đảm bảo toMap() đã bao gồm trường isOutOfStock
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    await db.delete('best_sellers', where: 'id = ?', whereArgs: [id]);
    await db.delete('out_of_stock_ids', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductModel>> getBestSellers() async {
    final db = await database;
    final result = await db.query('best_sellers');
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<void> toggleBestSeller(ProductModel product, bool isAdd) async {
    final db = await database;
    if (isAdd) {
      await db.insert('best_sellers', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete('best_sellers', where: 'id = ?', whereArgs: [product.id]);
    }
  }
}
