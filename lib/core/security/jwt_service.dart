// lib/core/security/jwt_service.dart (To'g'rilangan)

import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/domain/entities/user.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logging/logging.dart';

class JwtService {
  final Env _env;
  final _log = Logger('JwtService');

  JwtService(this._env);

  // Bu metod to'g'ri, o'zgarmaydi
  String generateToken(User user) {
    final jwt = JWT(
      {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      issuer: _env.jwtIssuer,
      subject: user.id,
    );
    final token = jwt.sign(
      SecretKey(_env.jwtSecret),
      expiresIn: _env.jwtExpiration,
    );
    _log.info('Foydalanuvchi ${user.id} uchun JWT muvaffaqiyatli generatsiya qilindi.');
    return token;
  }

  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_env.jwtSecret));
      _log.finer('Token muvaffaqiyatli tekshirildi: ${jwt.payload}');
      return jwt.payload as Map<String, dynamic>;
    }
    on JWTInvalidException catch (e) {
      if (e is JWTExpiredException) {
        _log.warning('Tokenning yashash muddati tugagan.');
      } else {
        _log.warning('Token yaroqsiz (noto\'g\'ri imzo yoki format): ${e.message}');
      }
      return null;
    }
    catch (e, st) {
      _log.severe('Tokenni tekshirishda noma\'lum xatolik', e, st);
      return null;
    }
  }
}