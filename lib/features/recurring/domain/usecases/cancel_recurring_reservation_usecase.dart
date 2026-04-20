import '../repositories/recurring_repository.dart';

class CancelRecurringReservationUseCase {
  final RecurringRepository repository;

  CancelRecurringReservationUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.cancelRecurringReservation(id);
  }
}
