// lib/di.dart (TO'G'RI VERSIYASI)

import 'package:chat_app_backend/api/auth_api.dart';
import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/security/hash.dart';
import 'package:chat_app_backend/core/security/jwt_service.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/data/repositories/auth_repository_impl.dart';
import 'package:chat_app_backend/domain/repositories/auth_repository.dart';
import 'package:chat_app_backend/domain/usecases/auth/login_user.dart';
import 'package:chat_app_backend/domain/usecases/auth/register_user.dart';
import 'package:chat_app_backend/services/database_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart'; // V3 versiyadan to'g'ri import

final locator = GetIt.instance;
final _log = Logger('DependencyInjection');

Future<void> init(Env env) async {
  _log.info('Bog\'liqliklarni ro\'yxatdan o\'tkazish boshlandi...');
  locator.registerSingleton<Env>(env);

  // Connection'ni ro'yxatdan o'tkazish
  locator.registerSingletonAsync<Connection>(() async {
    final bool isProduction = env.dbHost.startsWith('/');

    final endpoint = Endpoint(
      host: env.dbHost,
      port: isProduction ? 5432 : env.dbPort, // Port productionda muhim emas
      database: env.dbName,
      username: env.dbUser,
      password: env.dbPassword,
      isUnixSocket: isProduction,
    );
    try {
      final connection = await Connection.open(endpoint, settings: ConnectionSettings(timeZone: 'UTC'));
      return connection;
    } catch(e, st) {
      _log.severe('❌ PostgreSQL ulanishda xatolik:', e, st);
      rethrow;
    }
  });

  await locator.isReady<Connection>();

  locator.registerLazySingleton<DatabaseService>(() => DatabaseService(locator()));
  locator.registerLazySingleton<HashService>(() => HashService());
  locator.registerLazySingleton<JwtService>(() => JwtService(locator()));
  _log.info('-> Tashqi servislar (DB, Hash, JWT) ro\'yxatdan o\'tdi.');

  locator.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(connection: locator(), hashService: locator()),
  );
  _log.info('-> Repozitoriylar (AuthRepository) ro\'yxatdan o\'tdi.');

  locator.registerLazySingleton<RegisterUser>(() => RegisterUser(locator()));
  locator.registerLazySingleton<LoginUser>(() => LoginUser(locator()));
  _log.info('-> Use case\'lar (RegisterUser, LoginUser) ro\'yxatdan o\'tdi.');

  locator.registerLazySingleton<AuthApi>(
        () => AuthApi(locator<RegisterUser>(), locator<LoginUser>(), locator<JwtService>()),
  );
  _log.info('-> API\'lar (AuthApi) ro\'yxatdan o\'tdi.');

  locator.registerLazySingleton<ShelfServer>(
        () => ShelfServer(
      env: locator(),
      apiRouters: [locator<AuthApi>().router],
    ),
  );
  _log.info('-> Asosiy server (ShelfServer) ro\'yxatdan o\'tdi.');
  _log.info('✅ Barcha bog\'liqliklar muvaffaqiyatli ro\'yxatdan o\'tkazildi!');
}