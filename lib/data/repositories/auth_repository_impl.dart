// lib/data/repositories/auth_repository_impl.dart (YAKUNIY ISHLAYDIGAN VERSIYA)

import 'package:chat_app_backend/core/error/failure.dart';
import 'package:chat_app_backend/core/security/hash.dart';
import 'package:chat_app_backend/domain/entities/user.dart';
import 'package:chat_app_backend/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart'; // <<<--- ID YARATISH UCHUN UUID IMPORT QILAMIZ

// Bu klass AuthRepository shartnomasini bajaradi.
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
      _log.info('Registratsiya boshlandi: email=$email, username=$username');

      // 1. Parolni xavfsiz heshga aylantiramiz
      final hashedPassword = _hashService.hashPassword(password);

      // ✅✅✅ MUAMMONING YECHIMI MANA SHU YERDA ✅✅✅
      // Biz "id" ustunini so'rovdan olib tashlaymiz. Shunda PostgreSQL
      // jadval sxemasidagi "DEFAULT uuid_generate_v4()" qoidasini ishlatadi.
      // "RETURNING id" bizga yangi yaratilgan foydalanuvchining ID'sini qaytaradi.
      final result = await _connection.query(
        'INSERT INTO users (email, username, password_hash) VALUES (@email, @username, @password) RETURNING id',
        substitutionValues: {
          'email': email,
          'username': username,
          'password': hashedPassword,
        },
      );

      // Natija bo'sh emasligini tekshiramiz
      if (result.isEmpty || result.first.isEmpty) {
        _log.severe('Foydalanuvchi yaratilmadi, DB "RETURNING id" qaytarmadi.');
        return Left(ServerFailure('Foydalanuvchini yaratishda noma\'lum server xatoligi.'));
      }

      // Yangi yaratilgan ID'ni olamiz
      final userId = result.first.toColumnMap()['id'] as String;
      _log.info('Yangi foydalanuvchi muvaffaqiyatli yaratildi: ID=$userId');

      // Yangi foydalanuvchi uchun bo'sh profil yaratamiz
      await _createUserProfile(userId);

      // Muvaffaqiyatli natija sifatida ID'ni qaytaramiz
      return Right(userId);

    } on PostgreSQLException catch (e, st) {
      // UNIQUE cheklovini buzish xatoligi (23505 - unique_violation)
      if (e.code == '23505') {
        if (e.message != null && e.message!.contains('users_email_key')) {
          _log.warning('Registratsiya xatosi: email ($email) allaqachon mavjud.');
          return Left(ValidationFailure('Bu email allaqachon ro\'yxatdan o\'tgan.'));
        }
        if (e.message != null && e.message!.contains('users_username_key')) {
          _log.warning('Registratsiya xatosi: username ($username) allaqachon mavjud.');
          return Left(ValidationFailure('Bu username allaqachon band.'));
        }
      }
      // Boshqa barcha PostgreSQL xatoliklari
      _log.severe('Registratsiya vaqtida DB xatoligi', e, st);
      return Left(ServerFailure('Ma\'lumotlar omborida noma\'lum xatolik: ${e.message}'));
    } catch (e, st) {
      _log.severe('Registratsiya vaqtida kutilmagan tizim xatoligi', e, st);
      return Left(ServerFailure('Noma\'lum server xatoligi yuz berdi.'));
    }
  }


  @override
  Future<Either<Failure, User>> login({
    required String login,
    required String password,
  }) async {
    // Siz yuborgan LOGIN logikasi mutlaqo TO'G'RI!
    // Shuning uchun bu yerda o'zgarish yo'q. Faqat kod tozaligini yaxshiladim.
    try {
      _log.info('Login so\'rovi qabul qilindi: login=$login');

      final result = await _connection.query(
        'SELECT id, email, username, password_hash FROM users WHERE email = @login OR username = @login LIMIT 1',
        substitutionValues: {'login': login},
      );

      if (result.isEmpty) {
        _log.warning('Foydalanuvchi topilmadi: $login');
        return Left(AuthFailure('Login yoki parol xato!'));
      }

      final userData = result.first.toColumnMap();
      final hashedPasswordFromDb = userData['password_hash'] as String;
      final isPasswordCorrect = _hashService.verifyPassword(password, hashedPasswordFromDb);

      if (!isPasswordCorrect) {
        _log.warning('Parol xato: $login uchun');
        return Left(AuthFailure('Login yoki parol xato!'));
      }

      final user = User(
        id: userData['id'] as String,
        email: userData['email'] as String,
        username: userData['username'] as String,
      );

      _log.info('Foydalanuvchi ${user.id} tizimga muvaffaqiyatli kirdi.');
      return Right(user);

    } on PostgreSQLException catch (e, st) {
      _log.severe('Login vaqtida DB xatoligi', e, st);
      return Left(ServerFailure('Ma\'lumotlar omborida xatolik yuz berdi.'));
    } catch (e, st) {
      _log.severe('Login vaqtida kutilmagan xatolik', e, st);
      return Left(ServerFailure('Noma\'lum server xatoligi.'));
    }
  }

  // Yordamchi metod, foydalanuvchiga tegishli user_profiles yaratadi.
  Future<void> _createUserProfile(String userId) async {
    try {
      await _connection.execute(
        'INSERT INTO user_profiles (user_id) VALUES (@userId)',
        substitutionValues: {'userId': userId},
      );
      _log.info('Foydalanuvchi ($userId) uchun profil muvaffaqiyatli yaratildi.');
    } catch (e) {
      // Bu yerda xato bo'lsa ham registratsiyani to'xtatmaymiz,
      // shunchaki logga yozib qo'yamiz. Chunki asosiy `users` yaratildi.
      _log.severe('Foydalanuvchi ($userId) profilini yaratishda xatolik: $e');
    }
  }
}