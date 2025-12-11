part of 'create_task_bloc.dart';

class CreateTaskState extends Equatable {
  final String title;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final LatLng? selectedLocation;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const CreateTaskState({
    this.title = '',
    this.selectedDate,
    this.selectedTime,
    this.selectedLocation,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  CreateTaskState copyWith({
    String? title,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    LatLng? selectedLocation,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return CreateTaskState(
      title: title ?? this.title,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    title,
    selectedDate,
    selectedTime,
    selectedLocation,
    isSubmitting,
    isSuccess,
    error,
  ];
}
