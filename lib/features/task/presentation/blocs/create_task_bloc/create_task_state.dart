part of 'create_task_bloc.dart';

class CreateTaskState extends Equatable {
  const CreateTaskState();
  @override
  List<Object> get props => [];
}

class TasksInitial extends CreateTaskState {}

class TasksLoading extends CreateTaskState {}

class TasksLoaded extends CreateTaskState {
  final List<TaskModel> taskList;
  const TasksLoaded({required this.taskList});
}

class TasksError extends CreateTaskState {
  final String error;
  const TasksError({required this.error});
}
