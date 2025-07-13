import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../bussiness_logic/auth/auth_service.dart';
import '../../../core/failure/auth_failure.dart';
import '../../../data/models/user/login_request_model.dart';
import '../../../data/models/user/register_request_model.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Response _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final model = RegisterRequestModel.fromJson(jsonDecode(body));

      final result = await _authService.register(model);

      return result.fold(
        (failure) {
          if (failure is AuthFailure)
            return _jsonResponse(409, {'error': failure.message}); // Conflict
          return _jsonResponse(500, {'error': failure.message});
        },
        (authResponse) => _jsonResponse(201, {
          // Created
          'message': 'Muvaffaqiyatli ro\'yxatdan o\'tdingiz',
          'user': authResponse.user.toJson(),
          'token': authResponse.token,
        }),
      );
    } catch (e) {
      return _jsonResponse(400, {
        'error':
            'Noto\'g\'ri formatdagi so\'rov. Kerakli maydonlarni tekshiring: username, email, password'
      });
    }
  }

  Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final model = LoginRequestModel.fromJson(jsonDecode(body));

      final result = await _authService.login(model);

      return result.fold(
        (failure) {
          if (failure is AuthFailure)
            return _jsonResponse(
                401, {'error': failure.message}); // Unauthorized
          return _jsonResponse(500, {'error': failure.message});
        },
        (authResponse) => _jsonResponse(200, {
          'message': 'Tizimga muvaffaqiyatli kirdingiz',
          'user': authResponse.user.toJson(),
          'token': authResponse.token,
        }),
      );
    } catch (e) {
      return _jsonResponse(400, {
        'error':
            'Noto\'g\'ri formatdagi so\'rov. Kerakli maydonlarni tekshiring: email, password'
      });
    }
  }

  Future<Response> getProfile(Request request) async {
    final userId = request.context['userId'] as String;
    final result = await _authService.getProfile(userId);

    return result.fold((failure) {
      if (failure is AuthFailure)
        return _jsonResponse(404, {'error': failure.message}); // Not Found
      return _jsonResponse(500, {'error': failure.message});
    }, (user) => _jsonResponse(200, user.toJson()));
  }
}
