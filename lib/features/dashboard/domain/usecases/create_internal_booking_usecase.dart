import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/dashboard_repository.dart';

class CreateInternalBookingUseCase implements UseCase<Booking, Map<String, dynamic>> {
  final DashboardRepository repository;

  CreateInternalBookingUseCase(this.repository);

  @override
  Future<Either<Failure, Booking>> call(Map<String, dynamic> bookingData) async {
    return await repository.createInternalBooking(bookingData);
  }
}
