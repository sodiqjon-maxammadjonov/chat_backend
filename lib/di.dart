import 'package:chat_app_backend/services/database_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'api/auth_api.dart';
import 'config/env.dart';
import 'core/security/hash.dart';
import 'core/server/shelf_server.dart';

final locator = GetIt.instance;
final _log = Logger('DependencyInjection');

Future<void> init(Env env) async {
  _log.info('Bog\'liqliklarni ro\'yxatdan o\'tkazish boshlandi...');

  // --- CORE & CONFIG ---
  locator.registerSingleton<Env>(env);
  _log.info('-> Env (konfiguratsiya) ro\'yxatdan o\'tdi.');



  locator.registerSingletonAsync<PostgreSQLConnection>(() async {
    _log.info('PostgreSQLConnection ulanishi ochilmoqda...');

    final connection = PostgreSQLConnection(
      env.dbHost,
      env.dbPort,
      env.dbName,
      username: env.dbUser,
      password: env.dbPassword,
      timeZone: 'UTC',
      useSSL: false,
    );

    try {
      await connection.open();
      _log.info('✅ PostgreSQLConnection ulanishi muvaffaqiyatli ochildi!');
      return connection;
    } catch(e, stackTrace) {
      _log.severe('❌ PostgreSQLConnection ochishda xatolik:', e, stackTrace);
      await connection.close();
      rethrow;
    }
  });

  await locator.isReady<PostgreSQLConnection>();

  locator.registerLazySingleton<DatabaseService>(
        () => DatabaseService(locator<PostgreSQLConnection>()),
  );

  locator.registerLazySingleton<HashService>(() => HashService());

  _log.info('-> DatabaseService ro\'yxatdan o\'tdi.');
  _log.info('-> HashService ro\'yxatdan o\'tdi.');
  locator.registerLazySingleton<ShelfServer>(
        () => ShelfServer(
      env: locator<Env>(),
      apiRouters: [],
    ),
  );
  _log.info('-> ShelfServer ro\'yxatdan o\'tdi.');
  locator.registerLazySingleton<AuthApi>(
        () => AuthApi(locator()),
  );
  _log.info('-> API\'lar (AuthApi) ro\'yxatdan o\'tdi.');


  // --- 6. ASOSIY SERVER ---
  locator.registerLazySingleton<ShelfServer>(
        () => ShelfServer(
      env: locator(),
      // DI'dan AuthApi'ni olib, uning routerini serverga beramiz
      apiRouters: [
        locator<AuthApi>().router,
      ],
    ),
  );
  _log.info('-> Asosiy server (ShelfServer) ro\'yxatdan o\'tdi.');

  _log.info('✅ Barcha bog\'liqliklar muvaffaqiyatli ro\'yxatdan o\'tkazildi!');
}