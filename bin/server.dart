// bin/server.dart (Cloud Run uchun moslashtirilgan versiya)

import 'dart:io';

import 'package:chat_app_backend/services/database_service.dart';
import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/di.dart' as di;
import 'package:logging/logging.dart';

Future<Map<String, String>> loadEnvMap() async {
  final envPath = '.env'; // Relative path
  final envFile = File(envPath);
  final envMap = <String, String>{};

  if (!envFile.existsSync()) {
    print('⚠️  .env fayli topilmadi, environment variables ishlatiladi');

    // Environment variables'dan olish
    final envVars = Platform.environment;
    return envVars;
  }

  final lines = await envFile.readAsLines();

  for (final line in lines) {
    if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts.first.trim();
      final value = parts.sublist(1).join('=').trim();

      var finalValue = value;
      if (finalValue.startsWith('"') && finalValue.endsWith('"') ||
          finalValue.startsWith("'") && finalValue.endsWith("'")) {
        finalValue = finalValue.substring(1, finalValue.length - 1);
      }
      envMap[key] = finalValue;
    }
  }

  // Environment variables bilan birlashtirish (env vars prioritet)
  final envVars = Platform.environment;
  envMap.addAll(envVars);

  return envMap;
}

Future<void> main() async {
  print('🚀 Server boshlash jarayoni...');

  try {
    final envVariables = await loadEnvMap();
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