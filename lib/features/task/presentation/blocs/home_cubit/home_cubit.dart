import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'home_state.dart';

// class HomeCubit extends Cubit<HomeState> {
//   final Box<TaskModel> taskBox;

//   HomeCubit(this.taskBox) : super(HomeState.initial()) {
//     loadTasks();
//   }

//   void loadTasks() {
//     final tasks = taskBox.values.toList();

//     emit(state.copyWith(tasks: tasks));
//   }
// }
