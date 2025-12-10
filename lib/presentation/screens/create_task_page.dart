import 'package:flutter/material.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});
  static const id = 'create_task_page';

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TimeOfDay? _selectedTime;

  bool _isTimeSelected = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task saved successfully!')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.03,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Task Title *'),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTitleField(context),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSectionTitle('Description'),
                  SizedBox(height: screenHeight * 0.01),
                  _buildDescriptionField(context),
                  SizedBox(height: screenHeight * 0.03),
                  Divider(color: Colors.grey[300], thickness: 1, height: 20),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSectionTitle('Due Time *'),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTimePicker(context),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: 'Enter task title...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Add task details...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(fontSize: 15, color: Colors.black87),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(primary: Colors.blueGrey),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          setState(() {
            _selectedTime = pickedTime;
            _isTimeSelected = true;
          });
        }
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isTimeSelected ? Colors.blue : Colors.grey[300]!,
            width: _isTimeSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.access_time,
                color: _isTimeSelected ? Colors.blue : Colors.grey[500],
                size: 22,
              ),
            ),
            Text(
              _isTimeSelected ? _formatTime(_selectedTime!) : '--:--',
              style: TextStyle(
                fontSize: 16,
                color: _isTimeSelected ? Colors.black87 : Colors.grey[500],
                fontWeight: _isTimeSelected
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (_isTimeSelected)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedTime = null;
                    _isTimeSelected = false;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
              ),
          ],
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
    _descriptionController.dispose();
    super.dispose();
  }
}
