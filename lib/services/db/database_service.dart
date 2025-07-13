import 'package:postgres/postgres.dart';
import '../../core/config/config.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  factory DatabaseService() {
    return _instance;
  }

  Connection? _connection;

  Future<Connection> get connection async {
    if (_connection == null || _connection!.isOpen == false) {
      print('🗄️  Ma\'lumotlar bazasiga yangi ulanish yaratilmoqda...');

      final endpoint = Endpoint(
        host: AppConfig.dbHost,
        port: AppConfig.dbPort,
        database: AppConfig.dbName,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
      );

      final settings = ConnectionSettings(
        sslMode: SslMode.disable,
      );

      _connection = await Connection.open(endpoint, settings: settings);

      print('✅  Ma\'lumotlar bazasiga muvaffaqiyatli ulanildi!');
    }

    return _connection!;
  }

  /// Server o'chganda yoki kerak bo'lganda ulanishni yopish
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
    print('🔴  Ma\'lumotlar bazasi bilan aloqa uzildi.');
  }
}