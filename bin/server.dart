import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/di.dart' as di;
import 'package:chat_app_backend/services/database_service.dart';
import 'package:logging/logging.dart';
import 'dart:io';

Future<void> main() async {
  try {
    print('🚀 Server boshlash jarayoni...');

    final appEnv = Env.fromEnv();
    print('✅ Konfiguratsiya muvaffaqiyatli yuklandi.');
    print('📊 Port: ${appEnv.port}, Host: ${appEnv.host}');
    print('🗄️ Database: ${appEnv.dbHost}:${appEnv.dbPort}/${appEnv.dbName}');

    // Logger
    Logger.root.level = appEnv.logLevel;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}');
    });
    final log = Logger('Server');

    await di.init(appEnv);
    log.info('✅ Bog\'liqliklar (Dependency Injection) muvaffaqiyatli o\'rnatildi.');

    final dbService = di.locator<DatabaseService>();
    await dbService.runInitialMigration();
    log.info('✅ Database migratsiyasi muvaffaqiyatli bajarildi.');

    final server = di.locator<ShelfServer>();
    await server.start();
    log.info('🚀🚀🚀 Server ${appEnv.host}:${appEnv.port} manzilida ishga tushdi! 🚀🚀🚀');
  } catch (e, stackTrace) {
    print('❌❌❌ SERVERNI ISHGA TUSHIRISHDA KRITIK XATOLIK: ❌❌❌');
    print('Error: $e');
    print('StackTrace: $stackTrace');
    exit(1);
  }
}