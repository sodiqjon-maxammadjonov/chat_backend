// lib/data/repositories/auth_repository_impl.dart (YANGILANGAN)

import 'package:chat_app_backend/core/error/failure.dart';
import 'package:chat_app_backend/core/security/hash.dart';
import 'package:chat_app_backend/data/models/user_model.dart';
import 'package:chat_app_backend/domain/entities/user.dart';
import 'package:chat_app_backend/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

// BU ENDI 'implements AuthRepository' SHARTNOMASINI TO'LIQ BAJARADI
class AuthRepositoryImpl implements AuthRepository {
  final PostgreSQLConnection _connection;
  final HashService _hashService;
  final _log = Logger('AuthRepositoryImpl');

  AuthRepositoryImpl({
    required PostgreSQLConnection connection,
    required HashService hashService,
  }) :  _connection = connection,
        _hashService = hashService;


  // Register metodi o'zgarmaydi, shu holicha qoladi
  @override
  Future<Either<Failure, String>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    // ... avvalgi qadamdagi register kodi ...
    try {
      final hashedPassword = _hashService.hashPassword(password);
      final result = await _connection.query(
        'INSERT INTO users (email, username, password_hash) VALUES (@email, @username, @password) RETURNING id',
        substitutionValues: { 'email': email, 'username': username, 'password': hashedPassword,},
      );
      if (result.isEmpty || result.first.isEmpty) { return Left(ServerFailure('Foydalanuvchi yaratilmadi, server xatoligi.'));}
      final userId = result.first.toColumnMap()['id'] as String;
      await _createUserProfile(userId);
      return Right(userId);
    } on PostgreSQLException catch (e) {
      if (e.code == '23505') {
        if(e.message!.contains('users_email_key')){ return Left(ValidationFailure('Bu email allaqachon ro\'yxatdan o\'tgan.')); }
        if(e.message!.contains('users_username_key')){ return Left(ValidationFailure('Bu username allaqachon band.'));}
      }
      return Left(ServerFailure('Ma\'lumotlar omborida noma\'lum xatolik: ${e.message}'));
    } catch (e) { return Left(ServerFailure('Noma\'lum server xatoligi yuz berdi.')); }
  }


  // --- MANA YANGI METOD ---
  @override
  Future<Either<Failure, User>> login({
    required String login,
    required String password,
  }) async {
    try {
      _log.info('Login so\'rovi qabul qilindi: login=$login');

      // 1. Foydalanuvchini email yoki username orqali DB'dan qidiramiz
      final result = await _connection.query(
        'SELECT id, email, username, password_hash FROM users WHERE email = @login OR username = @login LIMIT 1',
        substitutionValues: {'login': login},
      );

      // Agar bunday foydalanuvchi topilmasa
      if (result.isEmpty) {
        _log.warning('Foydalanuvchi topilmadi: $login');
        return Left(AuthFailure('Login yoki parol xato!'));
      }

      final userData = result.first.toColumnMap();
      final hashedPassword = userData['password_hash'] as String;

      // 2. Kiritilgan parolni DB'dagi hesh bilan solishtiramiz
      final isPasswordCorrect = _hashService.verifyPassword(password, hashedPassword);

      // Agar parol noto'g'ri bo'lsa
      if (!isPasswordCorrect) {
        _log.warning('Parol xato: $login uchun');
        return Left(AuthFailure('Login yoki parol xato!'));
      }

      // 3. Hammasi to'g'ri bo'lsa, 'User' ob'ektini yaratib, qaytaramiz
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

  Future<void> _createUserProfile(String userId) async {
    try { await _connection.execute('INSERT INTO user_profiles (user_id) VALUES (@userId)', substitutionValues: {'userId': userId}); } catch (e) { _log.severe('Foydalanuvchi ($userId) profilini yaratishda xatolik: $e'); }
  }
}