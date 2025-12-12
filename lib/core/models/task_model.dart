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

  TaskModel copyWith({
    String? title,
    String? dueDate,
    String? id,
    String? dueTime,
    double? latitude,
    double? longitude,
    String? parentTaskId,
    String? status,
  }) {
    return TaskModel(
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      id: id ?? this.id,
      dueTime: dueTime ?? this.dueTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate,
      'id': id,
      'dueTime': dueTime,
      'latitude': latitude,
      'longitude': longitude,
      'parentTaskId': parentTaskId,
      'status': status,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      title: map['title'] ?? '',
      dueDate: map['dueDate'],
      id: map['id'] ?? '',
      dueTime: map['dueTime'],
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      parentTaskId: map['parentTaskId'],
      status: map['status'] ?? 'pending',
    );
  }
}
