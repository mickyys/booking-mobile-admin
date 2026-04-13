import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/dashboard_repository.dart';

class UpdateCourtScheduleUseCase implements UseCase<Unit, UpdateCourtScheduleParams> {
  final DashboardRepository repository;

  UpdateCourtScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateCourtScheduleParams params) async {
    return await repository.updateCourtSchedule(params.courtId, params.slots);
  }
}

class UpdateCourtScheduleParams extends Equatable {
  final String courtId;
  final List<TimeSlot> slots;

  const UpdateCourtScheduleParams({required this.courtId, required this.slots});

  @override
  List<Object?> get props => [courtId, slots];
}
