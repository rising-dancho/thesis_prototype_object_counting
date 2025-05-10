import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  NotifService._privateConstructor();
  static final NotifService _instance = NotifService._privateConstructor();
  factory NotifService() => _instance;

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const defaultIcon = "@mipmap/ic_launcher";
    const initSettingsAndroid = AndroidInitializationSettings(defaultIcon);

    const initSettings = InitializationSettings(android: initSettingsAndroid);
    await notificationsPlugin.initialize(initSettings);

    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "daily_channel_id",
        "Daily Notifications",
        channelDescription: "Daily Notification Channel",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }
}
