import 'package:flutter/material.dart';

class DateTimeFormats {
  static String formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:${t.minute.toString().padLeft(2, '0')} $period";
  }
}
