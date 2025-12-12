// ignore_for_file: deprecated_member_use, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:field_task_app/core/models/task_model.dart';
import 'package:field_task_app/core/utills/date_time_formats/date_time_formats.dart';
import 'package:field_task_app/core/utills/debugger/debugger.dart';
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state is TasksLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.fixed,
                backgroundColor: Colors.green,
                content: Text('Successfully Task Created!'),
                duration: Duration(seconds: 2),
              ),
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
                    _buildSectionTitle('Parent Task', opt: '(Optional)'),
                    SizedBox(height: screenHeight * 0.005),
                    if (taskList != null && taskList!.isNotEmpty)
                      CustomDropdown(
                        value: selectedTaskId,
                        items: taskList ?? [],
                        onChanged: (val) {
                          setState(() {
                            selectedTaskId = val;
                          });
                          Debugger("Selected: $val");
                        },
                      ),
                    SizedBox(height: screenHeight * 0.015),
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
                      onPressed: () {
                        List<String> missingFields = [];

                        if (_titleController.text.isEmpty)
                          missingFields.add('Title');
                        if (_selectedDate == null) missingFields.add('Date');
                        if (_selectedTime == null) missingFields.add('Time');
                        if (_latLng == null) missingFields.add('Location');
                        if (missingFields.isEmpty) {
                          final task = TaskModel(
                            title: _titleController.text,
                            id: Uuid().v4(),
                            dueDate: _selectedDate.toString(),
                            dueTime: DateTimeFormats.formatTime(
                              _selectedTime!,
                            ).toString(),
                            parentTaskId: selectedTaskId,
                            latitude: _latLng?.latitude,
                            longitude: _latLng?.longitude,
                            status: 'Pending',
                          );
                          context.read<CreateTaskBloc>().add(
                            CreateNewTaskEvent(task: task),
                          );
                        } else {
                          final missing = missingFields.join(', ');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please provide the following required (*) fields: $missing',
                              ),
                              behavior: SnackBarBehavior.fixed,
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
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
            color: Colors.black87,
          ),
        ),
        SizedBox(width: screenWidth * .01),
        if (opt != null)
          Text(
            opt,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
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

  Widget _buildDropDown(BuildContext context, List<TaskModel> taskList) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          onChanged: (value) {
            // TODO: handle selected value
            print("Selected task id: $value");
          },
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[500],
              size: 24,
            ),
          ),
          hint: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(Icons.link, color: Colors.grey[500], size: 18),
                SizedBox(width: 8),
                Text(
                  'Select task...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // FIXED ITEMS
          items: taskList.map((task) {
            return DropdownMenuItem<String>(
              value: task.id, // unique value required
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(task.title, style: TextStyle(fontSize: 13)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
