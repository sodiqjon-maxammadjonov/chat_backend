// bin/server.dart (Migratsiya logikasi bilan to'ldirilgan versiya)

import 'dart:io';

// --- YANGI IMPORTLAR ---
import 'package:chat_app_backend/services/database_service.dart';
// Bu importlarni o'zgartirmang, ular shundoq ham bor edi
import 'package:chat_app_backend/config/env.dart';
import 'package:chat_app_backend/core/server/shelf_server.dart';
import 'package:chat_app_backend/di.dart' as di;
import 'package:logging/logging.dart';

// Bu funksiya o'zgarishsiz qoladi
Future<Map<String, String>> _loadEnvMap() async {
  final envPath = r'D:\testing\chat_app_backend\.env';
  final envFile = File(envPath);
  final envMap = <String, String>{};

  if (!envFile.existsSync()) {
    throw FileSystemException('KRITIK XATO: .env fayli topilmadi!', envPath);
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
  return envMap;
}

Future<void> main() async {
  try {
    final envVariables = await _loadEnvMap();
    print('✅ .env fayli qo\'lda o\'qilib, Mapga yuklandi.');

    final appEnv = Env.fromEnv(variables: envVariables);
    print('✅ Konfiguratsiya muvaffaqiyatli yuklandi.');

    Logger.root.level = appEnv.logLevel;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}');
      if (record.error != null) print('   Error: ${record.error}');
    });

    final _log = Logger('Server');
    _log.info('Logger muvaffaqiyatli sozlandi. Log darajasi: ${appEnv.logLevel.name}');

    // Dependency Injection'ni ishga tushiramiz
    await di.init(appEnv);
    _log.info('Bog\'liqliklar (Dependency Injection) muvaffaqiyatli o\'rnatildi.');

    // --- MIGRATSIYA QISMINI QO'SHAMIZ ---
    // 1. Dependency Injection'dan DatabaseService namunasini olamiz
    _log.info('Ma\'lumotlar ombori migratsiyasini tekshirish boshlandi...');
    final dbService = di.locator<DatabaseService>();

    // 2. Dastlabki migratsiyani bajarish funksiyasini chaqiramiz
    await dbService.runInitialMigration();
    // ------------------------------------

    // Endi serverni ishga tushiramiz
    final server = di.locator<ShelfServer>();
    await server.start();
    _log.info('🚀🚀🚀 Server ${appEnv.host}:${appEnv.port} manzilida ishga tushdi! 🚀🚀🚀');

  } catch (e, stackTrace) {
    print('❌❌❌ SERVERNI ISHGA TUSHIRISHDA KRITIK XATOLIK: ❌❌❌');
    print(e);
    if (stackTrace != null) print('Stack Trace: \n$stackTrace');
  }
}