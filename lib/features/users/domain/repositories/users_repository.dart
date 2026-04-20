import 'package:dartz/dartz.dart';
import 'package:reservaloya_admin/core/error/failures.dart';
import 'package:reservaloya_admin/features/users/data/models/user_model.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<UserModel>>> getUsers();
}
