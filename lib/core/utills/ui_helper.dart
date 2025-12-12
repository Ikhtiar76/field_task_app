import 'package:flutter/material.dart';

class UIHelper {
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: color ?? Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
