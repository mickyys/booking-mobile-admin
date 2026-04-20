import '../entities/recurring_reservation.dart';
import '../entities/recurring_series.dart';

abstract class RecurringRepository {
  Future<List<RecurringSeries>> getRecurringSeries();
  Future<RecurringReservation> createRecurringReservation(Map<String, dynamic> data);
  Future<void> deleteSeries(String id);
  Future<void> cancelRecurringReservation(String id);
}
