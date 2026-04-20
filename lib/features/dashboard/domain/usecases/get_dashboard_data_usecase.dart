import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDataUseCase implements UseCase<DashboardData, DashboardParams> {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardData>> call(DashboardParams params) async {
    return await repository.getDashboardData(params: params);
  }
}

class DashboardParams extends Equatable {
  final String? date;
  final String? customerName;
  final String? bookingCode;
  final String? status;
  final int page;

  const DashboardParams({
    this.date,
    this.customerName,
    this.bookingCode,
    this.status,
    this.page = 1,
  });

  @override
  List<Object?> get props => [date, customerName, bookingCode, status, page];
}
