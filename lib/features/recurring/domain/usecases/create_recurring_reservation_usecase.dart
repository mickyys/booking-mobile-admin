import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recurring_reservation.dart';
import '../repositories/recurring_repository.dart';

class CreateRecurringReservationUseCase {
  final RecurringRepository repository;

  CreateRecurringReservationUseCase(this.repository);

  Future<RecurringReservation> call(Map<String, dynamic> data) async {
    return await repository.createRecurringReservation(data);
  }
}
