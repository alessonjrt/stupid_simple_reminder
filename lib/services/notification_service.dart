import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:stupid_simple_reminder/models/reminder.dart';

class NotificationService {
  static late String _channelKey;
  static bool _canShowNotifications = false;
  static Future<void> initialize(
      {required String channelKey,
      required String channelGroupKey,
      required String? channelName,
      required String channelGroupName,
      required String? channelDescription,
      required Color? ledColor,
      Color? defaultColor}) async {
    _channelKey = channelKey;

    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelGroupKey: channelGroupKey,
              channelKey: channelKey,
              channelName: channelName,
              channelDescription: channelDescription,
              defaultColor: defaultColor,
              ledColor: Colors.white)
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupName: channelGroupName,
              channelGroupKey: channelGroupKey)
        ],
        debug: true);
    _canShowNotifications =
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> createNotification(Reminder reminder) async {
    if (!_canShowNotifications) {
      throw Exception('App cannot send notifications');
    }

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminder.id,
          channelKey: _channelKey,
          criticalAlert: true,
          title: reminder.title,
          body: reminder.description,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
            preciseAlarm: true,
            hour: reminder.hour,
            minute: reminder.minute,
            second: 0,
            millisecond: 0,
            repeats: true));
  }

  static Future<void> cancelNotification(int id) async {
    if (!_canShowNotifications) {
      throw Exception('App cannot delete notifications');
    }

    await AwesomeNotifications().cancel(id);
  }
}
