import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _runSafely(
      '初始化',
      () async {
        await _plugin.initialize(const InitializationSettings(android: android));
      },
    );
  }

  Future<void> requestPermission() async {
    await _runSafely('请求通知权限', () async {
      await _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
    });
  }

  Future<void> scheduleReminder(EventModel event) async {
    if (!event.reminderEnabled) return;
    await _runSafely('设置提醒', () async {
      await _cancelReminder(event);

      final now = DateTime.now();
      final thisYear = DateTime(now.year, event.date.month, event.date.day);
      var nextAnniversary = thisYear.isBefore(now) || thisYear.isAtSameMomentAs(now)
          ? DateTime(now.year + 1, event.date.month, event.date.day)
          : thisYear;

      final dayOfReminder = DateTime(
        nextAnniversary.year,
        nextAnniversary.month,
        nextAnniversary.day,
        event.reminderHour,
        event.reminderMinute,
      );
      if (dayOfReminder.isAfter(now)) {
        await _schedule(
          id: event.notificationId,
          dateTime: dayOfReminder,
          title: '🎉 今天是「${event.name}」纪念日！',
          body: '已经 ${now.difference(event.date).inDays + (nextAnniversary.difference(now).inDays)} 天了',
        );
      }

      if (event.reminderDaysBefore > 0) {
        final advanceDate = dayOfReminder.subtract(Duration(days: event.reminderDaysBefore));
        if (advanceDate.isAfter(now)) {
          await _schedule(
            id: event.notificationId + 1,
            dateTime: advanceDate,
            title: '📅 「${event.name}」纪念日还有 ${event.reminderDaysBefore} 天',
            body: '记得准备一下哦',
          );
        }
      }
    });
  }

  Future<void> cancelReminder(EventModel event) async {
    await _runSafely('取消提醒', () => _cancelReminder(event));
  }

  Future<void> _cancelReminder(EventModel event) async {
    await _plugin.cancel(event.notificationId);
    await _plugin.cancel(event.notificationId + 1);
  }

  Future<void> rescheduleAll(List<EventModel> events) async {
    await _runSafely('重排提醒', _plugin.cancelAll);
    for (final event in events) {
      if (event.reminderEnabled) {
        await scheduleReminder(event);
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'anniversary_reminder',
          '纪念日提醒',
          channelDescription: '纪念日到期提醒通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _runSafely(
    String action,
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      debugPrint('通知$action失败: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
