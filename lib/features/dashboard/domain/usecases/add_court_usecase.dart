import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sport_center.dart';
import '../repositories/dashboard_repository.dart';

class AddCourtUseCase implements UseCase<AdminCourt, AddCourtParams> {
  final DashboardRepository repository;

  AddCourtUseCase(this.repository);

  @override
  Future<Either<Failure, AdminCourt>> call(AddCourtParams params) async {
    return await repository.addCourt(params.sportCenterId, params.name, params.description);
  }
}

class AddCourtParams extends Equatable {
  final String sportCenterId;
  final String name;
  final String description;

  const AddCourtParams({
    required this.sportCenterId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [sportCenterId, name, description];
}
