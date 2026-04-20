import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sport_center.dart';
import '../repositories/dashboard_repository.dart';

class GetSportCenterSettingsUseCase implements UseCase<AdminSportCenter, String> {
  final DashboardRepository repository;

  GetSportCenterSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, AdminSportCenter>> call(String id) async {
    return await repository.getSportCenterSettings(id);
  }
}
