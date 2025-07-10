import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtHelper {
  static final _secretKey = Platform.environment['JWT_SECRET'] ?? 'your-super-secret-key-2024';

  static String generateToken(String userId) {
    final jwt = JWT({
      'user_id': userId,
      'issued_at': DateTime.now().millisecondsSinceEpoch,
      'expires_at': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
    });

    return jwt.sign(SecretKey(_secretKey), expiresIn: Duration(days: 7));
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  static String? getUserIdFromToken(String token) {
    final payload = verifyToken(token);
    return payload?['user_id'];
  }
}