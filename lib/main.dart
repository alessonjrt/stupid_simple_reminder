import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stupid_simple_reminder/screens/list_reminder_page.dart';
import 'package:stupid_simple_reminder/services/notification_service.dart';
import 'package:stupid_simple_reminder/services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();

  NotificationService.initialize();
  await ReminderManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stupid Simple Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark, seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const ListRemindersPage(),
    );
  }
}
