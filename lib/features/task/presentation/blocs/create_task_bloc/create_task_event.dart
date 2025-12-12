part of 'create_task_bloc.dart';

abstract class CreateTaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitTaskBox extends CreateTaskEvent {}

class FetchAllTaskEvent extends CreateTaskEvent {}

class CreateNewTaskEvent extends CreateTaskEvent {
  final TaskModel task;
  CreateNewTaskEvent({required this.task});
}

class UpdateTaskEvent extends CreateTaskEvent {
  final TaskModel task;
  UpdateTaskEvent({required this.task});
}
