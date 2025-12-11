// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:field_task_app/core/utills/debugger/debugger.dart';
import 'package:field_task_app/features/task/presentation/widgets/map_view.dart';
import 'package:flutter/material.dart';

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
        physics: const BouncingScrollPhysics(),
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
                _buildTitleField(context),
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
                ReusableMap(mode: MapMode.picker, onPick: (loc) {}),
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

  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: 'Enter task title...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      style: const TextStyle(fontSize: 12, color: Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }

  Widget _buildDeadlineRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        _buildTimePicker(context),
        SizedBox(width: screenWidth * .01),
        _buildDatePicker(context),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final dt = await showDatePicker(
            context: context,
            firstDate: DateTime.now().subtract(Duration(days: 365)),
            lastDate: DateTime.now().add(Duration(days: 365)),
            initialDate: DateTime.now(),
          );
          if (dt != null) {
            setState(() {
              _selectedDate = dt;
            });
          }
        },
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Colors.grey[500],
                size: 18,
              ),
              SizedBox(width: screenWidth * .01),
              Text(
                _selectedDate?.toIso8601String() ?? 'Select date...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        final tm = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (tm != null) {
          setState(() => _selectedTime = tm);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.access_time, color: Colors.grey[500], size: 18),
            SizedBox(width: screenWidth * .01),
            Text(
              _selectedTime != null
                  ? _formatTime(_selectedTime!)
                  : 'Select Time...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _titleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
