part of 'home_cubit.dart';

class HomeState extends Equatable {
  final List<TaskModel> tasks;

  const HomeState({required this.tasks});

  factory HomeState.initial() => const HomeState(tasks: []);

  HomeState copyWith({List<TaskModel>? tasks}) {
    return HomeState(tasks: tasks ?? this.tasks);
  }

  @override
  List<Object?> get props => [tasks];
}
