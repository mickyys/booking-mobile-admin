import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class UpdateCourtUseCase implements UseCase<Unit, UpdateCourtParams> {
  final DashboardRepository repository;

  UpdateCourtUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateCourtParams params) async {
    return await repository.updateCourt(params.courtId, params.name, params.description);
  }
}

class UpdateCourtParams extends Equatable {
  final String courtId;
  final String name;
  final String description;

  const UpdateCourtParams({
    required this.courtId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [courtId, name, description];
}
