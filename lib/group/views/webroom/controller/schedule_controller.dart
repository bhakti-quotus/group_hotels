import 'package:get/get.dart';
import 'package:sunswept/group/views/webroom/model/schedule_event.dart';

class ScheduleController extends GetxController {
  final events = <ScheduleEvent>[].obs;
  final selectedDate = DateTime.now().obs;
  final isWeekView = true.obs;

  void addEvent(ScheduleEvent event) => events.add(event);

  List<ScheduleEvent> eventsForDate(DateTime date) => events
      .where((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day)
      .toList();

  /// Mon–Sun week containing [selectedDate]
  List<DateTime> get currentWeekDays {
    final now = selectedDate.value;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Calendar grid rows (Mon-start, 7 cols)
  List<List<DateTime?>> get monthGrid {
    final d = selectedDate.value;
    final firstDay = DateTime(d.year, d.month, 1);
    final lastDay = DateTime(d.year, d.month + 1, 0);
    final startOffset = firstDay.weekday - 1; // Mon = 0
    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int i = 1; i <= lastDay.day; i++) {
      cells.add(DateTime(d.year, d.month, i));
    }
    while (cells.length % 7 != 0) cells.add(null);
    final rows = <List<DateTime?>>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }
    return rows;
  }
}