import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';

class ProductLocalDataSource {
  static Database? _database;

  /// 🔥 Lấy database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// 🔥 Khởi tạo database
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'products.db');

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
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  /// 🔥 Gọi trong main() để init trước
  Future<void> init() async {
    await database;
  }

  /// 🔥 Lấy tất cả sản phẩm
  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final result = await db.query('products');

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  /// 🔥 Lấy sản phẩm theo ID
  Future<ProductModel?> getProductById(String id) async {
    final db = await database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return ProductModel.fromMap(result.first);
    }

    return null;
  }

  /// 🔥 Thêm sản phẩm
  Future<void> addProduct(ProductModel product) async {
    final db = await database;

    print("ADDING PRODUCT: ${product.name}");

    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final all = await db.query('products');
    print("TOTAL PRODUCTS IN DB: ${all.length}");
  }

  /// 🔥 Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    final db = await database;

    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}