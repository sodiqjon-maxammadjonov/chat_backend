import 'dart:io';
import 'package:postgres/postgres.dart';
import '../models/user_model.dart';

class DatabaseService {
  static late Connection _connection;

  static Future<void> initialize() async {
    try {
      _connection = await Connection.open(
        Endpoint(
          host: Platform.environment['DB_HOST'] ?? 'localhost',
          port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
          database: Platform.environment['DB_NAME'] ?? 'chat_db',
          username: Platform.environment['DB_USER'] ?? 'postgres',
          password: Platform.environment['DB_PASSWORD'] ?? 'password',
        ),
      );

      await _createTables();
      print('✅ Database connected successfully');
    } catch (e) {
      print('❌ Database connection failed: $e');
      rethrow;
    }
  }

  static Future<void> _createTables() async {
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR PRIMARY KEY,
        username VARCHAR UNIQUE NOT NULL,
        email VARCHAR UNIQUE NOT NULL,
        password_hash VARCHAR NOT NULL,
        profile_image VARCHAR,
        display_name VARCHAR,
        bio TEXT,
        is_online BOOLEAN DEFAULT FALSE,
        last_seen TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
      )
    ''');
  }

  static Future<void> createUser(User user, String passwordHash) async {
    await _connection.execute(
      'INSERT INTO users (id, username, email, password_hash, profile_image, display_name, bio, is_online, last_seen, created_at, updated_at) VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11)',
      parameters: [
        user.id,
        user.username,
        user.email,
        passwordHash,
        user.profileImage,
        user.displayName,
        user.bio,
        user.isOnline,
        user.lastSeen,
        user.createdAt,
        user.updatedAt,
      ],
    );
  }

  static Future<User?> getUserById(String id) async {
    final result = await _connection.execute(
      'SELECT * FROM users WHERE id = \$1',
      parameters: [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return User.fromJson({
      'id': row[0],
      'username': row[1],
      'email': row[2],
      'profile_image': row[4],
      'display_name': row[5],
      'bio': row[6],
      'is_online': row[7],
      'last_seen': row[8].toString(),
      'created_at': row[9].toString(),
      'updated_at': row[10].toString(),
    });
  }

  static Future<User?> getUserByUsernameOrEmail(String username, String email) async {
    final result = await _connection.execute(
      'SELECT * FROM users WHERE username = \$1 OR email = \$2',
      parameters: [username, email],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return User.fromJson({
      'id': row[0],
      'username': row[1],
      'email': row[2],
      'profile_image': row[4],
      'display_name': row[5],
      'bio': row[6],
      'is_online': row[7],
      'last_seen': row[8].toString(),
      'created_at': row[9].toString(),
      'updated_at': row[10].toString(),
    });
  }

  static Future<String> getUserPassword(String userId) async {
    final result = await _connection.execute(
      'SELECT password_hash FROM users WHERE id = \$1',
      parameters: [userId],
    );

    return result.first[0] as String;
  }

  static Future<void> updateUserLastSeen(String userId) async {
    await _connection.execute(
      'UPDATE users SET last_seen = \$1, is_online = TRUE WHERE id = \$2',
      parameters: [DateTime.now(), userId],
    );
  }
}