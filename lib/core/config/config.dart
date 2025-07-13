import 'package:envied/envied.dart';
part 'config.g.dart';

@Envied(path: '.env')
abstract class AppConfig {
  @EnviedField(varName: 'SERVER_PORT', defaultValue: '8080')
  static const int serverPort = _AppConfig.serverPort;

  @EnviedField(varName: 'DB_HOST')
  static const String dbHost = _AppConfig.dbHost;
  @EnviedField(varName: 'DB_PORT')
  static const int dbPort = _AppConfig.dbPort;
  @EnviedField(varName: 'DB_USER')
  static const String dbUser = _AppConfig.dbUser;
  @EnviedField(varName: 'DB_PASSWORD')
  static const String dbPassword = _AppConfig.dbPassword;
  @EnviedField(varName: 'DB_NAME')
  static const String dbName = _AppConfig.dbName;

  @EnviedField(varName: 'JWT_SECRET_KEY')
  static const String jwtSecretKey = _AppConfig.jwtSecretKey;
}