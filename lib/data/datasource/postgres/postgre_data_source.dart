// lib/data/datasources/postgres_auth_datasource.dart

import 'package:postgres/postgres.dart';
import '../../../services/db/database_service.dart';
import '../../models/user/user_model.dart';

class PostgresAuthDataSource {
  final DatabaseService _dbService;
  PostgresAuthDataSource(this._dbService);

  Future<UsersModel?> findUserByEmail(String email) async {
    final conn = await _dbService.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM users WHERE email = @email LIMIT 1'),
      parameters: {'email': email},
    );
    if (results.isEmpty) return null;
    return UsersModel.fromMap(results.first.toColumnMap());
  }

  Future<UsersModel?> findUserById(String id) async {
    final conn = await _dbService.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM users WHERE id = @id LIMIT 1'),
      parameters: {'id': id},
    );
    if (results.isEmpty) return null;
    return UsersModel.fromMap(results.first.toColumnMap());
  }

  Future<String?> findPasswordHashByUserId(String userId) async {
    final conn = await _dbService.connection;
    final results = await conn.execute(
      Sql.named('SELECT password_hash FROM users WHERE id = @id LIMIT 1'),
      parameters: {'id': userId},
    );
    if(results.isEmpty) return null;
    return results.first.toColumnMap()['password_hash'];
  }

  Future<UsersModel> saveUser({required UsersModel user, required String passwordHash}) async {
    final conn = await _dbService.connection;
    await conn.execute(
      Sql.named('INSERT INTO users (id, username, display_name, email, password_hash, created_at) VALUES (@id, @username, @displayName, @email, @passwordHash, @createdAt)'),
      parameters: {
        'id': user.id,
        'username': user.username,
        'displayName': user.displayName,
        'email': user.email,
        'passwordHash': passwordHash,
        'createdAt': user.createdAt,
      },
    );
    return user;
  }
}