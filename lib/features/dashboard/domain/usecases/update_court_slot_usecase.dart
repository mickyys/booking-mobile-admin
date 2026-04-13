import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule.dart';
import '../repositories/dashboard_repository.dart';

class UpdateCourtSlotUseCase implements UseCase<Unit, UpdateCourtSlotParams> {
  final DashboardRepository repository;

  UpdateCourtSlotUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateCourtSlotParams params) async {
    return await repository.updateCourtSlot(params.courtId, params.slot);
  }
}

class UpdateCourtSlotParams extends Equatable {
  final String courtId;
  final TimeSlot slot;

  const UpdateCourtSlotParams({required this.courtId, required this.slot});

  @override
  List<Object?> get props => [courtId, slot];
}
