import 'dart:io';
import 'package:logging/logging.dart';

class Env {
  final String host;
  final int port;
  final Level logLevel;
  final String dbHost;
  final int dbPort;
  final String dbUser;
  final String dbPassword;
  final String dbName;
  final int dbPoolSize;
  final String jwtSecret;
  final String jwtIssuer;
  final Duration jwtExpiration;
  final Duration passwordResetTokenExpiration;
  final int usernameChangeCooldownDays;
  final String smtpHost;
  final int smtpPort;
  final String smtpUsername;
  final String smtpPassword;
  final String emailFrom;

  Env({
    required this.host,
    required this.port,
    required this.logLevel,
    required this.dbHost,
    required this.dbPort,
    required this.dbUser,
    required this.dbPassword,
    required this.dbName,
    required this.dbPoolSize,
    required this.jwtSecret,
    required this.jwtIssuer,
    required this.jwtExpiration,
    required this.passwordResetTokenExpiration,
    required this.usernameChangeCooldownDays,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUsername,
    required this.smtpPassword,
    required this.emailFrom,
  });

  static Map<String, String> _loadEnvFile() {
    final envVars = <String, String>{};

    // Platform environment variables ni qo'shamiz
    envVars.addAll(Platform.environment);

    // .env faylini o'qishga harakat qilamiz
    final envFile = File('.env');
    if (envFile.existsSync()) {
      try {
        final content = envFile.readAsStringSync();
        final lines = content.split('\n');

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) {
            continue; // Bo'sh satrlar va kommentlarni o'tkazib yuboramiz
          }

          final parts = trimmed.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            envVars[key] = value;
          }
        }
        print('✅ .env fayli muvaffaqiyatli yuklandi (${envFile.absolute.path})');
      } catch (e) {
        print('⚠️  .env faylini o\'qishda xatolik: $e');
      }
    } else {
      print('⚠️  .env fayli topilmadi: ${envFile.absolute.path}');
    }

    return envVars;
  }

  factory Env.fromEnv({Map<String, String>? variables}) {
    final env = variables ?? _loadEnvFile();

    String _getRequired(String key) {
      final value = env[key];
      if (value == null || value.isEmpty) {
        print('❌ Mavjud environment variables (DB bilan boshlanuvchilar):');
        env.keys.where((k) => k.startsWith('DB_')).forEach((k) {
          print('  $k: ${env[k]}');
        });
        throw StateError('KRITIK XATO: "$key" o\'zgaruvchisi topilmadi yoki bo\'sh!');
      }
      return value;
    }

    String _getOptional(String key, String defaultValue) => env[key] ?? defaultValue;

    int _parseInt(String key, String value) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        throw StateError('KRITIK XATO: "$key" qiymatini ("$value") songa o\'girib bo\'lmadi.');
      }
      return parsed;
    }

    Level _getLogLevel(String levelStr) {
      switch (levelStr.toUpperCase()) {
        case 'ALL':
          return Level.ALL;
        case 'FINEST':
          return Level.FINEST;
        case 'FINER':
          return Level.FINER;
        case 'FINE':
          return Level.FINE;
        case 'CONFIG':
          return Level.CONFIG;
        case 'INFO':
          return Level.INFO;
        case 'WARNING':
          return Level.WARNING;
        case 'SEVERE':
          return Level.SEVERE;
        case 'SHOUT':
          return Level.SHOUT;
        case 'OFF':
          return Level.OFF;
        default:
          return Level.INFO;
      }
    }

    return Env(
      host: _getOptional('HOST', '0.0.0.0'),
      port: _parseInt('PORT', _getOptional('PORT', '8080')),
      logLevel: _getLogLevel(_getOptional('LOG_LEVEL', 'INFO')),
      dbHost: _getRequired('DB_HOST'),
      dbPort: _parseInt('DB_PORT', _getRequired('DB_PORT')),
      dbUser: _getRequired('DB_USER'),
      dbPassword: _getRequired('DB_PASSWORD'),
      dbName: _getRequired('DB_NAME'),
      dbPoolSize: _parseInt('DB_POOL_SIZE', _getRequired('DB_POOL_SIZE')),
      jwtSecret: _getRequired('JWT_SECRET'),
      jwtIssuer: _getRequired('JWT_ISSUER'),
      jwtExpiration: Duration(minutes: _parseInt('JWT_EXPIRATION_MINUTES', _getRequired('JWT_EXPIRATION_MINUTES'))),
      passwordResetTokenExpiration: Duration(minutes: _parseInt('PASSWORD_RESET_TOKEN_EXPIRATION_MINUTES', _getRequired('PASSWORD_RESET_TOKEN_EXPIRATION_MINUTES'))),
      usernameChangeCooldownDays: _parseInt('USERNAME_CHANGE_COOLDOWN_DAYS', _getRequired('USERNAME_CHANGE_COOLDOWN_DAYS')),
      smtpHost: _getRequired('SMTP_HOST'),
      smtpPort: _parseInt('SMTP_PORT', _getRequired('SMTP_PORT')),
      smtpUsername: _getRequired('SMTP_USERNAME'),
      smtpPassword: _getRequired('SMTP_PASSWORD'),
      emailFrom: _getRequired('EMAIL_FROM'),
    );
  }
}