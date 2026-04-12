import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sport_center.dart';
import '../repositories/dashboard_repository.dart';

class GetAdminCourtsUseCase implements UseCase<List<AdminSportCenterCourts>, NoParams> {
  final DashboardRepository repository;

  GetAdminCourtsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AdminSportCenterCourts>>> call(NoParams params) async {
    return await repository.getAdminCourts();
  }
}
