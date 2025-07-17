// bin/server.dart (Cloud Run uchun moslashtirilgan versiya)

import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:chat_app_backend/services/database_service.dart';
import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/di.dart' as di;
import 'package:logging/logging.dart';

Future<void> main() async {
  print('🚀 Server boshlash jarayoni...');

  try {
    final dotenv = DotEnv(); // includePlatformEnvironment: false
    dotenv.load();

    final envVariables = {
      ...Platform.environment,
      ...dotenv.map,
    };

    print('✅ Environment variables yuklandi.');

    final appEnv = Env.fromEnv(variables: envVariables);
    print('✅ Konfiguratsiya muvaffaqiyatli yuklandi.');
    print('📊 Port: ${appEnv.port}, Host: ${appEnv.host}');

    Logger.root.level = appEnv.logLevel;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}');
      if (record.error != null) print('   Error: ${record.error}');
    });

    final log = Logger('Server');
    log.info('Logger muvaffaqiyatli sozlandi. Log darajasi: ${appEnv.logLevel.name}');

    // Dependency Injection'ni ishga tushiramiz
    await di.init(appEnv);
    log.info('Bog\'liqliklar (Dependency Injection) muvaffaqiyatli o\'rnatildi.');

    // Database migratsiyasi
    log.info('Ma\'lumotlar ombori migratsiyasini tekshirish boshlandi...');
    try {
      final dbService = di.locator<DatabaseService>();
      await dbService.runInitialMigration();
      log.info('✅ Database migratsiyasi muvaffaqiyatli bajarildi.');
    } catch (e) {
      log.warning('⚠️ Database migratsiyasida xatolik: $e');
      // Database'siz ham server ishga tushsin
    }

    // Serverni ishga tushirish
    final server = di.locator<ShelfServer>();
    await server.start();
    log.info('🚀🚀🚀 Server ${appEnv.host}:${appEnv.port} manzilida ishga tushdi! 🚀🚀🚀');

  } catch (e, stackTrace) {
    print('❌❌❌ SERVERNI ISHGA TUSHIRISHDA KRITIK XATOLIK: ❌❌❌');
    print('Error: $e');
    print('Stack Trace: $stackTrace');
    exit(1); // Container'ni to'xtatish
  }
}