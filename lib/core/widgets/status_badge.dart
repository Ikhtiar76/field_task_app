import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.toLowerCase() == "completed"
        ? Colors.green
        : status.toLowerCase() == "in progress"
        ? Colors.blue
        : Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 10, color: color),
          SizedBox(width: 3),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
