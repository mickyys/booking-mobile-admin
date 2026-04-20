import 'package:dartz/dartz.dart';
import 'package:reservaloya_admin/core/error/failures.dart';
import 'package:reservaloya_admin/features/users/data/models/user_model.dart';
import 'package:reservaloya_admin/features/users/domain/repositories/users_repository.dart';

class GetUsersUseCase {
  final UsersRepository repository;

  GetUsersUseCase({required this.repository});

  Future<Either<Failure, List<UserModel>>> call() async {
    return await repository.getUsers();
  }
}
