import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/dashboard_repository.dart';

class GetAgendaUseCase implements UseCase<List<CourtSchedule>, String> {
  final DashboardRepository repository;

  GetAgendaUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourtSchedule>>> call(String date) async {
    return await repository.getAgenda(date);
  }
}
