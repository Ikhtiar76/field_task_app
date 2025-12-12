import 'package:field_task_app/core/constants/colors.dart';
import 'package:field_task_app/core/models/task_model.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<TaskModel> items;
  final String hint;
  final Function(String?) onChanged;
  final double borderRadius;
  final Color fillColor;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = "Select task...",
    this.borderRadius = 6,
    this.fillColor = white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: grey.withOpacity(0.5),
            size: 22,
          ),

          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: grey.withOpacity(0.5)),
          ),

          style: const TextStyle(fontSize: 12, color: black),

          onChanged: onChanged,

          items: items.map((task) {
            return DropdownMenuItem<String>(
              value: task.id,
              child: Text(task.title, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
