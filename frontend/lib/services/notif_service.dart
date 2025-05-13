import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  NotifService._privateConstructor();
  static final NotifService _instance = NotifService._privateConstructor();
  factory NotifService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await notificationsPlugin.initialize(initSettings);
    // ✅ Correct and required for Android 13+
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestNotificationsPermission() ?? true;
    debugPrint("Android notifications granted: $granted");

    _isInitialized = true;
  }

  // ✅ Stock notification details with grouping
  NotificationDetails _stockNotificationDetails({required String groupKey}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'stock_alerts_channel', // Channel ID
        'Stock Alerts', // Channel name
        channelDescription: 'Notifications about low or critical stock levels',
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey, // 🔹 Used for grouping
      ),
    );
  }

  /// ✅ Call this for individual notifications (e.g., one per item)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const groupKey = 'com.yourapp.stock_alerts';

    await notificationsPlugin.show(
      id,
      title,
      body,
      _stockNotificationDetails(groupKey: groupKey),
    );
  }

  /// ✅ Optional: Summary notification that groups all individual ones
  Future<void> showGroupedSummaryNotification() async {
    const groupKey = 'com.yourapp.stock_alerts';

    const androidDetails = AndroidNotificationDetails(
      'stock_alerts_channel',
      'Stock Alerts',
      channelDescription: 'Summary of stock notifications',
      styleInformation: InboxStyleInformation(
        [],
        contentTitle: 'Stock Alerts Summary',
        summaryText: 'Multiple stock items are low or out of stock.',
      ),
      groupKey: groupKey,
      setAsGroupSummary: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0, // Use a constant ID for summary
      'Stock Alerts Summary',
      'Multiple stock items need attention',
      details,
    );
  }
}
