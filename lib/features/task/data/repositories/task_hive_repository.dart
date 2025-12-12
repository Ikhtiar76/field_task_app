import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/domain/repository/task_repo.dart';
import 'package:hive/hive.dart';

class TaskHiveRepository implements TaskRepository {
  late final Box _taskBox;

  @override
  Future<void> init() async {
    Hive.registerAdapter(TaskModelAdapter());
    _taskBox = await Hive.openBox<TaskModel>('tasks');
  }

  Box get taskBox => _taskBox;

  @override
  List<TaskModel> getTasks() {
    final taskList = _taskBox.values.toList();
    return taskList as List<TaskModel>;
  }

  @override
  Future<List<TaskModel>> createTasks(TaskModel newTask) async {
    await _taskBox.add(newTask);
    return getTasks();
  }

  @override
  Future<List<TaskModel>> updateTasks(TaskModel task) async {
    final taskToUpdate = await _taskBox.values.firstWhere(
      (element) => element.id == task.id,
    );
    final index = taskToUpdate.key;
    await _taskBox.put(index, task);
    return getTasks();
  }
}
