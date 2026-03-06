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
    final path = join(await getDatabasesPath(), 'products.db');

    return await openDatabase(
      path,
      version: 4, 
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('DROP TABLE IF EXISTS products');
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
        }
      },
    );
  }

  Future<void> init() async {
    await database;
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  // BỔ SUNG LẠI HÀM NÀY ĐỂ HẾT LỖI BUILD
  Future<ProductModel?> getProductById(String id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return ProductModel.fromMap(result.first);
    return null;
  }

  Future<void> addProduct(ProductModel product) async {
    final db = await database;
    final data = product.toMap();
    
    print("--- [SQLITE] ĐANG LƯU MÓN: ${product.name} ---");

    await db.insert(
      'products', 
      data, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
    
    print("--- [SQLITE] LƯU THÀNH CÔNG ---");
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
