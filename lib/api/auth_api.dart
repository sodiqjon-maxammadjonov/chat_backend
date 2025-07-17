// lib/api/auth_api.dart

import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/error/failure.dart';
import '../domain/usecases/auth/register_user.dart';

class AuthApi {
  final RegisterUser _registerUser;
  final _log = Logger('AuthApi');

  AuthApi(this._registerUser);

  Router get router {
    final router = Router();

    router.post('/register', _registerHandler);

    // Kelajakda boshqa endpoint'lar qo'shiladi
    // router.post('/login', _loginHandler);

    return router;
  }

  Future<Response> _registerHandler(Request request) async {
    try {
      final requestBody = await request.readAsString();

      if (requestBody.isEmpty) {
        return _jsonResponse(400, {'error': 'Request body bo\'sh bo\'lishi mumkin emas.'});
      }

      final Map<String, dynamic> data = jsonDecode(requestBody);

      final email = data['email'] as String?;
      final username = data['username'] as String?;
      final password = data['password'] as String?;

      if (email == null || username == null || password == null) {
        return _jsonResponse(400, {'error': '"email", "username" va "password" maydonlari majburiy.'});
      }

      if(password.length < 6) {
        return _jsonResponse(400, {'error': 'Parol kamida 6 belgidan iborat bo\'lishi kerak.'});
      }

      _log.info('API: /register so\'rovi qabul qilindi. Email: $email, Username: $username');

      final params = RegisterUserParams(email: email, username: username, password: password);
      final result = await _registerUser(params);

      return result.fold(
              (failure) {
            _log.warning('Registratsiya xatoligi: ${failure.message}');
            if(failure is ValidationFailure) {
              return _jsonResponse(409, {'error': failure.message});
            }
            return _jsonResponse(500, {'error': failure.message});
          },

              (userId) {
            _log.info('API: Foydalanuvchi ($userId) muvaffaqiyatli ro\'yxatdan o\'tdi.');
            return _jsonResponse(201, {
              'message': 'Foydalanuvchi muvaffaqiyatli ro\'yxatdan o\'tdi.',
              'userId': userId,
            });
          }
      );

    } on FormatException {
      return _jsonResponse(400, {'error': 'Yuborilgan ma\'lumot JSON formatida emas.'});
    } catch (e, st) {
      _log.severe('AuthApi._registerHandler da kutilmagan xatolik!', e, st);
      return _jsonResponse(500, {'error': 'Serverda ichki xatolik yuz berdi.'});
    }
  }

  /// JSON formatida javob (Response) yaratuvchi yordamchi funksiya.
  Response _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }
}