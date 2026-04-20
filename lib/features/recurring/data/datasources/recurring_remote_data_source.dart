import '../../data/models/recurring_reservation_model.dart';
import '../../data/models/recurring_series_model.dart';

abstract class RecurringRemoteDataSource {
  Future<List<RecurringSeriesModel>> getRecurringSeries();
  Future<RecurringReservationModel> createRecurringReservation(Map<String, dynamic> data);
  Future<void> deleteSeries(String id);
  Future<void> cancelRecurringReservation(String id);
}
