import 'package:field_task_app/core/models/task_model.dart';

abstract class TaskRepository {
  // initialization
  Future<void> init();
  // get all task
  List<TaskModel> getTasks();

  // create task
  Future<List<TaskModel>> createTasks(TaskModel newTask);

  // update task
  Future<List<TaskModel>> updateTasks(TaskModel task);
}
