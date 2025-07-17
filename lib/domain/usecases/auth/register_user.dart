import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../repositories/auth_repository.dart';
class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<Either<Failure, String>> call(RegisterUserParams params) async {
    return await _repository.register(
      email: params.email,
      username: params.username,
      password: params.password,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String email;
  final String username;
  final String password;

  const RegisterUserParams({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}