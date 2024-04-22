import 'package:flutter/foundation.dart';
import 'package:stupid_simple_reminder/database/reminders_database.dart';
import 'package:stupid_simple_reminder/models/reminder.dart';
import 'package:stupid_simple_reminder/services/notification_service.dart';

class ReminderManager {
  static final ReminderManager _singleton = ReminderManager._internal();
  late RemindersDatabase _db;
  ValueNotifier<List<Reminder>> remindersListNotifier;

  ReminderManager._internal()
      : remindersListNotifier = ValueNotifier<List<Reminder>>([]);

  static Future<void> initialize() async {
    _singleton._db = await RemindersDatabase().init();
    _singleton._refreshReminders();
  }

  factory ReminderManager() {
    return _singleton;
  }

  Future<int> createReminder(Reminder reminder) async {
    int mainReminderId = _db.saveReminder(reminder);
    await NotificationService.createNotification(reminder);
    _refreshReminders();

    if (reminder.repeatCount != null && reminder.repeatInterval != null) {
      int currentHour = reminder.hour;
      int currentMinute = reminder.minute;

      for (int i = 1; i <= reminder.repeatCount!; i++) {
        Map<String, int> childTime =
            incrementHour(currentHour, currentMinute, reminder.repeatInterval!);

        Reminder childReminder = Reminder(
          dadId: mainReminderId,
          title: reminder.title,
          description: reminder.description,
          enabled: reminder.enabled,
          hour: childTime['hour']!,
          minute: childTime['minute']!,
        );
        childReminder.id = _db.saveReminder(childReminder);
        await NotificationService.createNotification(childReminder);

        currentHour = childTime['hour']!;
        currentMinute = childTime['minute']!;
      }
    }

    return mainReminderId;
  }

  void _refreshReminders() {
    remindersListNotifier.value = _db
        .getAllReminders()
        .where((element) => element.dadId == null)
        .toList();
  }

  Future<bool> updateReminder(Reminder updatedReminder) async {
    Reminder? existingReminder = _db.getReminder(updatedReminder.id);

    if (existingReminder == null) {
      throw 'error';
    }

    await NotificationService.cancelNotification(existingReminder.id);
    List<Reminder> childReminders = _db
        .getAllReminders()
        .where((reminder) => reminder.dadId == existingReminder.id)
        .toList();
    for (var childReminder in childReminders) {
      await NotificationService.cancelNotification(childReminder.id);
      _db.removeReminder(childReminder.id);
    }

    existingReminder.hour = updatedReminder.hour;
    existingReminder.minute = updatedReminder.minute;
    existingReminder.title = updatedReminder.title;
    existingReminder.description = updatedReminder.description;
    existingReminder.enabled = updatedReminder.enabled;
    _db.saveReminder(existingReminder);

    await NotificationService.createNotification(existingReminder);

    if (updatedReminder.repeatCount != null &&
        updatedReminder.repeatInterval != null) {
      createRecurringReminders(existingReminder.id, updatedReminder);
    }

    _refreshReminders();
    return true;
  }

  Future<void> createRecurringReminders(
      int mainReminderId, Reminder parentReminder) async {
    int currentHour = parentReminder.hour;
    int currentMinute = parentReminder.minute;

    for (int i = 1; i <= parentReminder.repeatCount!; i++) {
      Map<String, int> childTime = incrementHour(
          currentHour, currentMinute, parentReminder.repeatInterval!);

      Reminder childReminder = Reminder(
        dadId: mainReminderId,
        title: '${parentReminder.title}$i',
        description: parentReminder.description,
        enabled: parentReminder.enabled,
        hour: childTime['hour']!,
        minute: childTime['minute']!,
      );
      childReminder.id = _db.saveReminder(childReminder);
      await NotificationService.createNotification(childReminder);

      currentHour = childTime['hour']!;
      currentMinute = childTime['minute']!;
    }
  }

  Future<void> updateReminderStatus(int id, bool active) async {
    Reminder? mainReminder = _db.getReminder(id);
    if (mainReminder != null) {
      mainReminder.enabled = active;
      _db.saveReminder(mainReminder);
      _refreshReminders();

      if (active) {
        await NotificationService.createNotification(mainReminder);
      } else {
        await NotificationService.cancelNotification(mainReminder.id);
      }

      List<Reminder> childReminders = _db
          .getAllReminders()
          .where((element) => element.id == mainReminder.id)
          .toList();

      for (var childReminder in childReminders) {
        childReminder.enabled = active;
        _db.saveReminder(childReminder);

        if (active) {
          await NotificationService.createNotification(childReminder);
        } else {
          await NotificationService.cancelNotification(childReminder.id);
        }
      }
    }
  }

  Reminder? fetchReminder(int id) {
    return _db.getReminder(id);
  }

  Future<bool> deleteReminder(int id) async {
    await NotificationService.cancelNotification(id);
    bool deleted = _db.removeReminder(id);
    _refreshReminders();

    List<Reminder> childReminders = _db
        .getAllReminders()
        .where((reminder) => reminder.dadId == id)
        .toList();
    for (var childReminder in childReminders) {
      await NotificationService.cancelNotification(childReminder.id);
      _db.removeReminder(childReminder.id);
    }
    return deleted;
  }

  List<Reminder> listReminders() {
    return _db
        .getAllReminders()
        .where((reminder) => reminder.dadId == null)
        .toList();
  }

  Map<String, int> incrementHour(int hour, int minute, int incrementMinutes) {
    DateTime now = DateTime(2000, 1, 1, hour, minute);
    DateTime newHour = now.add(Duration(minutes: incrementMinutes));

    return {
      'hour': newHour.hour,
      'minute': newHour.minute,
    };
  }
}
