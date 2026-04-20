import '../repositories/recurring_repository.dart';

class DeleteSeriesUseCase {
  final RecurringRepository repository;

  DeleteSeriesUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteSeries(id);
  }
}
