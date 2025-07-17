import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> register({
    required String email,
    required String username,
    required String password,
  });
  Future<Either<Failure, User>> login({
    required String login,
    required String password,
  });
}