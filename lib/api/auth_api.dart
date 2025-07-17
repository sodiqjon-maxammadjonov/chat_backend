// lib/api/auth_api.dart (YANGILANGAN)

import 'dart:convert';
import 'package:chat_app_backend/core/error/failure.dart';
import 'package:chat_app_backend/core/security/jwt_service.dart';
import 'package:chat_app_backend/domain/usecases/auth/login_user.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../domain/usecases/auth/register_user.dart';

class AuthApi {
  final RegisterUser _registerUser;
  final LoginUser _loginUser;
  final JwtService _jwtService;

  final _log = Logger('AuthApi');

  AuthApi(
      this._registerUser,
      this._loginUser,
      this._jwtService,
      );

  Router get router {
    final router = Router();
    router.post('/register', _registerHandler);
    router.post('/login', _loginHandler);
    return router;
  }
  Future<Response> _registerHandler(Request request) async {
    try {
      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) return _jsonResponse(400, {'error': 'Request body bo\'sh bo\'lishi mumkin emas.'});
      final Map<String, dynamic> data = jsonDecode(requestBody);
      final email = data['email'] as String?; final username = data['username'] as String?; final password = data['password'] as String?;
      if (email == null || username == null || password == null) return _jsonResponse(400, {'error': '"email", "username" va "password" maydonlari majburiy.'});
      if(password.length < 6) return _jsonResponse(400, {'error': 'Parol kamida 6 belgidan iborat bo\'lishi kerak.'});
      final params = RegisterUserParams(email: email, username: username, password: password);
      final result = await _registerUser(params);
      return result.fold(
            (failure) {
          if(failure is ValidationFailure) return _jsonResponse(409, {'error': failure.message});
          return _jsonResponse(500, {'error': failure.message});
        },
            (userId) { return _jsonResponse(201, {'message': 'Foydalanuvchi muvaffaqiyatli ro\'yxatdan o\'tdi.', 'userId': userId,}); },
      );
    } on FormatException { return _jsonResponse(400, {'error': 'Yuborilgan ma\'lumot JSON formatida emas.'});
    } catch (e, st) { _log.severe('AuthApi._registerHandler da kutilmagan xatolik!', e, st); return _jsonResponse(500, {'error': 'Serverda ichki xatolik yuz berdi.'}); }
  }
  Future<Response> _loginHandler(Request request) async {
    try {
      final requestBody = await request.readAsString();
      if(requestBody.isEmpty) return _jsonResponse(400, {'error': 'Request body bo\'sh bo\'lishi mumkin emas.'});
      final Map<String, dynamic> data = jsonDecode(requestBody);
      final login = data['login'] as String?;
      final password = data['password'] as String?;
      if(login == null || password == null) {
        return _jsonResponse(400, {'error': '"login" va "password" maydonlari majburiy.'});
      }
      _log.info('API: /login so\'rovi qabul qilindi. Login: $login');
      final params = LoginUserParams(login: login, password: password);
      final result = await _loginUser(params);
      return result.fold(
        // Chap (Left) - Xatolik holati
              (failure) {
            _log.warning('Login xatoligi: ${failure.message}');
            // AuthFailure - bu 'login yoki parol xato' degani
            if (failure is AuthFailure) {
              return _jsonResponse(401, {'error': failure.message}); // 401 Unauthorized
            }
            // Boshqa server xatoliklari
            return _jsonResponse(500, {'error': failure.message});
          },
          // O'ng (Right) - Muvaffaqiyatli holat
              (user) {
            _log.info('API: Foydalanuvchi ${user.id} muvaffaqiyatli tizimga kirdi.');

            // Foydalanuvchi uchun JWT generatsiya qilamiz
            final token = _jwtService.generateToken(user);

            // Klientga foydalanuvchi ma'lumotlari va tokenni qaytaramiz
            return _jsonResponse(200, {
              'message': 'Tizimga muvaffaqiyatli kirildi!',
              'token': token,
              'user': {
                'id': user.id,
                'username': user.username,
                'email': user.email,
              }
            });
          }
      );

    } on FormatException {
      return _jsonResponse(400, {'error': 'Yuborilgan ma\'lumot JSON formatida emas.'});
    } catch (e, st) {
      _log.severe('AuthApi._loginHandler da kutilmagan xatolik!', e, st);
      return _jsonResponse(500, {'error': 'Serverda ichki xatolik yuz berdi.'});
    }
  }

  Response _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }
}