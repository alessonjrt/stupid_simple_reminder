import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:stupid_simple_reminder/models/reminder.dart';

class NotificationService {
  static const String channelKey = 'my_channel';
  static const String channelGroupKey = 'my_channel';

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelGroupKey: channelGroupKey,
              channelKey: channelKey,
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupName: 'Basic group', channelGroupKey: channelGroupKey)
        ],
        debug: true);
  }

  static Future<void> createNotification(Reminder reminder) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminder.id,
          channelKey: channelKey,
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
    await AwesomeNotifications().cancel(id);
  }
}
