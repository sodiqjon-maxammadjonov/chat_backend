import 'package:chat_backend/services/db/database_service.dart';
import 'package:chat_backend/services/hash/hash_service.dart';
import 'package:chat_backend/services/token/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:uuid/uuid.dart';
import 'package:chat_backend/bussiness_logic/auth/auth_service.dart' as app_auth;

import 'api/controller/auth/auth_controller.dart';
import 'api/middleware/auth/auth_middleware.dart';
import 'api/routes/routes.dart';
import 'core/config/config.dart';
import 'data/datasource/postgres/postgre_data_source.dart';

class Server {
  late final DatabaseService _dbService;
  late final HashService _hashService;
  late final TokenService _tokenService;
  late final PostgresAuthDataSource _authDataSource;
  late final app_auth.AuthService _authService;
  late final AuthMiddleware _authMiddleware;
  late final AuthController _authController;
  late final ApiRoutes _apiRoutes;

  void _initializeDependencies() {
    print('🔄 Bog\'liqliklar initsializatsiya qilinmoqda...');

    _dbService = DatabaseService();
    _hashService = HashService();
    _tokenService = TokenService();
    final uuid = Uuid();

    _authDataSource = PostgresAuthDataSource(_dbService);

    _authService = app_auth.AuthService(_authDataSource, _hashService, _tokenService, uuid);

    _authMiddleware = AuthMiddleware(_tokenService);
    _authController = AuthController(_authService);
    _apiRoutes = ApiRoutes(_authController, _authMiddleware);

    print('👍 Barcha bog\'liqliklar tayyor!');
  }

  Future<void> start() async {
    try {
      _initializeDependencies();
      final cascade = Cascade().add(_apiRoutes.router);
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(cascade.handler);

      final server = await shelf_io.serve(
        handler,
        '0.0.0.0',
        AppConfig.serverPort,
      );

      print('🚀 Server ${server.address.host}:${server.port} manzilida ishga tushdi!');

    } catch (e, stackTrace) {
      print('❌ Serverni ishga tushirishda xatolik: $e');
      print(stackTrace);
    }
  }

  Future<void> stop() async {
    print('👋 Server o\'chirilmoqda. Resurslar tozalanmoqda...');
    await _dbService.close();
    print('✅ Resurslar muvaffaqiyatli tozalandi.');
  }
}