import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../services/token/token_service.dart';

class AuthMiddleware {
  final TokenService _tokenService;

  AuthMiddleware(this._tokenService);

  Middleware call() {
    return (Handler innerHandler) {
      return (Request request) {
        final authHeader = request.headers['authorization'];

        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(
              jsonEncode({'error': 'Avtorizatsiya tokeni talab qilinadi.'}));
        }

        final token = authHeader.substring(7);
        final userId = _tokenService.verifyToken(token);

        if (userId == null) {
          return Response.unauthorized(
              jsonEncode({'error': 'Token yaroqsiz yoki muddati o\'tgan.'}));
        }

        final updatedRequest = request.change(context: {'userId': userId});
        return innerHandler(updatedRequest);
      };
    };
  }
}
