import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDataUseCase implements UseCase<DashboardData, NoParams> {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardData>> call(NoParams params) async {
    return await repository.getDashboardData();
  }
}
