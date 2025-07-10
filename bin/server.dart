import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';
import '../lib/routes/auth_routes.dart';
import '../lib/services/database_service.dart';

void main() async {
  // Load environment variables
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Initialize database
  await DatabaseService.initialize();

  // Create router
  final router = Router();

  // Add auth routes
  router.mount('/api/auth/', AuthRoutes().router);

  // Health check
  router.get('/health', (Request request) {
    return Response.ok('{"status": "healthy", "timestamp": "${DateTime.now().toIso8601String()}"}');
  });

  // Create handler pipeline
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router);

  // Start server
  final port = int.parse(env['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);

  print('🚀 Server running on port ${server.port}');
  print('📱 Chat Backend API ready!');
}