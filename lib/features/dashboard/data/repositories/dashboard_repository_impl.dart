import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/sport_center.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

import '../../domain/usecases/get_dashboard_data_usecase.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardData>> getDashboardData({DashboardParams? params}) async {
    try {
      final data = await remoteDataSource.getDashboardData(params: params);
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

  @override
  Future<Either<Failure, Unit>> updateCourtSlot(String courtId, TimeSlot slot) async {
    try {
      await remoteDataSource.updateCourtSlot(courtId, {
        'hour': slot.hour,
        'minutes': slot.minutes,
        'price': slot.price,
        'status': slot.status,
        'payment_required': slot.paymentRequired,
        'payment_optional': slot.paymentOptional,
        'partial_payment_enabled': slot.partialPaymentEnabled,
        'day_of_week': slot.dayOfWeek,
      });
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar el horario.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCourtSchedule(String courtId, List<TimeSlot> slots) async {
    try {
      final data = slots.map((slot) => {
        'hour': slot.hour,
        'minutes': slot.minutes,
        'price': slot.price,
        'status': slot.status,
        'payment_required': slot.paymentRequired,
        'payment_optional': slot.paymentOptional,
        'partial_payment_enabled': slot.partialPaymentEnabled,
        if (slot.dayOfWeek != null) 'day_of_week': slot.dayOfWeek,
      }).toList();
      await remoteDataSource.updateCourtSchedule(courtId, data);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar el calendario.'));
    }
  }

  @override
  Future<Either<Failure, AdminSportCenter>> getSportCenterSettings(String id) async {
    try {
      final data = await remoteDataSource.getSportCenterSettings(id);
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Error al cargar la configuración del centro.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSportCenter(String id, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateSportCenter(id, data);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar el centro.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSportCenterSettings(String id, Map<String, dynamic> settings) async {
    try {
      await remoteDataSource.updateSportCenterSettings(id, settings);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar la configuración.'));
    }
  }
}
