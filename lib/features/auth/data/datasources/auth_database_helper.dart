import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthDatabaseHelper {
  static final AuthDatabaseHelper instance = AuthDatabaseHelper._init();
  static Database? _database;

  AuthDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_mart_auth.db');
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
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      fullName TEXT NOT NULL
    )
    ''');
  }
}
