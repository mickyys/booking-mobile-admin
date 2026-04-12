import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/sport_center.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      final data = await remoteDataSource.getDashboardData();
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Error al cargar datos del dashboard.'));
    }
  }

  @override
  Future<Either<Failure, List<CourtSchedule>>> getAgenda(String sportCenterId, String date) async {
    try {
      final data = await remoteDataSource.getAgenda(sportCenterId, date);
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Error al cargar la agenda.'));
    }
  }

  @override
  Future<Either<Failure, List<AdminSportCenterCourts>>> getAdminCourts() async {
    try {
      final data = await remoteDataSource.getAdminCourts();
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Error al cargar los centros deportivos.'));
    }
  }

  @override
  Future<Either<Failure, AdminCourt>> addCourt(String sportCenterId, String name, String description) async {
    try {
      final data = await remoteDataSource.addCourt(sportCenterId, name, description);
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Error al agregar la cancha.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCourt(String courtId, String name, String description) async {
    try {
      await remoteDataSource.updateCourt(courtId, name, description);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar la cancha.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCourt(String courtId) async {
    try {
      await remoteDataSource.deleteCourt(courtId);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al eliminar la cancha.'));
    }
  }

  @override
  Future<Either<Failure, Booking>> createInternalBooking(Map<String, dynamic> bookingData) async {
    try {
      final data = await remoteDataSource.createInternalBooking(bookingData);
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Error al crear la reserva interna.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelBooking(String bookingId) async {
    try {
      await remoteDataSource.cancelBooking(bookingId);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al cancelar la reserva.'));
    }
  }
}
