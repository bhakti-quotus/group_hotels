import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart'; 
import 'package:group/group/controllers/search_controller.dart' as search_ctrl;

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH WIDGET
// ═══════════════════════════════════════════════════════════════════════════════
class SearchWidget extends StatefulWidget {
  final bool update;
  final bool showEditText;
  final VoidCallback? onModifySearch;

  const SearchWidget({
    Key? key,
    this.update = false,
    this.showEditText = false,
    this.onModifySearch,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  DateTime checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime checkOut = DateTime.now().add(const Duration(days: 2));
  int rooms = 1;
  List<Map<String, int>> roomGuests = [];
  String propertyCode = '';
  final TextEditingController _promoController = TextEditingController();
  String promocode = '';

  // Overlays
  OverlayEntry? _occupancyOverlay;
  OverlayEntry? _calendarOverlay;
  final LayerLink _occupancyLayerLink = LayerLink();
  final LayerLink _calendarLayerLink = LayerLink();

  // Get HotelController
  late final HotelController _hotelController;

  Color get _primary => AppColor.primary;
  Color get _secondary => AppColor.secondary;

  int get totalAdults => roomGuests.fold(0, (s, r) => s + r['adults']!);
  int get totalChildren => roomGuests.fold(0, (s, r) => s + r['children']!);
  int get totalGuests => totalAdults + totalChildren;
  int get remainingSlots => (3 * rooms) - totalGuests;
  int get totalNights => checkOut.difference(checkIn).inDays;

  @override
  void initState() {
    super.initState();
    _hotelController = Get.find<HotelController>();
    roomGuests = List.generate(rooms, (_) => {'adults': 1, 'children': 0});
    _loadPropertyCode();
    _loadFromController();
  }

  @override
  void dispose() {
    _removeOccupancyOverlay();
    _removeCalendarOverlay();
    _promoController.dispose();
    super.dispose();
  }

  void _loadPropertyCode() {
    try {
      // Get property code from HotelController instead of loading from assets
      final hotelData = _hotelController.selectedHotel.value;
      if (hotelData != null) {
        setState(() {
          propertyCode = hotelData['code'] ?? '';
        });
        debugPrint('✅ Property code loaded from controller: $propertyCode');
      } else {
        debugPrint('⚠️ Hotel data not available in controller');
      }
    } catch (e) {
      debugPrint('❌ Error loading property code from controller: $e');
    }
  }

  void _loadFromController() {
    try {
      final sc = Get.find<search_ctrl.AppSearchController>();
      if (sc.searchPayload.isNotEmpty) {
        final p = Map<String, dynamic>.from(sc.searchPayload.value);
        if (p['startDate'] != null) checkIn = DateTime.parse(p['startDate']);
        if (p['endDate'] != null) checkOut = DateTime.parse(p['endDate']);
        final g = p['guests'] as Map<String, dynamic>?;
        if (g != null) {
          rooms = g['rooms'] as int? ?? 1;
          final ra = g['roomsArray'] as List?;
          if (ra != null && ra.isNotEmpty) {
            roomGuests = ra
                .map(
                  (r) => {
                    'adults': (r['adults'] as int?) ?? 1,
                    'children': (r['children'] as int?) ?? 0,
                  },
                )
                .toList();
          }
        }
        if (p['promocode'] != null) {
          promocode = p['promocode'] as String;
          _promoController.text = promocode;
        }
      }
    } catch (e) {
      debugPrint('Error loading from controller: $e');
    }
  }

  void updateRooms(int v) {
    setState(() {
      rooms = v;
      if (v > roomGuests.length) {
        roomGuests.addAll(
          List.generate(
            v - roomGuests.length,
            (_) => {'adults': 1, 'children': 0},
          ),
        );
      } else if (v < roomGuests.length) {
        roomGuests = roomGuests.sublist(0, v);
      }
    });
    _occupancyOverlay?.markNeedsBuild();
  }

  void updateAdults(int i, int v) {
    if (v + roomGuests[i]['children']! <= 3 && v >= 1) {
      setState(() => roomGuests[i]['adults'] = v);
      _occupancyOverlay?.markNeedsBuild();
    }
  }

  void updateChildren(int i, int v) {
    if (roomGuests[i]['adults']! + v <= 3 && v >= 0) {
      setState(() => roomGuests[i]['children'] = v);
      _occupancyOverlay?.markNeedsBuild();
    }
  }

  Map<String, dynamic> getSearchPayload() => {
    "PropertyCode": propertyCode,
    "startDate": checkIn.toIso8601String().split('T')[0],
    "endDate": checkOut.toIso8601String().split('T')[0],
    "adults": totalAdults,
    "children": totalChildren,
    "rooms": rooms,
    "location": "",
    "numberOfRooms": rooms,
    "promocode": promocode.trim(),
    "guests": {
      "adults": totalAdults,
      "children": totalChildren,
      "rooms": rooms,
      "roomsArray": roomGuests
          .map((r) => {"adults": r['adults'], "children": r['children']})
          .toList(),
    },
  };

  String _month(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];

  void _performSearch() {
    _removeOccupancyOverlay();
    _removeCalendarOverlay();
    Get.find<search_ctrl.AppSearchController>().updateSearchPayload(
      getSearchPayload(),
    );
    if (widget.showEditText && widget.onModifySearch != null) {
      widget.onModifySearch!();
    } else {
      Get.toNamed('/rooms');
    }
  }

  // ── CALENDAR OVERLAY ───────────────────────────────────────────────────────

  void _removeCalendarOverlay() {
    _calendarOverlay?.remove();
    _calendarOverlay = null;
    if (mounted) setState(() {});
  }

  void _toggleCalendar() {
    if (_calendarOverlay != null) {
      _removeCalendarOverlay();
      return;
    }
    _removeOccupancyOverlay();
    _calendarOverlay = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeCalendarOverlay,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _calendarLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 6),
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _CompactCalendar(
                    primary: _primary,
                    secondary: _secondary,
                    checkIn: checkIn,
                    checkOut: checkOut,
                    onRangeSelected: (start, end) {
                      setState(() {
                        checkIn = start;
                        checkOut = end;
                      });
                      _removeCalendarOverlay();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_calendarOverlay!);
    setState(() {});
  }

  // ── OCCUPANCY OVERLAY ──────────────────────────────────────────────────────

  void _removeOccupancyOverlay() {
    _occupancyOverlay?.remove();
    _occupancyOverlay = null;
    if (mounted) setState(() {});
  }

  void _toggleOccupancy() {
    if (_occupancyOverlay != null) {
      _removeOccupancyOverlay();
      return;
    }
    _removeCalendarOverlay();
    _occupancyOverlay = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOccupancyOverlay,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _occupancyLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 6),
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _OccupancyDropdown(
                    primary: _primary,
                    secondary: _secondary,
                    rooms: rooms,
                    roomGuests: roomGuests,
                    remainingSlots: remainingSlots,
                    onUpdateRooms: updateRooms,
                    onUpdateAdults: updateAdults,
                    onUpdateChildren: updateChildren,
                    onDone: _removeOccupancyOverlay,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_occupancyOverlay!);
    setState(() {});
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final calOpen = _calendarOverlay != null;
    final occOpen = _occupancyOverlay != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.hotel_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Search Rooms',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        size: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$totalNights ${totalNights == 1 ? 'Night' : 'Nights'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // ── Dates (single tap opens compact calendar) ─────────────
                CompositedTransformTarget(
                  link: _calendarLayerLink,
                  child: GestureDetector(
                    onTap: _toggleCalendar,
                    child: Container(
                      decoration: BoxDecoration(
                        color: calOpen
                            ? _primary.withOpacity(0.04)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: calOpen ? _primary : Colors.grey.shade200,
                          width: calOpen ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Check-in
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flight_land_rounded,
                                        size: 10,
                                        color: _secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'CHECK-IN',
                                        style: TextStyle(
                                          fontSize: 9,
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: _primary.withOpacity(0.45),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${checkIn.day}',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          color: _primary,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 3,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _month(checkIn.month),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: _secondary,
                                                height: 1,
                                              ),
                                            ),
                                            Text(
                                              '${checkIn.year}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Divider + nights badge
                          Column(
                            children: [
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$totalNights N',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: _secondary,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                            ],
                          ),

                          // Check-out
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 10, 12, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'CHECK-OUT',
                                        style: TextStyle(
                                          fontSize: 9,
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: _primary.withOpacity(0.45),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.flight_takeoff_rounded,
                                        size: 10,
                                        color: _secondary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 3,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _month(checkOut.month),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: _secondary,
                                                height: 1,
                                              ),
                                            ),
                                            Text(
                                              '${checkOut.year}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${checkOut.day}',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          color: _primary,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Occupancy ─────────────────────────────────────────────
                CompositedTransformTarget(
                  link: _occupancyLayerLink,
                  child: GestureDetector(
                    onTap: _toggleOccupancy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: occOpen
                            ? _primary.withOpacity(0.04)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: occOpen ? _primary : Colors.grey.shade200,
                          width: occOpen ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 17,
                            color: occOpen ? _primary : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OCCUPANCY',
                                  style: TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: _primary.withOpacity(0.45),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$rooms ${rooms == 1 ? 'Room' : 'Rooms'}'
                                  '  ·  $totalAdults ${totalAdults == 1 ? 'Adult' : 'Adults'}'
                                  '${totalChildren > 0 ? '  ·  $totalChildren ${totalChildren == 1 ? 'Child' : 'Children'}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            occOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: _primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Promo code ────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: promocode.isNotEmpty
                          ? _secondary.withOpacity(0.55)
                          : Colors.grey.shade200,
                      width: promocode.isNotEmpty ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          size: 17,
                          color: promocode.isNotEmpty
                              ? _secondary
                              : Colors.grey.shade400,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'PROMO CODE',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: _primary.withOpacity(0.45),
                              ),
                            ),
                            TextField(
                              controller: _promoController,
                              onChanged: (v) => setState(() => promocode = v),
                              textCapitalization: TextCapitalization.characters,
                              cursorColor: _primary, 
                              decoration: InputDecoration(
                                hintText: 'Enter code for discount',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                                
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.only(
                                  bottom: 10,
                                  top: 2,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (promocode.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() {
                            promocode = '';
                            _promoController.clear();
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 14),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Book Now ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.showEditText ? 'UPDATE SEARCH' : 'BOOK NOW',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPACT CALENDAR  —  custom date-range picker popup
// ═══════════════════════════════════════════════════════════════════════════════
class _CompactCalendar extends StatefulWidget {
  final Color primary;
  final Color secondary;
  final DateTime checkIn;
  final DateTime checkOut;
  final void Function(DateTime start, DateTime end) onRangeSelected;

  const _CompactCalendar({
    required this.primary,
    required this.secondary,
    required this.checkIn,
    required this.checkOut,
    required this.onRangeSelected,
  });

  @override
  State<_CompactCalendar> createState() => _CompactCalendarState();
}

class _CompactCalendarState extends State<_CompactCalendar> {
  late DateTime _viewMonth; // month currently shown
  DateTime? _start; // first tap
  DateTime? _end; // second tap

  static const List<String> _weekDays = [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _start = widget.checkIn;
    _end = widget.checkOut;
    _viewMonth = DateTime(widget.checkIn.year, widget.checkIn.month);
  }

  void _prevMonth() => setState(
    () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1),
  );

  void _nextMonth() => setState(
    () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1),
  );

  void _onDayTap(DateTime day) {
    final today = DateTime.now();
    if (day.isBefore(DateTime(today.year, today.month, today.day))) return;

    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        // Start fresh selection
        _start = day;
        _end = null;
      } else {
        // Second tap
        if (day.isBefore(_start!)) {
          _end = _start;
          _start = day;
        } else if (day.isAtSameMomentAs(_start!)) {
          // Same day — auto-set checkout to next day
          _end = _start!.add(const Duration(days: 1));
        } else {
          _end = day;
        }
        // Confirm and close
        widget.onRangeSelected(_start!, _end!);
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime day) {
    if (_start == null || _end == null) return false;
    return day.isAfter(_start!) && day.isBefore(_end!);
  }

  bool _isStart(DateTime day) => _start != null && _isSameDay(day, _start!);
  bool _isEnd(DateTime day) => _end != null && _isSameDay(day, _end!);

  bool _isPast(DateTime day) {
    final today = DateTime.now();
    return day.isBefore(DateTime(today.year, today.month, today.day));
  }

  List<DateTime?> _buildDays() {
    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // 0=Sun

    final List<DateTime?> cells = [];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_viewMonth.year, _viewMonth.month, d));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cells = _buildDays();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth - 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: widget.primary.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Month nav ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                border: Border(
                  bottom: BorderSide(color: widget.primary.withOpacity(0.08)),
                ),
              ),
              child: Row(
                children: [
                  _NavBtn(
                    icon: Icons.chevron_left_rounded,
                    onTap: _prevMonth,
                    primary: widget.primary,
                  ),
                  Expanded(
                    child: Text(
                      '${_months[_viewMonth.month - 1]} ${_viewMonth.year}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: widget.primary,
                      ),
                    ),
                  ),
                  _NavBtn(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextMonth,
                    primary: widget.primary,
                  ),
                ],
              ),
            ),

            // ── Selection hint ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  _DateChip(
                    label: 'Check-in',
                    date: _start,
                    primary: widget.primary,
                    secondary: widget.secondary,
                    isActive: _end == null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  _DateChip(
                    label: 'Check-out',
                    date: _end,
                    primary: widget.primary,
                    secondary: widget.secondary,
                    isActive: _start != null && _end == null,
                  ),
                ],
              ),
            ),

            // ── Week header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: _weekDays
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.primary.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 4),

            // ── Day grid ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: cells.map((day) {
                  if (day == null) return const SizedBox();

                  final isStart = _isStart(day);
                  final isEnd = _isEnd(day);
                  final inRange = _isInRange(day);
                  final isPast = _isPast(day);
                  final isToday = _isSameDay(day, DateTime.now());

                  Color? bgColor;
                  Color textColor = Colors.black87;
                  BorderRadius borderRadius = BorderRadius.circular(8);

                  if (isStart || isEnd) {
                    bgColor = widget.primary;
                    textColor = Colors.white;
                    borderRadius = isStart
                        ? const BorderRadius.horizontal(
                            left: Radius.circular(10),
                            right: Radius.circular(4),
                          )
                        : const BorderRadius.horizontal(
                            left: Radius.circular(4),
                            right: Radius.circular(10),
                          );
                  } else if (inRange) {
                    bgColor = widget.primary.withOpacity(0.10);
                    textColor = widget.primary;
                    borderRadius = BorderRadius.zero;
                  }

                  if (isPast) textColor = Colors.grey.shade300;

                  return GestureDetector(
                    onTap: isPast ? null : () => _onDayTap(day),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: borderRadius,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isStart || isEnd
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            if (isToday && !isStart && !isEnd)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: widget.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ── Small date chip shown inside calendar header ──────────────────────────────
class _DateChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Color primary;
  final Color secondary;
  final bool isActive;

  const _DateChip({
    required this.label,
    required this.date,
    required this.primary,
    required this.secondary,
    required this.isActive,
  });

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? primary.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? primary.withOpacity(0.3) : Colors.grey.shade200,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: primary.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 2),
            date != null
                ? Text(
                    '${date!.day} ${_months[date!.month - 1]} ${date!.year}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive ? primary : Colors.black87,
                    ),
                  )
                : Text(
                    'Select',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Month nav button ──────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primary;

  const _NavBtn({
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: primary),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OCCUPANCY DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════
class _OccupancyDropdown extends StatefulWidget {
  final Color primary;
  final Color secondary;
  final int rooms;
  final List<Map<String, int>> roomGuests;
  final int remainingSlots;
  final void Function(int) onUpdateRooms;
  final void Function(int, int) onUpdateAdults;
  final void Function(int, int) onUpdateChildren;
  final VoidCallback onDone;

  const _OccupancyDropdown({
    required this.primary,
    required this.secondary,
    required this.rooms,
    required this.roomGuests,
    required this.remainingSlots,
    required this.onUpdateRooms,
    required this.onUpdateAdults,
    required this.onUpdateChildren,
    required this.onDone,
  });

  @override
  State<_OccupancyDropdown> createState() => _OccupancyDropdownState();
}

class _OccupancyDropdownState extends State<_OccupancyDropdown> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 24;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: w,
        constraints: const BoxConstraints(maxHeight: 430),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: widget.primary.withOpacity(0.13),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with rooms counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: widget.primary.withOpacity(0.08)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.meeting_room_rounded,
                    size: 16,
                    color: widget.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rooms',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: widget.primary,
                    ),
                  ),
                  const Spacer(),
                  _CounterButtons(
                    value: widget.rooms,
                    onDec: () => widget.onUpdateRooms(
                      widget.rooms > 1 ? widget.rooms - 1 : 1,
                    ),
                    onInc: () => widget.onUpdateRooms(widget.rooms + 1),
                    minusEnabled: widget.rooms > 1,
                    addEnabled: widget.rooms < 10,
                    primary: widget.primary,
                    size: 28,
                    iconSize: 14,
                    fontSize: 14,
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ...List.generate(widget.rooms, (idx) {
                      final adults = widget.roomGuests[idx]['adults']!;
                      final children = widget.roomGuests[idx]['children']!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.rooms > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Room ${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: widget.primary,
                                  ),
                                ),
                              ),
                            ),
                          _GuestRow(
                            icon: Icons.person_rounded,
                            label: 'Adults',
                            subtitle: '18+ years',
                            value: adults,
                            onDec: () => widget.onUpdateAdults(idx, adults - 1),
                            onInc: () => widget.onUpdateAdults(idx, adults + 1),
                            minusEnabled: adults > 1,
                            addEnabled: adults + children < 3,
                            primary: widget.primary,
                          ),
                          const SizedBox(height: 12),
                          _GuestRow(
                            icon: Icons.child_care_rounded,
                            label: 'Children',
                            subtitle: '0–17 years',
                            value: children,
                            onDec: () => widget.onUpdateChildren(
                              idx,
                              children > 0 ? children - 1 : 0,
                            ),
                            onInc: () =>
                                widget.onUpdateChildren(idx, children + 1),
                            minusEnabled: children > 0,
                            addEnabled: adults + children < 3,
                            primary: widget.primary,
                          ),
                          if (idx < widget.rooms - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Divider(
                                color: widget.primary.withOpacity(0.08),
                              ),
                            )
                          else
                            const SizedBox(height: 2),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.secondary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: widget.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Max 3 guests per room · ${widget.remainingSlots} slot${widget.remainingSlots == 1 ? '' : 's'} remaining',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: widget.primary.withOpacity(0.08)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest row ─────────────────────────────────────────────────────────────────
class _GuestRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final bool minusEnabled;
  final bool addEnabled;
  final Color primary;

  const _GuestRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onDec,
    required this.onInc,
    required this.minusEnabled,
    required this.addEnabled,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        _CounterButtons(
          value: value,
          onDec: onDec,
          onInc: onInc,
          minusEnabled: minusEnabled,
          addEnabled: addEnabled,
          primary: primary,
          size: 30,
          iconSize: 15,
          fontSize: 15,
        ),
      ],
    );
  }
}

// ── Counter buttons ───────────────────────────────────────────────────────────
class _CounterButtons extends StatelessWidget {
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final bool minusEnabled;
  final bool addEnabled;
  final Color primary;
  final double size;
  final double iconSize;
  final double fontSize;

  const _CounterButtons({
    required this.value,
    required this.onDec,
    required this.onInc,
    required this.minusEnabled,
    required this.addEnabled,
    required this.primary,
    required this.size,
    required this.iconSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: minusEnabled ? onDec : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: minusEnabled ? primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.remove_rounded,
              size: iconSize,
              color: minusEnabled ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: addEnabled ? onInc : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: addEnabled ? primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_rounded,
              size: iconSize,
              color: addEnabled ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}