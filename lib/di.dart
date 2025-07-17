// lib/di.dart (ShelfServer dublikatsiyasi olib tashlangan versiya)

import 'package:chat_app_backend/api/auth_api.dart';
import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/security/hash.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/data/repositories/auth_repository_impl.dart';
import 'package:chat_app_backend/domain/repositories/auth_repository.dart';
import 'package:chat_app_backend/domain/usecases/auth/register_user.dart';
import 'package:chat_app_backend/services/database_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import 'core/security/jwt_service.dart';
import 'domain/usecases/auth/login_user.dart';

final locator = GetIt.instance;
final _log = Logger('DependencyInjection');

Future<void> init(Env env) async {
  _log.info('Bog\'liqliklarni ro\'yxatdan o\'tkazish boshlandi...');

  locator.registerSingleton<Env>(env);
  _log.info('-> Env (konfiguratsiya) ro\'yxatdan o\'tdi.');


  locator.registerSingletonAsync<PostgreSQLConnection>(() async {
    _log.info('PostgreSQLConnection ulanishi ochilmoqda...');
    final connection = PostgreSQLConnection(
      env.dbHost, env.dbPort, env.dbName,
      username: env.dbUser, password: env.dbPassword,
      timeZone: 'UTC', useSSL: false,
    );
    await connection.open();
    _log.info('✅ PostgreSQLConnection ulanishi muvaffaqiyatli ochildi!');
    return connection;
  });
  await locator.isReady<PostgreSQLConnection>();

  locator.registerLazySingleton<DatabaseService>(() => DatabaseService(locator()));
  locator.registerLazySingleton<HashService>(() => HashService());
  locator.registerLazySingleton<JwtService>(() => JwtService(locator()));
  _log.info('-> Tashqi servislar (DB, Hash. Jwt) ro\'yxatdan o\'tdi.');

  locator.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      connection: locator(),
      hashService: locator(),
    ),
  );
  _log.info('-> Repozitoriylar (AuthRepository) ro\'yxatdan o\'tdi.');


  // --- 4. USE CASES ---
  locator.registerLazySingleton<RegisterUser>(() => RegisterUser(locator()));
  // Biz hozircha login uchun ham yaratamiz, chunki keyingi qadamimiz shu.
  // Agar xatolik bersa, bu qatorni vaqtincha izohga olib turing.
  locator.registerLazySingleton<LoginUser>(() => LoginUser(locator()));
  _log.info('-> Use case\'lar (RegisterUser) ro\'yxatdan o\'tdi.');


  // --- 5. API'lar (HANDLER/CONTROLLER) ---
  locator.registerLazySingleton<AuthApi>(() => AuthApi(locator()));
  _log.info('-> API\'lar (AuthApi) ro\'yxatdan o\'tdi.');


  // --- 6. ASOSIY SERVER (FAQAT BIR MARTA, ENG OXIRIDA) ---
  locator.registerLazySingleton<ShelfServer>(
        () => ShelfServer(
      env: locator(),
      apiRouters: [
        locator<AuthApi>().router,
      ],
    ),
  );
  _log.info('-> Asosiy server (ShelfServer) ro\'yxatdan o\'tdi.');

  _log.info('✅ Barcha bog\'liqliklar muvaffaqiyatli ro\'yxatdan o\'tkazildi!');
}