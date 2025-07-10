import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../utils/jwt_helper.dart';

class AuthMiddleware {
  static Future<Map<String, dynamic>> authenticate(Request request) async {
    final authHeader = request.headers['authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return {
        'success': false,
        'message': 'Authorization header yo\'q'
      };
    }

    final token = authHeader.substring(7);
    final userId = JwtHelper.getUserIdFromToken(token);

    if (userId == null) {
      return {
        'success': false,
        'message': 'Noto\'g\'ri yoki muddati o\'tgan token'
      };
    }

    return {
      'success': true,
      'user_id': userId
    };
  }
}