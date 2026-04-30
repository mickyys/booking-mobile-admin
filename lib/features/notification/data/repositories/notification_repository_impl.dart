import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/device_token_model.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String?>> getFCMToken() async {
    try {
      final token = await remoteDataSource.getFCMToken();
      return Right(token);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestNotificationPermission() async {
    try {
      await remoteDataSource.requestNotificationPermission();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerDevice(String token) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final deviceToken = DeviceTokenModel(
        token: token,
        platform: DeviceTokenModel.getPlatform(),
        deviceName: DeviceTokenModel.getDeviceName(),
        osVersion: DeviceTokenModel.getOSVersion(),
      );

      await remoteDataSource.registerDevice(deviceToken);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
