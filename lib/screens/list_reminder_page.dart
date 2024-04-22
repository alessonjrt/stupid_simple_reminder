import 'package:flutter/material.dart';
import 'package:stupid_simple_reminder/models/reminder.dart';
import 'package:stupid_simple_reminder/screens/create_reminder_page.dart';
import 'package:stupid_simple_reminder/services/reminder_service.dart';

class ListRemindersPage extends StatefulWidget {
  const ListRemindersPage({super.key});

  @override
  _ListRemindersPageState createState() => _ListRemindersPageState();
}

class _ListRemindersPageState extends State<ListRemindersPage> {
  late final ReminderManager _reminderManager;

  @override
  void initState() {
    super.initState();
    _reminderManager = ReminderManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar lembrete'),
        onPressed: () => showReminderCreatePage(),
      ),
      appBar: AppBar(
        title: const Text('Seus lembretes'),
      ),
      body: ValueListenableBuilder<List<Reminder>>(
        valueListenable: _reminderManager.remindersListNotifier,
        builder: (context, reminders, _) {
          if (reminders.isNotEmpty) {
            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ListTile(
               title: Text('${reminder.title} - ${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}'),

                  subtitle: Text(reminder.description),
                  trailing: Wrap(
                    spacing: 12,
                    children: <Widget>[
                      Switch(
                        value: reminder.enabled,
                        onChanged: (bool value) {
                          _toggleReminderStatus(reminder, value);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteReminder(reminder.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showReminderCreatePage(reminder: reminder),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('Você não tem lembretes'),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteReminder(int id) async {
    var wasDeleted = await _reminderManager.deleteReminder(id);
    if (wasDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lembrete deletado com sucesso')),
      );
    }
  }

  Future<void> _toggleReminderStatus(Reminder reminder, bool value) async {
    await _reminderManager.updateReminderStatus(reminder.id, value);
  }

  Future<void> showReminderCreatePage({Reminder? reminder}) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CreateReminderPage(reminder: reminder),
    ));
  }
}
