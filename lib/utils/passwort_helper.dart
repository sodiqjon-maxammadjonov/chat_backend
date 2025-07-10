import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordHelper {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password + 'salt_key_2024');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String hashedPassword) {
    final hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }
}