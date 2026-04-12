import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/dashboard_repository.dart';

class GetAgendaUseCase implements UseCase<List<CourtSchedule>, AgendaParams> {
  final DashboardRepository repository;

  GetAgendaUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourtSchedule>>> call(AgendaParams params) async {
    return await repository.getAgenda(params.sportCenterId, params.date);
  }
}

class AgendaParams extends Equatable {
  final String sportCenterId;
  final String date;

  const AgendaParams({required this.sportCenterId, required this.date});

  @override
  List<Object?> get props => [sportCenterId, date];
}
