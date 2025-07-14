import 'dart:io' show Platform;
import 'package:dotenv/dotenv.dart' show DotEnv;

class AppConfig {
  AppConfig._();
  static DotEnv? _env;

  static Future<DotEnv> get _dotenv async {
    if (_env == null) {
      _env = DotEnv();
      _env!.load();
    }
    return _env!;
  }


  static Future<String> get serverPort async {
    final env = await _dotenv;
    return Platform.environment['SERVER_PORT'] ?? env['SERVER_PORT'] ?? '8080';
  }

  static Future<String> get dbHost async {
    final env = await _dotenv;
    return Platform.environment['DB_HOST'] ?? env['DB_HOST'] ?? 'localhost';
  }

  static Future<String> get dbPort async {
    final env = await _dotenv;
    return Platform.environment['DB_PORT'] ?? env['DB_PORT'] ?? '5432';
  }

  static Future<String> get dbUser async {
    final env = await _dotenv;
    return Platform.environment['DB_USER'] ?? env['DB_USER'] ?? 'postgres';
  }

  static Future<String> get dbPassword async {
    final env = await _dotenv;
    return Platform.environment['DB_PASSWORD'] ?? env['DB_PASSWORD'] ?? '';
  }

  static Future<String> get dbName async {
    final env = await _dotenv;
    return Platform.environment['DB_NAME'] ?? env['DB_NAME'] ?? 'chat_db';
  }

  static Future<String> get jwtSecretKey async {
    final env = await _dotenv;
    return Platform.environment['JWT_SECRET_KEY'] ?? env['JWT_SECRET_KEY'] ?? 'default_secret';
  }
}