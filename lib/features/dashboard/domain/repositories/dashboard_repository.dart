import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../entities/schedule.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
  Future<Either<Failure, List<CourtSchedule>>> getAgenda(String date);
}
