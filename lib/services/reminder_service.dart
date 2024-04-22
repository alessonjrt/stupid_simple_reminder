import 'package:flutter/material.dart';
import 'package:stupid_simple_reminder/database/reminders_database.dart';
import 'package:stupid_simple_reminder/models/reminder.dart';
import 'package:stupid_simple_reminder/services/notification_service.dart';

class ReminderManager {
  static final ReminderManager _singleton = ReminderManager._internal();
  late RemindersDatabase _db;
  ValueNotifier<List<Reminder>> remindersListNotifier =
      ValueNotifier<List<Reminder>>([]);

  ReminderManager._internal();

  factory ReminderManager() {
    return _singleton;
  }

  static Future<void> initialize(
      {required String channelKey,
      required String channelGroupKey,
      required String? channelName,
      required String channelGroupName,
      required String? channelDescription,
      required Color? ledColor,
      Color? defaultColor}) async {
    _singleton._db = await RemindersDatabase().init();
    _singleton._refreshReminders();
    await NotificationService.initialize(
        channelDescription: channelDescription,
        channelGroupKey: channelGroupKey,
        channelKey: channelKey,
        channelGroupName: channelGroupName,
        channelName: channelName,
        ledColor: ledColor,
        defaultColor: defaultColor);
  }

  Future<int> createReminder(Reminder reminder) async {
    int mainReminderId = _db.saveReminder(reminder);
    await NotificationService.createNotification(reminder);
    _refreshReminders();

    if (reminder.repeatCount != null && reminder.repeatInterval != null) {
      await createRecurringReminders(mainReminderId, reminder);
    }
    return mainReminderId;
  }

  void _refreshReminders() {
    remindersListNotifier.value =
        _db.getAllReminders().where((r) => r.dadId == null).toList();
  }

  Future<bool> updateReminder(Reminder updatedReminder) async {
    var existingReminder = _db.getReminder(updatedReminder.id);
    if (existingReminder == null) throw Exception('Reminder not found.');

    existingReminder.hour = updatedReminder.hour;
    existingReminder.minute = updatedReminder.minute;
    existingReminder.title = updatedReminder.title;
    existingReminder.description = updatedReminder.description;
    existingReminder.enabled = updatedReminder.enabled;

    await NotificationService.cancelNotification(existingReminder.id);
    await NotificationService.createNotification(existingReminder);
    _db.saveReminder(existingReminder);

    if (updatedReminder.repeatCount != null &&
        updatedReminder.repeatInterval != null) {
      await createRecurringReminders(existingReminder.id, updatedReminder);
    }

    _refreshReminders();
    return true;
  }

  Future<void> createRecurringReminders(
      int mainReminderId, Reminder parentReminder) async {
    DateTime time =
        DateTime(2000, 1, 1, parentReminder.hour, parentReminder.minute);
    for (int i = 1; i <= parentReminder.repeatCount!; i++) {
      time = time.add(Duration(minutes: parentReminder.repeatInterval!));
      Reminder childReminder = Reminder(
        dadId: mainReminderId,
        title: parentReminder.title,
        description: parentReminder.description,
        enabled: parentReminder.enabled,
        hour: time.hour,
        minute: time.minute,
      );
      childReminder.id = _db.saveReminder(childReminder);
      await NotificationService.createNotification(childReminder);
    }
  }

  Future<void> updateReminderStatus(int id, bool active) async {
    var remindersToUpdate = _db
        .getAllReminders()
        .where((r) => r.id == id || r.dadId == id)
        .toList();
    for (var reminder in remindersToUpdate) {
      reminder.enabled = active;
      _db.saveReminder(reminder);
      await (active
          ? NotificationService.createNotification(reminder)
          : NotificationService.cancelNotification(reminder.id));
    }
    _refreshReminders();
  }

  Future<bool> deleteReminder(int id) async {
    var remindersToDelete = _db
        .getAllReminders()
        .where((r) => r.id == id || r.dadId == id)
        .toList();
    for (var reminder in remindersToDelete) {
      await NotificationService.cancelNotification(reminder.id);
      _db.removeReminder(reminder.id);
    }
    _refreshReminders();
    return true;
  }

  List<Reminder> listReminders() =>
      _db.getAllReminders().where((r) => r.dadId == null).toList();

}
