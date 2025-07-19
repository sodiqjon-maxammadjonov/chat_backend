// lib/services/database_service.dart (TO'G'RI VERSIYASI)

import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  final Connection _connection;
  final _log = Logger('DatabaseService');

  DatabaseService(this._connection);

  Future<void> runInitialMigration() async {
    _log.info('Ma\'lumotlar ombori migratsiyasi tekshirilmoqda...');
    try {
      final result = await _connection.execute(Sql.named("SELECT to_regclass('public.users') AS name"));

      if (result.isEmpty || result.first.toColumnMap()['name'] == null) {
        _log.warning('"users" jadvali topilmadi. Dastlabki migratsiya boshlanmoqda...');
        await _createTables();
        _log.info('✅ Dastlabki migratsiya muvaffaqiyatli yakunlandi!');
      } else {
        _log.info('Jadvallar mavjud. Migratsiyaga hojat yo\'q.');
      }
    } on ServerException catch (e, st) {
      _log.severe('Migratsiya vaqtida DB xatoligi:', e, st);
      rethrow;
    } catch (e, st) {
      _log.severe('Migratsiya vaqtida kutilmagan xatolik:', e, st);
      rethrow;
    }
  }

  Future<void> _createTables() async {
    final script = r'''
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(50) UNIQUE NOT NULL, password_hash TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE user_profiles (
        user_id UUID PRIMARY KEY, phone VARCHAR(30), device_info JSONB, 
        last_online TIMESTAMP WITH TIME ZONE, is_online BOOLEAN NOT NULL DEFAULT FALSE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
      CREATE TABLE password_resets (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), email VARCHAR(255) NOT NULL,
        token VARCHAR(6) NOT NULL, expires_at TIMESTAMP WITH TIME ZONE NOT NULL
      );
      CREATE TABLE user_sessions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID NOT NULL,
        token TEXT NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
      CREATE TABLE username_changes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID NOT NULL,
        old_username VARCHAR(50) NOT NULL, new_username VARCHAR(50) NOT NULL,
        changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
      CREATE TABLE login_history (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID NOT NULL,
        ip_address VARCHAR(45), device_info JSONB,
        login_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
      CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
        $$ LANGUAGE 'plpgsql';
      CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''';

    await _connection.runTx((session) async {
      await session.execute(script);
    });
  }
}