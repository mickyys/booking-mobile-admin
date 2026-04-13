import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase implements UseCase<User, SocialLoginParams> {
  final AuthRepository repository;

  SocialLoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SocialLoginParams params) async {
    return await repository.loginWithSocial(params.connection);
  }
}

class SocialLoginParams extends Equatable {
  final String connection;

  const SocialLoginParams({required this.connection});

  @override
  List<Object?> get props => [connection];
}
