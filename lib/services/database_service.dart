// lib/services/database_service.dart

import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  final PostgreSQLConnection _connection;
  final _log = Logger('DatabaseService');

  DatabaseService(this._connection);

  /// Dastur ishga tushganda ma'lumotlar ombori jadvallarini yaratish uchun
  /// tekshiruv va "migratsiya"ni amalga oshiradi.
  Future<void> runInitialMigration() async {
    _log.info('Ma\'lumotlar ombori migratsiyasi tekshirilmoqda...');

    try {
      // "users" jadvali mavjudligini tekshiramiz.
      // `to_regclass` funksiyasi jadval mavjud bo'lmasa, `null` qaytaradi.
      final tableExistsResult = await _connection.query(
        "SELECT to_regclass('public.users') as name;",
      );

      // Agar natijada qaytgan `name` ustuni `null` bo'lsa, demak jadval yo'q
      if (tableExistsResult.first.toColumnMap()['name'] == null) {
        _log.warning(
            '"users" jadvali topilmadi. Dastlabki migratsiya boshlanmoqda...');
        await _createTables();
        _log.info('✅ Dastlabki migratsiya muvaffaqiyatli yakunlandi!');
      } else {
        _log.info('Jadvallar mavjud. Migratsiyaga hojat yo\'q.');
      }
    } on PostgreSQLException catch (e, st) {
      _log.severe('Migratsiya vaqtida DB xatoligi:', e, st);
      rethrow; // Xatoni yuqoriga uzatamiz.
    } catch (e, st) {
      _log.severe('Migratsiya vaqtida kutilmagan xatolik:', e, st);
      rethrow;
    }
  }

  /// Loyiha uchun kerak bo'ladigan barcha jadvallarni yaratuvchi SQL skript
  Future<void> _createTables() async {
    // `EXTENSION "uuid-ossp"` Postgre'da UUID'larni generatsiya qilish uchun kerak.
    // Odatda Superuser ruxsati bilan bir marta yoziladi. Agar xato bersa, DB'ga kirib
    // o'zingiz bir marta `CREATE EXTENSION "uuid-ossp";` deb yozib qo'yishingiz mumkin.
    final script = '''
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE user_profiles (
        user_id UUID PRIMARY KEY,
        phone VARCHAR(30),
        device_info JSONB, 
        last_online TIMESTAMP WITH TIME ZONE,
        is_online BOOLEAN NOT NULL DEFAULT FALSE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );

      CREATE TABLE password_resets (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255) NOT NULL,
        token VARCHAR(6) NOT NULL, -- 6 xonali raqamli kod
        expires_at TIMESTAMP WITH TIME ZONE NOT NULL
      );

      CREATE TABLE user_sessions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL,
        token TEXT NOT NULL, -- JWT Token
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
      
      CREATE TABLE username_changes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL,
        old_username VARCHAR(50) NOT NULL,
        new_username VARCHAR(50) NOT NULL,
        changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
      
      CREATE TABLE login_history (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL,
        ip_address VARCHAR(45),
        device_info JSONB,
        login_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );

    CREATE OR REPLACE FUNCTION update_updated_at_column()
  RETURNS TRIGGER AS '
  BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
  END;
  ' LANGUAGE plpgsql;

  CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
    ''';

    await _connection.transaction((ctx) async {
      await ctx.execute(script);
    });
  }
}
