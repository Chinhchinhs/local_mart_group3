import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartDatabaseHelper {
  // Tạo Singleton để đảm bảo toàn app chỉ có 1 kết nối Database
  static final CartDatabaseHelper instance = CartDatabaseHelper._init();
  static Database? _database;

  CartDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_mart_cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Tìm đường dẫn an toàn trên điện thoại để lưu file
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Mở database, nếu chưa có thì gọi hàm _createDB để tạo bảng
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Kẻ bảng cartItems với các cột tương ứng
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