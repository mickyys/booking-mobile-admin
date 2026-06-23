import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class CancelRecurringDateUseCase implements UseCase<Unit, CancelRecurringDateParams> {
  final DashboardRepository repository;

  CancelRecurringDateUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CancelRecurringDateParams params) async {
    return await repository.cancelRecurringDate(params.recurringReservationId, params.date);
  }
}

class CancelRecurringDateParams extends Equatable {
  final String recurringReservationId;
  final String date;

  const CancelRecurringDateParams({required this.recurringReservationId, required this.date});

  @override
  List<Object?> get props => [recurringReservationId, date];
}
