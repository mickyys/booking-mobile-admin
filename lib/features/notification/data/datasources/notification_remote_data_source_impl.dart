import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/device_token_model.dart';
import 'notification_remote_data_source.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseMessaging _firebaseMessaging;
  final Dio _dio;

  NotificationRemoteDataSourceImpl({
    FirebaseMessaging? firebaseMessaging,
    required Dio dio,
  })  : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _dio = dio;

  @override
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      throw Exception('Error getting FCM token: $e');
    }
  }

  @override
  Future<void> requestNotificationPermission() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
    }
  }

  @override
  Future<void> registerDevice(DeviceTokenModel deviceToken) async {
    try {
      print('[Notification] Registering device with token: ${deviceToken.token}');
      print('[Notification] Platform: ${deviceToken.platform}');
      print('[Notification] Device: ${deviceToken.deviceName}');
      print('[Notification] OS: ${deviceToken.osVersion}');

      final response = await _dio.post(
        '/users/devices',
        data: deviceToken.toJson(),
      );

      if (response.statusCode == 200) {
        print('[Notification] Device registered successfully');
      } else {
        throw Exception('Failed to register device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[Notification] Dio error registering device: ${e.message}');
      if (e.response?.statusCode == 403) {
        throw Exception('Unauthorized: Only administrators can register devices');
      }
      throw Exception('Error registering device: ${e.message}');
    } catch (e) {
      print('[Notification] Error registering device: $e');
      rethrow;
    }
  }

  FirebaseMessaging get firebaseMessaging => _firebaseMessaging;
}
