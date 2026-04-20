import '../entities/recurring_series.dart';
import '../repositories/recurring_repository.dart';

class GetRecurringSeriesUseCase {
  final RecurringRepository repository;

  GetRecurringSeriesUseCase(this.repository);

  Future<List<RecurringSeries>> call() async {
    return await repository.getRecurringSeries();
  }
}
