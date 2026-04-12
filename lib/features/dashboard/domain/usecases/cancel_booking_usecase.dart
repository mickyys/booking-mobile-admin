import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class CancelBookingUseCase implements UseCase<Unit, String> {
  final DashboardRepository repository;

  CancelBookingUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}
