// lib/data/repositories/auth_repository_impl.dart (TO'G'RI VERSIYASI)

import 'package:chat_app_backend/core/error/failure.dart';
import 'package:chat_app_backend/core/security/hash.dart';
import 'package:chat_app_backend/domain/entities/user.dart';
import 'package:chat_app_backend/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Connection _connection;
  final HashService _hashService;
  final _log = Logger('AuthRepositoryImpl');

  AuthRepositoryImpl({
    required Connection connection,
    required HashService hashService,
  }) :  _connection = connection,
        _hashService = hashService;

  @override
  Future<Either<Failure, String>> register({
    required String email, required String username, required String password
  }) async {
    try {
      _log.info('Registratsiya boshlandi: email=$email, username=$username');
      final hashedPassword = _hashService.hashPassword(password);

      final result = await _connection.execute(
        Sql.named('INSERT INTO users (email, username, password_hash) VALUES (@email, @username, @password) RETURNING id'),
        parameters: { 'email': email, 'username': username, 'password': hashedPassword, },
      );

      if (result.isEmpty || result.first.isEmpty) {
        return Left(ServerFailure('Foydalanuvchini yaratishda noma\'lum server xatoligi.'));
      }
      final userId = result.first.toColumnMap()['id'] as String;
      _log.info('Yangi foydalanuvchi yaratildi: ID=$userId');

      await _createUserProfile(userId);
      return Right(userId);
    } on ServerException catch (e) {
      if (e.code == '23505') { // unique_violation
        if(e.message.contains('users_email_key')){ return Left(ValidationFailure('Bu email allaqachon ro\'yxatdan o\'tgan.')); }
        if(e.message.contains('users_username_key')){ return Left(ValidationFailure('Bu username allaqachon band.'));}
      }
      return Left(ServerFailure('Ma\'lumotlar omborida xatolik: ${e.message}'));
    } catch (e) { return Left(ServerFailure('Noma\'lum server xatoligi yuz berdi.')); }
  }


  @override
  Future<Either<Failure, User>> login({ required String login, required String password }) async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT id, email, username, password_hash FROM users WHERE email = @login OR username = @login LIMIT 1'),
        parameters: {'login': login},
      );
      if (result.isEmpty) { return Left(AuthFailure('Login yoki parol xato!')); }

      final userData = result.first.toColumnMap();
      final hashedPasswordFromDb = userData['password_hash'] as String;
      final isPasswordCorrect = _hashService.verifyPassword(password, hashedPasswordFromDb);
      if (!isPasswordCorrect) { return Left(AuthFailure('Login yoki parol xato!')); }

      return Right(User(
        id: userData['id'] as String,
        email: userData['email'] as String,
        username: userData['username'] as String,
      ));
    } on ServerException catch (e) { return Left(ServerFailure('Ma\'lumotlar omborida xatolik yuz berdi.'));
    } catch (e) { return Left(ServerFailure('Noma\'lum server xatoligi.')); }
  }

  Future<void> _createUserProfile(String userId) async {
    try {
      await _connection.execute(
        Sql.named('INSERT INTO user_profiles (user_id) VALUES (@userId)'),
        parameters: {'userId': userId},
      );
    } catch (e) { _log.severe('Foydalanuvchi ($userId) profilini yaratishda xatolik: $e'); }
  }
}