import '../models/device_token_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> registerDevice(DeviceTokenModel deviceToken);
  Future<String?> getFCMToken();
  Future<void> requestNotificationPermission();
}
