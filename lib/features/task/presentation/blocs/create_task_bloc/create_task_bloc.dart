import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';

part 'create_task_event.dart';
part 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  CreateTaskBloc() : super(CreateTaskState()) {
    on<TitleChanged>((event, emit) => emit(state.copyWith(title: event.title)));
    on<DateSelected>(
      (event, emit) => emit(state.copyWith(selectedDate: event.date)),
    );
    on<TimeSelected>(
      (event, emit) => emit(state.copyWith(selectedTime: event.time)),
    );
    on<LocationSelected>(
      (event, emit) => emit(state.copyWith(selectedLocation: event.location)),
    );
    on<SubmitTask>((event, emit) async {
      if (state.title.isEmpty || state.selectedLocation == null) {
        emit(state.copyWith(error: "Title or location cannot be empty"));
        return;
      }

      emit(state.copyWith(isSubmitting: true));

      try {
        final box = Hive.box<TaskModel>('tasks');

        final task = TaskModel(
          title: state.title,
          dueDate: state.selectedDate,
          dueHour: state.selectedTime?.hour,
          dueMinute: state.selectedTime?.minute,
          latitude: state.selectedLocation?.latitude,
          longitude: state.selectedLocation?.longitude,
        );

        await box.add(task);

        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isSubmitting: false, error: e.toString()));
      }
    });
  }
}
