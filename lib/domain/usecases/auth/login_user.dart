import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<Either<Failure, User>> call(LoginUserParams params) async {
    return await _repository.login(
      login: params.login,
      password: params.password,
    );
  }
}

class LoginUserParams extends Equatable {
  final String login;
  final String password;

  const LoginUserParams({
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [login, password];
}