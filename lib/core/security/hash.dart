// lib/core/security/hash.dart

import 'package:bcrypt/bcrypt.dart';

class HashService {

  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool verifyPassword(String plainPassword, String hashedPassword) {
    try {
      return BCrypt.checkpw(plainPassword, hashedPassword);
    } catch (_) {
      return false;
    }
  }
}