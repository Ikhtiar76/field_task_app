// ignore_for_file: use_build_context_synchronously

import 'package:field_task_app/core/utills/date_time_formats/date_time_formats.dart';
import 'package:field_task_app/core/utills/ui_helper.dart';
import 'package:flutter/material.dart';

class TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final String hintText;
  final double height;
  final DateTime? selectedDate;

  const TimePickerField({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.hintText = "Select Time...",
    this.height = 45,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        final now = TimeOfDay.now();
        final initialTime =
            (selectedDate != null &&
                selectedDate!.year == DateTime.now().year &&
                selectedDate!.month == DateTime.now().month &&
                selectedDate!.day == DateTime.now().day)
            ? (selectedTime != null && selectedTime!.hour >= now.hour
                  ? selectedTime!
                  : now)
            : (selectedTime ?? TimeOfDay.now());

        final tm = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ),
              child: child!,
            );
          },
        );

        if (tm != null) {
          if (selectedDate != null &&
              selectedDate!.year == DateTime.now().year &&
              selectedDate!.month == DateTime.now().month &&
              selectedDate!.day == DateTime.now().day) {
            if (tm.hour < now.hour ||
                (tm.hour == now.hour && tm.minute < now.minute)) {
              UIHelper.showSnackBar(
                context,
                'Cannot select past time for today',
                color: Colors.red,
              );
              return;
            }
          }
          onTimeSelected(tm);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[500], size: 18),
            SizedBox(width: screenWidth * .01),
            Text(
              selectedTime != null
                  ? DateTimeFormats.formatTime(selectedTime!)
                  : hintText,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
