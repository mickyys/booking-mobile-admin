import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[Background Message] ${message.messageId}');
  print('[Background Message Title] ${message.notification?.title}');
  print('[Background Message Body] ${message.notification?.body}');
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  String? _initialMessageBookingId;

  Future<void> initialize() async {
    print('[NotificationManager] Initializing...');

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

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _setupMessageHandlers();

    print('[NotificationManager] Initialization complete');
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[Foreground Message] Received: ${message.messageId}');
      print('[Foreground Message Title] ${message.notification?.title}');
      print('[Foreground Message Body] ${message.notification?.body}');
      _messageController.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[Opened App] Message clicked: ${message.messageId}');
      _handleNotificationNavigation(message);
    });

    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      print('[Initial Message] App opened from notification: ${initialMessage.messageId}');
      _handleNotificationNavigation(initialMessage);
    }
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    print('[Navigation] Handling notification click');
    _navigateToBooking(message.data);
  }

  void _navigateToBooking(Map<String, dynamic> data) {
    final bookingId = data['booking_id'];
    
    if (bookingId != null) {
      print('[Navigation] Navigating to booking: $bookingId');
      _initialMessageBookingId = bookingId.toString();
    }
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('[FCM Token] Token: $token');
      
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('[FCM Token] Token refreshed: $newToken');
      });
      
      return token;
    } catch (e) {
      print('[FCM Token] Error: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('[FCM Token] Token deleted');
    } catch (e) {
      print('[FCM Token] Error deleting token: $e');
    }
  }

  String? getInitialBookingId() {
    final bookingId = _initialMessageBookingId;
    _initialMessageBookingId = null;
    return bookingId;
  }

  void dispose() {
    _messageController.close();
  }
}
