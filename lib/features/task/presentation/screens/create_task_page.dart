// ignore_for_file: deprecated_member_use, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:field_task_app/core/constants/colors.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/core/utills/date_time_formats/date_time_formats.dart';
import 'package:field_task_app/core/utills/debugger/debugger.dart';
import 'package:field_task_app/core/utills/ui_helper.dart';
import 'package:field_task_app/core/widgets/custom_button.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/widgets/custom_dropdown.dart';
import 'package:field_task_app/features/task/presentation/widgets/custom_textfiled.dart';
import 'package:field_task_app/features/task/presentation/widgets/date_picker.dart';
import 'package:field_task_app/features/task/presentation/widgets/map_view.dart';
import 'package:field_task_app/features/task/presentation/widgets/timer_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});
  static const id = 'create_task_page';

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _latLng;
  List<TaskModel>? taskList;
  String? selectedTaskId;

  @override
  Widget build(BuildContext context) {
    Debugger('buld...');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: white,
        foregroundColor: black,
      ),
      body: BlocConsumer<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state is TasksLoaded) {
            UIHelper.showSnackBar(
              context,
              'Successfully Task Created!',
              color: Colors.green,
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is TasksLoaded) {
            taskList = state.taskList;
          }
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Task Title *'),
                    SizedBox(height: screenHeight * 0.005),
                    CustomTextField(
                      controller: _titleController,
                      hint: 'Enter the task...',
                      onChanged: (value) {},
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildSectionTitle('Due Time *'),
                    SizedBox(height: screenHeight * 0.005),
                    _buildDeadlineRow(context),
                    SizedBox(height: screenHeight * 0.015),

                    if (taskList != null && taskList!.isNotEmpty) ...[
                      _buildSectionTitle('Parent Task', opt: '(Optional)'),
                      SizedBox(height: screenHeight * 0.005),

                      CustomDropdown(
                        value: selectedTaskId,
                        items: (taskList ?? [])
                            .where(
                              (task) =>
                                  task.status.toLowerCase() != 'completed',
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedTaskId = val;
                          });
                          Debugger("Selected: $val");
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),
                    ],

                    _buildSectionTitle('Choose Location *'),
                    SizedBox(height: screenHeight * 0.005),
                    ReusableMap(
                      mode: MapMode.picker,
                      onPick: (loc) {
                        setState(() => _latLng = loc);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    CustomButton(
                      text: state is TasksLoading ? null : "+ Add Task",
                      isLoading: state is TasksLoading,
                      onPressed: _onAddTaskPressed,
                      color: Colors.blue,
                    ),

                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? opt}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: black,
          ),
        ),
        SizedBox(width: screenWidth * .01),
        if (opt != null)
          Text(
            opt,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: grey.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildDeadlineRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<CreateTaskBloc, CreateTaskState>(
      builder: (context, state) {
        return Row(
          children: [
            TimePickerField(
              onTimeSelected: (time) {
                setState(() => _selectedTime = time);
              },
              selectedTime: _selectedTime,
              height: 45,
            ),
            SizedBox(width: screenWidth * .01),
            DatePickerField(
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
              selectedDate: _selectedDate,
            ),
          ],
        );
      },
    );
  }

  void _onAddTaskPressed() {
    final missingFields = <String>[];
    if (_titleController.text.isEmpty) missingFields.add('Title');
    if (_selectedDate == null) missingFields.add('Date');
    if (_selectedTime == null) missingFields.add('Time');
    if (_latLng == null) missingFields.add('Location');

    if (missingFields.isNotEmpty) {
      UIHelper.showSnackBar(
        context,
        'Please provide the following required (*) fields: ${missingFields.join(', ')}',
        color: red,
      );
      return;
    }

    final task = TaskModel(
      title: _titleController.text,
      id: Uuid().v4(),
      dueDate: _selectedDate.toString(),
      dueTime: DateTimeFormats.formatTime(_selectedTime!).toString(),
      parentTaskId: selectedTaskId,
      latitude: _latLng?.latitude,
      longitude: _latLng?.longitude,
      status: 'Pending',
    );

    context.read<CreateTaskBloc>().add(CreateNewTaskEvent(task: task));
  }

  @override
  void dispose() {
    _titleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
