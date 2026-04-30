import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> registerDevice(String token);
  Future<Either<Failure, String?>> getFCMToken();
  Future<Either<Failure, void>> requestNotificationPermission();
}
