import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/dashboard_repository.dart';

class BatchBookingsParams extends Equatable {
  final List<Map<String, dynamic>> bookings;
  final String? seriesId;

  const BatchBookingsParams({required this.bookings, this.seriesId});

  @override
  List<Object?> get props => [bookings, seriesId];
}

class CreateBatchBookingsUseCase implements UseCase<List<Booking>, BatchBookingsParams> {
  final DashboardRepository repository;

  CreateBatchBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(BatchBookingsParams params) async {
    return await repository.createBatchBookings(params.bookings, seriesId: params.seriesId);
  }
}
