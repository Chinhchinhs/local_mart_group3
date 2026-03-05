import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_database_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatabaseHelper dbHelper;

  AuthRepositoryImpl(this.dbHelper);

  @override
  Future<UserEntity?> login(String username, String password) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return UserEntity(
        id: maps.first['id'] as String,
        username: maps.first['username'] as String,
        password: maps.first['password'] as String,
        fullName: maps.first['fullName'] as String,
      );
    }
    return null;
  }

  @override
  Future<void> register(UserEntity user) async {
    final db = await dbHelper.database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'username': user.username,
        'password': user.password,
        'fullName': user.fullName,
      },
    );
  }
}
