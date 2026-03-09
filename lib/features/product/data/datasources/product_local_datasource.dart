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
    final path = join(await getDatabasesPath(), 'products_v3.db'); // V3 để đảm bảo schema mới nhất

    return await openDatabase(
      path,
      version: 6, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT,
            price REAL,
            description TEXT,
            imageUrl TEXT,
            sideDishes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE best_sellers(
            id TEXT PRIMARY KEY,
            name TEXT,
            price REAL,
            description TEXT,
            imageUrl TEXT,
            sideDishes TEXT
          )
        ''');
      },
    );
  }

  // Thêm lại hàm init() để main.dart không bị lỗi
  Future<void> init() async {
    await database;
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
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
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
