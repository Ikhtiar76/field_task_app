import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime? dueDate;

  @HiveField(2)
  int? dueHour;

  @HiveField(3)
  int? dueMinute;

  @HiveField(4)
  double? latitude;

  @HiveField(5)
  double? longitude;

  @HiveField(6)
  String? parentTaskId;
  @HiveField(7)
  bool isCompleted;

  TaskModel({
    required this.title,
    this.dueDate,
    this.dueHour,
    this.dueMinute,
    this.latitude,
    this.longitude,
    this.parentTaskId,
    this.isCompleted = false,
  });
}
