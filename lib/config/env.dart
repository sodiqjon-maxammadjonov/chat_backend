// lib/core/config/env.dart (YAKUNIY, UNIVERSAL VERSIYA)

import 'dart:io';
import 'package:logging/logging.dart';

class Env {
  // --- Bu qism o'zgarmas ---
  final String host; final int port; final Level logLevel;
  final String dbHost; final int dbPort; final String dbUser;
  final String dbPassword; final String dbName; final int dbPoolSize;
  final String jwtSecret; final String jwtIssuer; final Duration jwtExpiration;
  final Duration passwordResetTokenExpiration; final int usernameChangeCooldownDays;
  final String smtpHost; final int smtpPort; final String smtpUsername;
  final String smtpPassword; final String emailFrom;

  Env({
    required this.host, required this.port, required this.logLevel, required this.dbHost,
    required this.dbPort, required this.dbUser, required this.dbPassword, required this.dbName,
    required this.dbPoolSize, required this.jwtSecret, required this.jwtIssuer, required this.jwtExpiration,
    required this.passwordResetTokenExpiration, required this.usernameChangeCooldownDays,
    required this.smtpHost, required this.smtpPort, required this.smtpUsername, required this.smtpPassword,
    required this.emailFrom,
  });

  factory Env.fromEnv({Map<String, String>? variables}) {
    final env = variables ?? Platform.environment;

    String _getRequired(String key) {
      final value = env[key];
      if (value == null || value.isEmpty) {
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
      //... log darajasini belgilash kodi ...
      return Level.INFO; // qisqartirish uchun
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