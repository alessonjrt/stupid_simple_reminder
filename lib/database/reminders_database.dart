import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:stupid_simple_reminder/database/objectbox.g.dart';
import 'package:stupid_simple_reminder/models/reminder.dart';

class RemindersDatabase {
  late final Store store;
  late final Box<Reminder> box;

  Future<RemindersDatabase> init() async {
    final dir =
        await getApplicationDocumentsDirectory(); // Get the directory path
    final path = p.join(
        dir.path, 'objectbox'); // Append 'objectbox' to the directory path
    store = Store(getObjectBoxModel(),
        directory: path); // Initialize the store with the path
    box = store.box<Reminder>();

    return this;
  }

  int saveReminder(Reminder reminder) {
    final id = box.put(reminder);
    return id;
  }

  Reminder? getReminder(int id) {
    return box.get(id);
  }

  bool removeReminder(int id) {
    return box.remove(id);
  }

  List<Reminder> getAllReminders() {
    return box.getAll();
  }

  void close() {
    store.close();
  }
}
