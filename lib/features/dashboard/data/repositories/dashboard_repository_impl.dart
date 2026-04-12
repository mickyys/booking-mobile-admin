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
}
