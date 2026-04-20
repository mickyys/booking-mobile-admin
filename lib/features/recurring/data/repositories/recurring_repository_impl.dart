import '../../domain/entities/recurring_reservation.dart';
import '../../domain/entities/recurring_series.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_remote_data_source.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringRemoteDataSource remoteDataSource;

  RecurringRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RecurringSeries>> getRecurringSeries() async {
    return await remoteDataSource.getRecurringSeries();
  }

  @override
  Future<RecurringReservation> createRecurringReservation(Map<String, dynamic> data) async {
    return await remoteDataSource.createRecurringReservation(data);
  }

  @override
  Future<void> deleteSeries(String id) async {
    return await remoteDataSource.deleteSeries(id);
  }

  @override
  Future<void> cancelRecurringReservation(String id) async {
    return await remoteDataSource.cancelRecurringReservation(id);
  }
}
