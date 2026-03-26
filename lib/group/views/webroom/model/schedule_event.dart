import 'package:flutter/material.dart';

class ScheduleEvent {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  String get timeRange =>
      '${_fmt(startTime)}-${_fmt(endTime)}';

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  double get startHour => startTime.hour + startTime.minute / 60.0;

  double get durationHours =>
      (endTime.hour + endTime.minute / 60.0) - startHour;
}