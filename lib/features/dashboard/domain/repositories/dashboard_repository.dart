import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../entities/schedule.dart';
import '../entities/sport_center.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
  Future<Either<Failure, List<CourtSchedule>>> getAgenda(String sportCenterId, String date);
  Future<Either<Failure, List<AdminSportCenterCourts>>> getAdminCourts();
  Future<Either<Failure, AdminCourt>> addCourt(String sportCenterId, String name, String description);
  Future<Either<Failure, Unit>> updateCourt(String courtId, String name, String description);
  Future<Either<Failure, Unit>> deleteCourt(String courtId);
  Future<Either<Failure, Booking>> createInternalBooking(Map<String, dynamic> bookingData);
  Future<Either<Failure, Unit>> cancelBooking(String bookingId);
}
