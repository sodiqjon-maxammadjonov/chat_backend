import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/user_model.dart';
import '../middleware/auth_middleware.dart';
import '../services/auth_services.dart';

class AuthController {
  static Future<Response> register(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);

      final userReg = UserRegistration.fromJson(data);
      final result = await AuthService.register(userReg);

      return Response.ok(
        json.encode(result),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: json.encode({
          'success': false,
          'message': 'Noto\'g\'ri ma\'lumot: $e'
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  static Future<Response> login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);

      final userLogin = UserLogin.fromJson(data);
      final result = await AuthService.login(userLogin);

      return Response.ok(
        json.encode(result),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: json.encode({
          'success': false,
          'message': 'Login qilishda xatolik: $e'
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  static Future<Response> getProfile(Request request) async {
    // Check authentication
    final authResult = await AuthMiddleware.authenticate(request);
    if (!authResult['success']) {
      return Response.unauthorized(
        json.encode(authResult),
        headers: {'content-type': 'application/json'},
      );
    }

    final userId = authResult['user_id'];
    final result = await AuthService.getProfile(userId);

    return Response.ok(
      json.encode(result),
      headers: {'content-type': 'application/json'},
    );
  }

  static Future<Response> updateProfile(Request request) async {
    return Response.ok(
      json.encode({'message': 'Update profile - coming soon'}),
      headers: {'content-type': 'application/json'},
    );
  }

  static Future<Response> logout(Request request) async {
    return Response.ok(
      json.encode({
        'success': true,
        'message': 'Muvaffaqiyatli chiqildi'
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}