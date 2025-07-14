// lib/services/token_service.dart (Asinxron AppConfig'ga moslashtirilgan)

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../core/config/config.dart';

class TokenService {

  Future<String> generateToken({required String userId}) async {
    final jwt = JWT({'id': userId, 'issuer': 'ChatAppBackend'});

    final secret = await AppConfig.jwtSecretKey;

    return jwt.sign(SecretKey(secret), expiresIn: Duration(days: 7));
  }
  Future<String?> verifyToken(String token) async {
    try {
      final secret = await AppConfig.jwtSecretKey;

      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload['id'] as String;
    } on JWTException {
      return null;
    }
  }
}