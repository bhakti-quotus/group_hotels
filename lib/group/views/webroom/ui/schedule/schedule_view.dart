import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/group/views/webroom/controller/schedule_controller.dart';
import 'package:sunswept/group/views/webroom/model/schedule_event.dart';
// ─────────────────────────────────────────────────────────────────────────────
// ScheduleView — drop this anywhere inside a Scaffold body.
// It expects ScheduleController to already be registered via Get.put().
// ─────────────────────────────────────────────────────────────────────────────

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ScheduleController>();

    return Column(
      children: [
        SizedBox(height: 20,),
        _ScheduleHeader(ctrl: ctrl),
        Obx(() => ctrl.isWeekView.value
            ? _WeekStrip(ctrl: ctrl)
            : _MonthCalendar(ctrl: ctrl)),
        const Divider(height: 1, thickness: 1),
        Expanded(child: _TimelineView(ctrl: ctrl)),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget {
  final ScheduleController ctrl;
  const _ScheduleHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
           Text(
            'My schedule',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.primary),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TabButton(
                    label: 'WEEK',
                    selected: ctrl.isWeekView.value,
                    onTap: () => ctrl.isWeekView.value = true,
                  ),
                  const SizedBox(width: 32),
                  _TabButton(
                    label: 'MONTH',
                    selected: !ctrl.isWeekView.value,
                    onTap: () => ctrl.isWeekView.value = false,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: selected ? 40 : 0,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Week Strip ───────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final ScheduleController ctrl;
  const _WeekStrip({required this.ctrl});

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final days = ctrl.currentWeekDays;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                _monthYear(ctrl.selectedDate.value),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              )),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final day = days[i];
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;

              return GestureDetector(
                onTap: () => ctrl.selectedDate.value = day,
                child: Obx(() {
                  final isSel = day.year == ctrl.selectedDate.value.year &&
                      day.month == ctrl.selectedDate.value.month &&
                      day.day == ctrl.selectedDate.value.day;

                  return Column(
                    children: [
                      Text(
                        _labels[i],
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSel
                              ? Colors.red
                              : isToday
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSel
                                ? Colors.white
                                : isToday
                                    ? Colors.red
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _monthYear(DateTime d) {
    const m = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${m[d.month]}, ${d.year}';
  }
}

// ─── Month Calendar ───────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final ScheduleController ctrl;
  const _MonthCalendar({required this.ctrl});

  static const _headers = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        final grid = ctrl.monthGrid;
        final sel = ctrl.selectedDate.value;
        final now = DateTime.now();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _monthYear(sel),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _headers
                  .map((h) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(h,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            ...grid.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: row.map((day) {
                      if (day == null) {
                        return const SizedBox(width: 36, height: 36);
                      }
                      final isSel = day.year == sel.year &&
                          day.month == sel.month &&
                          day.day == sel.day;
                      final isToday = day.year == now.year &&
                          day.month == now.month &&
                          day.day == now.day;

                      return GestureDetector(
                        onTap: () => ctrl.selectedDate.value = day,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSel
                                ? Colors.red
                                : isToday ? Colors.red.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSel
                                  ? Colors.white
                                  : isToday
                                      ? Colors.red[700]
                                      : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),
          ],
        );
      }),
    );
  }

  String _monthYear(DateTime d) {
    const m = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${m[d.month]}, ${d.year}';
  }
}

// ─── Timeline View ────────────────────────────────────────────────────────────

class _TimelineView extends StatelessWidget {
  final ScheduleController ctrl;
  const _TimelineView({required this.ctrl});

  static const _hourHeight = 60.0;
  static const _startHour = 0;
  static const _endHour = 24;
  static const _timeColWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final events = ctrl.eventsForDate(ctrl.selectedDate.value);

      return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 80),
        child: SizedBox(
          height: (_endHour - _startHour) * _hourHeight,
          child: Stack(
            children: [
              // Hour rows
              ...List.generate(_endHour - _startHour, (i) {
                final hour = _startHour + i;
                return Positioned(
                  top: i * _hourHeight,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _timeColWidth,
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}.00',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(top: 8),
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Event blocks
              ...events.map((event) {
                final top =
                    (event.startHour - _startHour) * _hourHeight;
                final height =
                    (event.durationHours * _hourHeight).clamp(44.0, double.infinity);

                return Positioned(
                  top: top,
                  left: _timeColWidth + 4,
                  right: 0,
                  height: height,
                  child: _EventCard(event: event),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

class _EventCard extends StatelessWidget {
  final ScheduleEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.12),
        border: Border(
          left: BorderSide(color: event.color, width: 3),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: event.color),
          ),
          const SizedBox(height: 2),
          Text(
            event.timeRange,
            style: TextStyle(
                fontSize: 11,
                color: event.color.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}

// ─── Add Event Bottom Sheet (public helper) ───────────────────────────────────

/// Call this from any button/FAB to open the add-event sheet.
void showAddEventSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _AddEventSheet(),
  );
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet();

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _titleCtrl = TextEditingController();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  DateTime _date = DateTime.now();
  Color _color = Colors.blue;

  static const _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (context, child) {
  final theme = Theme.of(context);

  return Theme(
    data: theme.copyWith(
      useMaterial3: false,
      colorScheme: theme.colorScheme.copyWith(
        primary: AppColor.primary,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,

        // 👇 Selected time (hour/min)
        hourMinuteColor: AppColor.primary.withOpacity(0.12),
        hourMinuteTextColor: Colors.black,

        // 👇 AM/PM
        dayPeriodColor: Colors.grey.shade200,
        dayPeriodTextColor: Colors.black,

        // 👇 Clock dial
        dialBackgroundColor: Colors.grey.shade100,
        dialHandColor: AppColor.primary,
        dialTextColor: Colors.black,

        // 👇 Shape (modern UI)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        // 👇 Entry icon (keyboard icon)
        entryModeIconColor: AppColor.primary,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primary,
        ),
      ),
    ),
    child: child!,
  );
}
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:  ColorScheme.light(
              primary: AppColor.primary, // Main color for header and selected date
              onPrimary: Colors.white, // Text color on selected date
              surface: Colors.white, // Background color
              onSurface: Colors.black87, // Text color
              primaryContainer: Color(0xFFFFE5E5), // Light red for hover/container
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primary, // Button text color (Cancel/OK)
              ),
            ),
          
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final ctrl = Get.find<ScheduleController>();
    ctrl.addEvent(ScheduleEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: _date,
      startTime: _start,
      endTime: _end,
      color: _color,
    ));
    ctrl.selectedDate.value = _date;
    Navigator.pop(context);
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Add Schedule',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Title field
          TextField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Yoga, Team meeting…',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 4),

          // Date picker row
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined, size: 20),
            title: Text(_fmtDate(_date),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Date'),
            onTap: _pickDate,
          ),

          // Start / End time
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time, size: 20),
                  title: Text(_fmtTime(_start),
                      style:
                          const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Start'),
                  onTap: () => _pickTime(true),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_filled, size: 20),
                  title: Text(_fmtTime(_end),
                      style:
                          const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('End'),
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Text('Colour',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),

          // Color dots
          Row(
            children: _colorOptions.map((c) {
              final isSel = c.value == _color.value;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSel
                        ? Border.all(color: Colors.black87, width: 2.5)
                        : null,
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                                color: c.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                  child: isSel
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}