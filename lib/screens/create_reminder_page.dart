import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../services/reminder_service.dart';

class CreateReminderPage extends StatefulWidget {
  final Reminder? reminder;
  const CreateReminderPage({super.key, this.reminder});

  @override
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _repeatCountController = TextEditingController();
  final _repeatIntervalController = TextEditingController();

  bool repeat = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description;
      _selectedTime = TimeOfDay(
          hour: widget.reminder!.hour, minute: widget.reminder!.minute);
      _repeatCountController.text = widget.reminder!.repeatCount.toString();
      _repeatIntervalController.text = widget.reminder!.repeatInterval.toString();
    }
  }

  Future<void> _escolherHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Lembrete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextButton(
              onPressed: () => _escolherHora(context),
              child: Text(
                '${_selectedTime.format(context)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              autocorrect: false,
              maxLength: 50,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: null,
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Text('Repetir:'),
                Checkbox(
                  value: repeat,
                  onChanged: (bool? value) {
                    setState(() {
                      repeat = value!;
                    });
                  },
                ),
                const Text('Ativado'),
              ],
            ),
            if (repeat) ...[
              Row(
                children: [
                  SizedBox(
                    width: 80.0,
                    child: TextField(
                      controller: _repeatCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantidade'),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _repeatIntervalController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Intervalo (minutos)'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _enviarFormulario(context),
              child: const Text('Salvar Lembrete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarFormulario(BuildContext context) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final hour = _selectedTime.hour;
    final minute = _selectedTime.minute;
    final repeatCount = int.tryParse(_repeatCountController.text);
    final repeatInterval = int.tryParse(_repeatIntervalController.text);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um título')),
      );
      return;
    }

    var reminder = Reminder(
      title: title,
      description: description,
      hour: hour,
      minute: minute,
      repeatCount: repeatCount,
      repeatInterval: repeatInterval,
      enabled: true,
    );

    if (widget.reminder != null) {
       reminder.id = widget.reminder?.id ?? 0;
      await ReminderManager().updateReminder(reminder);
    } else {
      await ReminderManager().createReminder(reminder);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lembrete Criado')),
    );

    Navigator.pop(context);
  }
}
