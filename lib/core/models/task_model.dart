import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? dueDate;

  @HiveField(2)
  String id;

  @HiveField(3)
  String? dueTime;

  @HiveField(4)
  double? latitude;

  @HiveField(5)
  double? longitude;

  @HiveField(6)
  String? parentTaskId;
  @HiveField(7)
  String status;

  TaskModel({
    required this.title,
    this.dueDate,
    required this.id,
    this.dueTime,
    this.latitude,
    this.longitude,
    this.parentTaskId,
    this.status = "pending",
  });
}
