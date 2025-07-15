// lib/core/config/env.dart (Map QABUL QILADIGAN YAKUNIY VERSIYA)

import 'dart:io';
import 'package:logging/logging.dart';

/// Ilova uchun barcha muhit o'zgaruvchilarini saqlaydigan
/// va ularga xavfsiz kirishni ta'minlaydigan klass.
class Env {
  // --- ILOVA SOZLAMALARI ---
  final String host;
  final int port;
  final Level logLevel;

  // --- MA'LUMOTLAR OMBORI (POSTGRESQL) ---
  final String dbHost;
  final int dbPort;
  final String dbUser;
  final String dbPassword;
  final String dbName;
  final int dbPoolSize;

  // --- JWT TOKEN ---
  final String jwtSecret;
  final String jwtIssuer;
  final Duration jwtExpiration;

  // --- XAVFSIZLIK VA BOSHQA SOZLAMALAR ---
  final Duration passwordResetTokenExpiration;
  final int usernameChangeCooldownDays;

  // --- EMAIL SERVISI (SMTP) ---
  final String smtpHost;
  final int smtpPort;
  final String smtpUsername;
  final String smtpPassword;
  final String emailFrom;

  // Klassning barcha maydonlarini talab qiluvchi konstruktor
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

  /// `.env` faylidan kelgan `Map` yoki `Platform.environment` yordamida [Env] namunasini yaratadi.
  ///
  /// Agar [variables] parametri berilsa, qiymatlarni o'sha Map'dan o'qiydi.
  /// Aks holda, tizimdagi [Platform.environment]'dan foydalanadi.
  factory Env.fromEnv({Map<String, String>? variables}) {
    // Agar tashqaridan `Map` berilmagan bo'lsa, tizimdagi `environment`'dan foydalanamiz.
    // Bu standart holat (masalan, Docker yoki Cloud'da ishlatish uchun).
    final env = variables ?? Platform.environment;

    // --- Yordamchi Funksiyalar ---

    /// Majburiy o'zgaruvchini o'qiydi. Agar topilmasa yoki bo'sh bo'lsa, xato beradi.
    String _getRequiredEnv(String key) {
      final value = env[key];
      if (value == null || value.isEmpty) {
        throw StateError(
            'KRITIK XATO: ".env" faylida "$key" o\'zgaruvchisi topilmadi yoki bo\'sh qoldirilgan!');
      }
      return value;
    }

    /// Ixtiyoriy o'zgaruvchini o'qiydi. Agar topilmasa, berilgan standart qiymatni qaytaradi.
    String _getOptionalEnv(String key, String defaultValue) {
      return env[key] ?? defaultValue;
    }

    /// String qiymatni butun songa (int) o'giradi. Agar imkonsiz bo'lsa, xato beradi.
    int _parseInt(String key, String value) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        throw StateError(
            'KRITIK XATO: ".env" faylidagi "$key" o\'zgaruvchisini ("$value") butun songa (int) o\'girib bo\'lmadi.');
      }
      return parsed;
    }

    /// String qiymatdan `logging` paketi uchun `Level` ob'ektini yaratadi.
    Level _getLogLevel(String levelStr) {
      switch (levelStr.toUpperCase()) {
        case 'ALL': return Level.ALL;
        case 'INFO': return Level.INFO;
        case 'WARNING': return Level.WARNING;
        case 'SEVERE': return Level.SEVERE;
        case 'OFF': return Level.OFF;
        default: return Level.INFO;
      }
    }

    // Qiymatlarni o'qib, klass namunasini yaratib, qaytaramiz.
    return Env(
      host: _getOptionalEnv('HOST', '0.0.0.0'),
      port: _parseInt('PORT', _getOptionalEnv('PORT', '8080')),
      logLevel: _getLogLevel(_getOptionalEnv('LOG_LEVEL', 'INFO')),

      dbHost: _getRequiredEnv('DB_HOST'),
      dbPort: _parseInt('DB_PORT', _getRequiredEnv('DB_PORT')),
      dbUser: _getRequiredEnv('DB_USER'),
      dbPassword: _getRequiredEnv('DB_PASSWORD'),
      dbName: _getRequiredEnv('DB_NAME'),
      dbPoolSize: _parseInt('DB_POOL_SIZE', _getRequiredEnv('DB_POOL_SIZE')),

      jwtSecret: _getRequiredEnv('JWT_SECRET'),
      jwtIssuer: _getRequiredEnv('JWT_ISSUER'),
      jwtExpiration: Duration(minutes: _parseInt('JWT_EXPIRATION_MINUTES', _getRequiredEnv('JWT_EXPIRATION_MINUTES'))),

      passwordResetTokenExpiration: Duration(minutes: _parseInt('PASSWORD_RESET_TOKEN_EXPIRATION_MINUTES', _getRequiredEnv('PASSWORD_RESET_TOKEN_EXPIRATION_MINUTES'))),
      usernameChangeCooldownDays: _parseInt('USERNAME_CHANGE_COOLDOWN_DAYS', _getRequiredEnv('USERNAME_CHANGE_COOLDOWN_DAYS')),

      smtpHost: _getRequiredEnv('SMTP_HOST'),
      smtpPort: _parseInt('SMTP_PORT', _getRequiredEnv('SMTP_PORT')),
      smtpUsername: _getRequiredEnv('SMTP_USERNAME'),
      smtpPassword: _getRequiredEnv('SMTP_PASSWORD'),
      emailFrom: _getRequiredEnv('EMAIL_FROM'),
    );
  }
}