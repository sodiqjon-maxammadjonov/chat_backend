import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../core/failure/auth_failure.dart';
import '../../core/failure/failure.dart';
import '../../core/failure/server_failure.dart';
import '../../data/datasource/postgres/postgre_data_source.dart';
import '../../data/models/user/login_request_model.dart';
import '../../data/models/user/register_request_model.dart';
import '../../data/models/user/user_model.dart';
import '../../services/hash/hash_service.dart';
import '../../services/token/token_service.dart';


class AuthResponse {
  final UsersModel user;
  final String token;
  AuthResponse({required this.user, required this.token});
}

class AuthService {
  final PostgresAuthDataSource _dataSource;
  final HashService _hashService;
  final TokenService _tokenService;
  final Uuid _uuid;

  AuthService(
      this._dataSource, this._hashService, this._tokenService, this._uuid);

  Future<Either<Failure, AuthResponse>> register(
      RegisterRequestModel request) async {
    try {
      final existingUser = await _dataSource.findUserByEmail(request.email);
      if (existingUser != null) {
        return Left(AuthFailure('Ushbu email bilan foydalanuvchi allaqachon mavjud.'));
      }

      final passwordHash = _hashService.hash(request.password);

      final newUser = UsersModel(
        id: _uuid.v4(),
        username: request.username.trim(),
        displayName: request.displayName.trim(),
        email: request.email.trim(),
        createdAt: DateTime.now().toUtc(),
      );

      final savedUser = await _dataSource.saveUser(user: newUser, passwordHash: passwordHash);

      final token = await _tokenService.generateToken(userId: savedUser.id);

      // Token (string) bilan javob qaytaramiz
      return Right(AuthResponse(user: savedUser, token: token));

    } catch (e) {
      return Left(ServerFailure('Ro\'yxatdan o\'tishda kutilmagan server xatoligi: $e'));
    }
  }

  Future<Either<Failure, AuthResponse>> login(LoginRequestModel request) async {
    try {
      final user = await _dataSource.findUserByEmail(request.email);
      if (user == null) {
        return Left(AuthFailure('Email yoki parol noto\'g\'ri.'));
      }

      final passwordHash = await _dataSource.findPasswordHashByUserId(user.id);
      if (passwordHash == null || !_hashService.verify(request.password, passwordHash)) {
        return Left(AuthFailure('Email yoki parol noto\'g\'ri.'));
      }

      final token = await _tokenService.generateToken(userId: user.id);

      return Right(AuthResponse(user: user, token: token));

    } catch(e) {
      return Left(ServerFailure('Tizimga kirishda kutilmagan server xatoligi: $e'));
    }
  }

  Future<Either<Failure, UsersModel>> getProfile(String userId) async {
    try {
      final user = await _dataSource.findUserById(userId);
      if (user == null) {
        return Left(AuthFailure('Foydalanuvchi topilmadi.'));
      }
      return Right(user);
    } catch(e) {
      return Left(ServerFailure('Profilni olishda kutilmagan server xatoligi: $e'));
    }
  }
}