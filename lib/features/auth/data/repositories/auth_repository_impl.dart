import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Error al iniciar sesión. Por favor, intente de nuevo.'));
    }
  }

  @override
  Future<Either<Failure, User>> getAuthenticatedUser() async {
     // TODO: Implement persistent auth check
     return const Left(CacheFailure());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }
}
