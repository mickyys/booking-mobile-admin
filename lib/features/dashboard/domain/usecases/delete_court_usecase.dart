import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class DeleteCourtUseCase implements UseCase<Unit, String> {
  final DashboardRepository repository;

  DeleteCourtUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String courtId) async {
    return await repository.deleteCourt(courtId);
  }
}
