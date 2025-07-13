import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../core/config/config.dart';

class TokenService {
  String generateToken({required String userId}) {
    final jwt = JWT({'id': userId, 'issuer': 'ChatAppBackend'});
    return jwt.sign(SecretKey(AppConfig.jwtSecretKey), expiresIn: Duration(days: 7));
  }
  String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(AppConfig.jwtSecretKey));
      return jwt.payload['id'] as String;
    } on JWTException {
      return null;
    }
  }
}