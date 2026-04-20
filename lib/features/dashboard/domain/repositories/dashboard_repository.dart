import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../entities/schedule.dart';
import '../entities/sport_center.dart';

import '../usecases/get_dashboard_data_usecase.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData({DashboardParams? params});
  Future<Either<Failure, List<CourtSchedule>>> getAgenda(String sportCenterId, String date);
  Future<Either<Failure, List<AdminSportCenterCourts>>> getAdminCourts();
  Future<Either<Failure, AdminCourt>> addCourt(String sportCenterId, String name, String description);
  Future<Either<Failure, Unit>> updateCourt(String courtId, String name, String description);
  Future<Either<Failure, Unit>> deleteCourt(String courtId);
  Future<Either<Failure, Booking>> createInternalBooking(Map<String, dynamic> bookingData);
  Future<Either<Failure, Unit>> cancelBooking(String bookingId);
  Future<Either<Failure, Unit>> updateCourtSlot(String courtId, TimeSlot slot);
  Future<Either<Failure, Unit>> updateCourtSchedule(String courtId, List<TimeSlot> slots);
  Future<Either<Failure, AdminSportCenter>> getSportCenterSettings(String id);
  Future<Either<Failure, Unit>> updateSportCenter(String id, Map<String, dynamic> data);
  Future<Either<Failure, Unit>> updateSportCenterSettings(String id, Map<String, dynamic> settings);
}
