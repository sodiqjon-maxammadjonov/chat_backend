import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import '../../core/error/failure.dart';
import '../../core/security/hash.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final PostgreSQLConnection _connection;
  final HashService _hashService;
  final _log = Logger('AuthRepositoryImpl');

  AuthRepositoryImpl({
    required PostgreSQLConnection connection,
    required HashService hashService,
  }) :  _connection = connection,
        _hashService = hashService;

  @override
  Future<Either<Failure, String>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      _log.info('Registratsiya so\'rovi qabul qilindi: email=$email, username=$username');

      // 1. Parolni heshlaymiz
      final hashedPassword = _hashService.hashPassword(password);

      final result = await _connection.query(
        'INSERT INTO users (email, username, password_hash) VALUES (@email, @username, @password) RETURNING id',
        substitutionValues: {
          'email': email,
          'username': username,
          'password': hashedPassword,
        },
      );

      if (result.isEmpty || result.first.isEmpty) {
        _log.severe('DBga yozishdan so\'ng `id` qaytarilmadi.');
        return Left(ServerFailure('Foydalanuvchi yaratilmadi, server xatoligi.'));
      }

      final userId = result.first.toColumnMap()['id'] as String;

      _log.info('Yangi foydalanuvchi muvaffaqiyatli yaratildi: id=$userId');
      await _createUserProfile(userId);

      return Right(userId);

    } on PostgreSQLException catch (e, st) {
      _log.warning('Registratsiya vaqtida DB xatoligi yuz berdi', e, st);
      if (e.code == '23505') {
        if(e.message!.contains('users_email_key')){
          return Left(ValidationFailure('Bu email allaqachon ro\'yxatdan o\'tgan.'));
        }
        if(e.message!.contains('users_username_key')){
          return Left(ValidationFailure('Bu username allaqachon band.'));
        }
      }
      return Left(ServerFailure('Ma\'lumotlar omborida noma\'lum xatolik: ${e.message}'));
    } catch (e, st) {
      _log.severe('Registratsiyada kutilmagan xatolik', e, st);
      return Left(ServerFailure('Noma\'lum server xatoligi yuz berdi.'));
    }
  }

  Future<void> _createUserProfile(String userId) async {
    try {
      await _connection.execute(
        'INSERT INTO user_profiles (user_id) VALUES (@userId)',
        substitutionValues: {'userId': userId},
      );
      _log.info('Foydalanuvchi ($userId) uchun profil muvaffaqiyatli yaratildi.');
    } catch (e) {
      _log.severe('Foydalanuvchi ($userId) profilini yaratishda xatolik: $e');
    }
  }

}