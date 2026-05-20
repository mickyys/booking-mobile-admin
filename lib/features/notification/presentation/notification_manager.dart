import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[Background Message] ${message.messageId}');
  print('[Background Message Title] ${message.notification?.title}');
  print('[Background Message Body] ${message.notification?.body}');
  
  // Si queremos mostrar notificaciones locales en background cuando solo viene data
  // o para asegurar el sonido personalizado, podríamos hacerlo aquí.
  // Pero Firebase ya maneja la notificación si viene el payload 'notification'.
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  String? _initialMessageBookingId;

  // Canal para reservas con sonido personalizado
  // NOTA: cambiar el channelId si ya existía uno previo sin sonido (Android no actualiza canales existentes)
  static const AndroidNotificationChannel _reservationChannel = AndroidNotificationChannel(
    'reservation_channel_v2',
    'Reservas',
    description: 'Notificaciones de nuevas reservas con sonido especial',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('reservation_sound'),
    playSound: true,
  );

  // Canal por defecto
  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'default_channel',
    'General',
    description: 'Notificaciones generales',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    print('[NotificationManager] Initializing...');

    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          _navigateToBooking(data);
        }
      },
    );

    // Configuración específica de Android
    if (Platform.isAndroid) {
      final androidPlugin = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Solicitar permiso de notificaciones en Android 13+
        await androidPlugin.requestNotificationsPermission();

        await androidPlugin.createNotificationChannel(_reservationChannel);
        await androidPlugin.createNotificationChannel(_defaultChannel);
      }
    }

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
      
      _showLocalNotification(message);
      _messageController.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[Opened App] Message clicked: ${message.messageId}');
      _handleNotificationNavigation(message);
    });

    _checkInitialMessage();
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      print('[NotificationManager] No notification payload in message');
      return;
    }

    final bool isReservation = notification.title?.toLowerCase().contains('reserva') ?? false;
    final channel = isReservation ? _reservationChannel : _defaultChannel;

    print('[NotificationManager] Showing local notification (isReservation=$isReservation, channel=${channel.id})');

    try {
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: channel.importance,
            priority: Priority.high,
            icon: 'notification_icon',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_foreground'),
            sound: isReservation ? const RawResourceAndroidNotificationSound('reservation_sound') : null,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: isReservation ? 'reservation_sound.wav' : null,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      print('[NotificationManager] Local notification shown successfully');
    } catch (e) {
      print('[NotificationManager] Error showing notification: $e');
    }
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
