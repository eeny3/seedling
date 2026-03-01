import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init (you can also use DarwinInitializationSettings, but iOS-specific exists too)
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // optional: requestCarPlayPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      // Optional: handle notification tap
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // response.payload can be used for navigation
      },
    );
  }

  Future<bool> _isEnabledByUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> requestPermissionsIfNeeded() async {
    if (!Platform.isIOS) return;

    final enabled = await _isEnabledByUser();
    if (!enabled) return;

    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final enabled = await _isEnabledByUser();
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'seedling_channel',
      'Seedling Notifications',
      channelDescription: 'Notifications for Seedling Timer',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}