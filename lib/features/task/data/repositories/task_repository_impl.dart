import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/domain/repository/task_repo.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRepositoryImpl implements TaskRepository {
  late final Box _taskBox;
  final CollectionReference taskCollection = FirebaseFirestore.instance
      .collection('tasks');

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
    await _taskBox.put(newTask.id, newTask); // Hive
    try {
      await taskCollection.doc(newTask.id).set(newTask.toMap()); // Firebase
    } catch (_) {}
    return getTasks();
  }

  @override
  Future<List<TaskModel>> updateTasks(TaskModel task) async {
    await _taskBox.put(task.id, task); // Hive
    try {
      await taskCollection.doc(task.id).update(task.toMap()); // Firebase
    } catch (_) {}
    return getTasks();
  }

  Future<void> syncFromFirebase() async {
    try {
      final snapshot = await taskCollection.get();
      for (var doc in snapshot.docs) {
        final task = TaskModel.fromMap(doc.data() as Map<String, dynamic>);
        await _taskBox.put(task.id, task); // Hive
      }
    } catch (_) {}
  }
}
