import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> loginWithSocial(String connection);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> refreshToken();
  Future<Either<Failure, User>> getSavedUser();
  Future<bool> hasToken();
}
