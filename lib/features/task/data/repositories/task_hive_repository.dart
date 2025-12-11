import 'package:field_task_app/core/models/task_model.dart';
import 'package:hive/hive.dart';

class TaskHiveRepository {
  final Box<TaskModel> _box = Hive.box<TaskModel>('tasks');

  Future<void> addTask(TaskModel task) async {
    await _box.add(task);
  }

  List<TaskModel> getAllTasks() {
    return _box.values.toList();
  }

  Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  Future<void> deleteTask(TaskModel task) async {
    await task.delete();
  }
}
