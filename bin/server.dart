// bin/server.dart (UNIVERSAL YECHIM: HAM LOKAL, HAM CLOUD)

import 'dart:io';

import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/di.dart' as di;
import 'package:chat_app_backend/services/database_service.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  Map<String, String>? envVariables;

  // Google Cloud Run'da ishlayotganini tekshiramiz.
  // `K_SERVICE` - bu Cloud Run avtomatik tarzda o'rnatadigan o'zgaruvchi.
  final bool isProduction = Platform.environment.containsKey('K_SERVICE');

  try {
    // Agar lokalda ishlayotgan bo'lsak (production bo'lmasa), .env faylini o'qiymiz
    if (!isProduction) {
      print('ℹ️ Lokal rejim aniqlandi. ".env" faylini o\'qishga harakat qilinmoqda...');
      envVariables = await _loadEnvFromFile(r'D:\testing\chat_app_backend\.env');
      print('✅ .env fayli qo\'lda muvaffaqiyatli o\'qildi.');
    } else {
      print('✅ Production (Cloud Run) rejimi aniqlandi. Tizim o\'zgaruvchilari ishlatiladi.');
    }

    // `Env` klassini ishga tushiramiz. Lokal bo'lsa, fayldan olingan Map bilan,
    // cloud'da bo'lsa, Platform.environment'ning o'zi bilan.
    final appEnv = Env.fromEnv(variables: envVariables);
    print('✅ Konfiguratsiya muvaffaqiyatli yuklandi.');

    // Logger sozlamalari
    Logger.root.level = appEnv.logLevel;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}');
    });
    final log = Logger('Server');

    await di.init(appEnv);
    log.info('DI muvaffaqiyatli ishga tushirildi.');

    final dbService = di.locator<DatabaseService>();
    await dbService.runInitialMigration();
    log.info('Migratsiya muvaffaqiyatli tekshirildi.');

    final server = di.locator<ShelfServer>();
    await server.start();
    log.info('🚀🚀🚀 Server ${appEnv.host}:${appEnv.port} manzilida ishga tushdi! 🚀🚀🚀');

  } catch (e, stackTrace) {
    print('❌❌❌ SERVERNI ISHGA TUSHIRISHDA KRITIK XATOLIK: ❌❌❌');
    print(e);
    print(stackTrace);
    exit(1);
  }
}


/// .env faylini qattiq belgilangan yo'ldan o'qiydigan yordamchi funksiya.
Future<Map<String, String>> _loadEnvFromFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw FileSystemException('KRITIK XATO: ".env" fayli topilmadi!', path);
  }
  final envMap = <String, String>{};
  final lines = await file.readAsLines();

  for (final line in lines) {
    if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts.first.trim();
      final value = parts.sublist(1).join('=').trim();
      envMap[key] = value;
    }
  }
  // .env'dagi qiymatlarni mavjud tizim o'zgaruvchilariga qo'shamiz
  return {...Platform.environment, ...envMap};
}