// lib/core/server/shelf_server.dart

import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:chat_app_backend/config/env.dart';


class ShelfServer {
  final Env _env;
  final List<Router> _apiRouters;
  final _log = Logger('ShelfServer');

  ShelfServer({
    required Env env,
    required List<Router> apiRouters,
  }) :  _env = env,
        _apiRouters = apiRouters;

  Future<void> start() async {
    final pipeline = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware)
        .addMiddleware(_errorHandlerMiddleware);

    final authRouter = _apiRouters.isNotEmpty ? _apiRouters.first : Router();

    final mainRouter = Router()
      ..get('/health', (Request request) {
        return Response.ok(
          '{"status": "OK", "timestamp": "${DateTime.now().toUtc().toIso8601String()}"}',
          headers: {'Content-Type': 'application/json'},
        );
      })
      ..mount('/api/v1/auth', authRouter);

    final handler = pipeline.addHandler(mainRouter.call);

    final server = await shelf_io.serve(
      handler,
      _env.host,
      _env.port,
    );

    server.autoCompress = true;
    _log.info('CORS qoidasi \'*\', barcha usullar uchun faollashtirildi.');
  }

  static final Middleware _corsMiddleware = createMiddleware(
    requestHandler: (request) {
      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: _corsHeaders);
      }
      return null;
    },
    responseHandler: (response) {
      return response.change(headers: {
        ...response.headers,
        ..._corsHeaders,
      });
    },
  );

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  static Middleware _errorHandlerMiddleware = (innerHandler) {
    return (request) {
      return Future.sync(() => innerHandler(request)).catchError((error, StackTrace stackTrace) {
        // Logga yozamiz
        final _log = Logger('ErrorHandler');
        _log.severe(
          'Kutilmagan xatolik: ${request.method} ${request.requestedUri}',
          error,
          stackTrace,
        );
        // Mijozga 500 kod bilan umumiy xato xabarini qaytaramiz
        return Response.internalServerError(
          body: jsonEncode({'error': 'Internal server error occurred.'}),
          headers: {'Content-Type': 'application/json'},
        );
      });
    };
  };
}