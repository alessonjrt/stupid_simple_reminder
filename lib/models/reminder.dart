import 'package:objectbox/objectbox.dart';

@Entity()
class Reminder {
  int id;
  int? dadId;
  int hour;
  int minute;
  String title;
  String description;
  int? repeatCount;
  int? repeatInterval;
  bool repeat;
  bool enabled;

  Reminder({
    this.id = 0,
    this.dadId,
    required this.hour,
    required this.minute,
    required this.title,
    required this.description,
    this.repeatCount,
    this.repeatInterval,
    this.repeat = false,
    required this.enabled,
  });


}
