import 'package:reservaloya_admin/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:reservaloya_admin/features/users/data/datasources/users_remote_data_source.dart';
import 'package:reservaloya_admin/features/users/data/models/user_model.dart';
import 'package:reservaloya_admin/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserModel>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();
      return Right(users);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
