import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/features/task/data/repositories/task_hive_repository.dart';

part 'create_task_event.dart';
part 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  final TaskHiveRepository taskHiveRepository;
  CreateTaskBloc({required this.taskHiveRepository}) : super(TasksInitial()) {
    on<InitTaskBox>(_initTaskBox);
    on<FetchAllTaskEvent>(_fetchAllTask);
    on<CreateNewTaskEvent>(_createNewTask);
    on<UpdateTaskEvent>(_updateTask);
  }

  FutureOr<void> _fetchAllTask(
    FetchAllTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      emit(TasksLoading());
      final taskList = taskHiveRepository.getTasks();
      emit(TasksLoaded(taskList: taskList));
    } catch (e) {
      emit(TasksError(error: e.toString()));
    }
  }

  FutureOr<void> _initTaskBox(
    InitTaskBox event,
    Emitter<CreateTaskState> emit,
  ) async {
    await taskHiveRepository.init();
    add(FetchAllTaskEvent());
  }

  FutureOr<void> _createNewTask(
    CreateNewTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      emit(TasksLoading());
      final newTaskList = await taskHiveRepository.createTasks(event.task);
      emit(TasksLoaded(taskList: newTaskList));
    } catch (e) {
      emit(TasksError(error: e.toString()));
    }
  }

  FutureOr<void> _updateTask(
    UpdateTaskEvent event,
    Emitter<CreateTaskState> emit,
  ) async {
    try {
      emit(TasksLoading());
      final updatedTaskList = await taskHiveRepository.updateTasks(event.task);
      emit(TasksLoaded(taskList: updatedTaskList));
    } catch (e) {
      emit(TasksError(error: e.toString()));
    }
  }
}
