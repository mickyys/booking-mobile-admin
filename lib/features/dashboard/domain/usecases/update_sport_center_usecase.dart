import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class UpdateSportCenterUseCase implements UseCase<void, UpdateSportCenterParams> {
  final DashboardRepository repository;

  UpdateSportCenterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSportCenterParams params) async {
    if (params.settings != null) {
      return await repository.updateSportCenterSettings(params.id, params.settings!);
    }
    return await repository.updateSportCenter(params.id, params.data!);
  }
}

class UpdateSportCenterParams extends Equatable {
  final String id;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? settings;

  const UpdateSportCenterParams({
    required this.id,
    this.data,
    this.settings,
  });

  @override
  List<Object?> get props => [id, data, settings];
}
