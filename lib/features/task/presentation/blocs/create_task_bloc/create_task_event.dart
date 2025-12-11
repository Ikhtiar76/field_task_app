part of 'create_task_bloc.dart';

abstract class CreateTaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TitleChanged extends CreateTaskEvent {
  final String title;
  TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class DateSelected extends CreateTaskEvent {
  final DateTime date;
  DateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

class TimeSelected extends CreateTaskEvent {
  final TimeOfDay time;
  TimeSelected(this.time);

  @override
  List<Object?> get props => [time];
}

class LocationSelected extends CreateTaskEvent {
  final LatLng location;
  LocationSelected(this.location);

  @override
  List<Object?> get props => [location];
}

class SubmitTask extends CreateTaskEvent {}

class UpdateTaskStatus extends CreateTaskEvent {
  final TaskModel task;
  final String newStatus;

  UpdateTaskStatus({required this.task, required this.newStatus});
}
