// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:field_task_app/core/utills/debugger/debugger.dart';
import 'package:field_task_app/core/widgets/submit_button.dart';
import 'package:field_task_app/features/task/presentation/blocs/create_task_bloc/create_task_bloc.dart';
import 'package:field_task_app/features/task/presentation/widgets/custom_textfiled.dart';
import 'package:field_task_app/features/task/presentation/widgets/date_picker.dart';
import 'package:field_task_app/features/task/presentation/widgets/map_view.dart';
import 'package:field_task_app/features/task/presentation/widgets/timer_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      body: SingleChildScrollView(
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
                  onChanged: (value) {
                    context.read<CreateTaskBloc>().add(TitleChanged(value));
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildSectionTitle('Due Time *'),
                SizedBox(height: screenHeight * 0.005),
                _buildDeadlineRow(context),
                SizedBox(height: screenHeight * 0.015),
                _buildSectionTitle('Parent Task', opt: '(Optional)'),
                SizedBox(height: screenHeight * 0.005),
                _buildDropDown(context),
                SizedBox(height: screenHeight * 0.015),
                _buildSectionTitle('Choose Location *'),
                SizedBox(height: screenHeight * 0.005),
                ReusableMap(
                  mode: MapMode.picker,
                  onPick: (loc) {
                    context.read<CreateTaskBloc>().add(LocationSelected(loc!));
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                BlocConsumer<CreateTaskBloc, CreateTaskState>(
                  listener: (context, state) {
                    if (state.isSuccess) {
                      Navigator.pop(context);
                    }

                    if (state.error != null && state.error!.isNotEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error!)));
                    }
                  },
                  builder: (context, state) {
                    return SubmitButton(
                      text: state.isSubmitting ? null : "+ Add Task",
                      isLoading: state.isSubmitting,
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              context.read<CreateTaskBloc>().add(SubmitTask());
                            },
                      color: Colors.blue,
                    );
                  },
                ),

                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ),
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
                context.read<CreateTaskBloc>().add(TimeSelected(time));
              },
              selectedTime: state.selectedTime,
              height: 45,
            ),
            SizedBox(width: screenWidth * .01),
            DatePickerField(
              onDateSelected: (date) {
                context.read<CreateTaskBloc>().add(DateSelected(date));
              },
              selectedDate: state.selectedDate,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropDown(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          onChanged: (value) {},
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
          items: [],
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
