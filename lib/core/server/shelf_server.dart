// lib/core/server/shelf_server.dart

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../../config/env.dart';


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
    // Pipeline - bu so'rov (request) kelgandan boshlab unga javob (response)
    // qaytargunicha bo'lgan qadamlar zanjiri (middleware'lar to'plami).
    final pipeline = const Pipeline()
    // 1. Har bir so'rov haqida log chiqaradi.
        .addMiddleware(logRequests())
    // 2. CORS (Cross-Origin Resource Sharing) uchun.
        .addMiddleware(_corsMiddleware)
    // 3. Kodda yuzaga keladigan kutilmagan xatoliklarni ushlab qolish uchun.
        .addMiddleware(_errorHandlerMiddleware);

    final mainRouter = Router();

    // Health-check uchun endpoint. Server ishlab turganini tekshirish uchun.
    mainRouter.get('/health', (Request request) {
      return Response.ok('{"status": "OK"}',
          headers: {'Content-Type': 'application/json'});
    });

    // Barcha API router'larni yagona /api/v1/ prefiksi ostiga yig'amiz.
    final apiRouter = Router();
    for (final router in _apiRouters) {
      apiRouter.mount('/', router);
    }
    mainRouter.mount('/api/v1/', apiRouter);

    // Yaratilgan pipeline'ga asosiy router'ni qo'shamiz.
    final handler = pipeline.addHandler(mainRouter);

    // Serverni `shelf_io` yordamida haqiqatdan ishga tushiramiz
    final server = await shelf_io.serve(
      handler,
      _env.host,
      _env.port,
    );

    // Javoblarni avtomatik siqishni (compression) yoqamiz
    server.autoCompress = true;
    _log.info('CORS qoidasi \'*\', barcha usullar uchun faollashtirildi.');
  }

  // --- Middlewares ---

  /// CORS uchun javobgar middleware.
  static final Middleware _corsMiddleware = createMiddleware(
    requestHandler: (request) {
      // Barcha `OPTIONS` so'rovlari CORS uchun "preflight" (dastlabki) so'rovlar hisoblanadi.
      // Ularga shunchaki OK javobini sarlavhalar bilan qaytaramiz.
      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: _corsHeaders);
      }
      return null; // Boshqa barcha so'rovlar o'zgarishsiz davom etsin.
    },
    responseHandler: (response) {
      // Serverdan chiqayotgan har bir javobga CORS sarlavhalarini qo'shamiz.
      return response.change(headers: {
        ...response.headers, // mavjud sarlavhalarni saqlab qolamiz
        ..._corsHeaders,
      });
    },
  ); // <<--- TUZATISH: "... as Handler" qismi olib tashlandi. Bu xato edi.

  static const _corsHeaders = {
    // Barcha manbalarga ruxsat (ishlab chiqish (development) uchun qulay).
    // Production'da buni aniq domeningizga o'zgartirish tavsiya etiladi (masalan: 'https://my-app.com').
    'Access-Control-Allow-Origin': '*',
    // Ruxsat etilgan HTTP usullari.
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    // Ruxsat etilgan so'rov sarlavhalari.
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  /// Xatoliklarni markazlashgan holda boshqarish uchun middleware.
  static Middleware _errorHandlerMiddleware = (innerHandler) {
    return (request) {
      // So'rovni bajarishga harakat qilamiz va xatolikni kutamiz.
      return Future.sync(() => innerHandler(request)).catchError((error, StackTrace stackTrace) {
        // Logga yozamiz
        Logger('ErrorHandler').severe(
          'Kutilmagan xatolik: ${request.method} ${request.requestedUri}',
          error,
          stackTrace,
        );
        // Mijozga 500 kod bilan umumiy xato xabarini qaytaramiz
        return Response.internalServerError(
          body: '{"error": "Internal server error"}',
          headers: {'Content-Type': 'application/json'},
        );
      });
    };
  };
}