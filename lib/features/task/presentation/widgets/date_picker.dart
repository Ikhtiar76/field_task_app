import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String hint;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.hint = 'Select date...',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final dt = await showDatePicker(
            context: context,
            firstDate: DateTime.now(), // prevent selecting past dates
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDate:
                selectedDate != null && selectedDate!.isAfter(DateTime.now())
                ? selectedDate!
                : DateTime.now(),
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
          if (dt != null) {
            onDateSelected(dt);
          }
        },
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Colors.grey[700],
                size: 18,
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                selectedDate != null
                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                    : hint,
                style: TextStyle(
                  fontSize: 12,
                  color: selectedDate != null ? Colors.black : Colors.grey[500],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
