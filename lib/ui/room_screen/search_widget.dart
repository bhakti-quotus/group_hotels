import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:royalcontinent/group/controllers/search_controller.dart'
    as search_ctrl;
import 'package:royalcontinent/group/controllers/hotel_controller.dart';

class _T {
  static Color get bg => Colors.white;
  static Color get surface => const Color(0xFFF7F5F0);
  static Color get chipBg => Colors.white;
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8CC80);
  static const Color goldDim = Color(0xFF9A7A35);
  static Color get textPrimary => const Color(0xFF1A1A1A);
  static Color get textSub => const Color(0xFF555555);
  static Color get textMuted => const Color(0xFF999999);
  static const Color border = Color(0xFFE5DEC8);
  static const Color divider = Color(0xFFEEE8D8);
  static Color get panel => Colors.white;
  static Color get panelDark => const Color(0xFFF2EFE8);
}

class SearchWidget extends StatefulWidget {
  final bool update;
  final bool showEditText;
  final VoidCallback? onModifySearch;

  const SearchWidget({
    super.key,
    this.update = false,
    this.showEditText = false,
    this.onModifySearch,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with TickerProviderStateMixin {
  DateTime checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime checkOut = DateTime.now().add(const Duration(days: 2));
  int rooms = 1;
  List<Map<String, Object?>> roomGuests = [];
  String propertyCode = '';
  String? hotelLogoUrl;
  String hotelName = '';
  bool _showGuestDetails = false;
  bool _showFullSearch = false;
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _calendarSectionKey = GlobalKey();
  final GlobalKey _guestSectionKey = GlobalKey();
  late HotelController hotelCtrl;
  int selectedHotelIndex = 0;
  List<dynamic> childHotels = [];

  // Range calendar state
  late PageController _calPageCtrl;
  int _calMonthOffset = 0;
  DateTime? _pendingCheckIn;

  late AnimationController _panelCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _panelFade;

  int get totalChildren =>
      roomGuests.fold<int>(0, (s, r) => s + (r['children'] as int));
  int get totalAdults =>
      roomGuests.fold<int>(0, (s, r) => s + (r['adults'] as int));
  int get totalGuests => totalAdults + totalChildren;
  int get remainingSlots => (4 * rooms) - totalGuests;
  int get totalNights => checkOut.difference(checkIn).inDays;

  @override
  void initState() {
    super.initState();
    hotelCtrl = Get.find<HotelController>();
    ever(hotelCtrl.selectedHotel, _onExternalHotelChange);
    _initializeRoomGuests();
    _loadConfig();
    _loadFromController();
    _calPageCtrl = PageController(initialPage: 0);
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _panelFade = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeInOut);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  void _onExternalHotelChange(Map<String, dynamic>? hotel) {
    if (hotel == null) return;
    final code = hotel['code'] as String? ?? '';
    if (code == propertyCode) return;
    final index = childHotels.indexWhere((h) => (h['code'] as String?) == code);
    if (!mounted) return;
    setState(() {
      propertyCode = code;
      hotelName = hotel['name'] as String? ?? hotelName;
      hotelLogoUrl = hotel['config']?['branding']?['logo'] as String?;
      if (index >= 0) selectedHotelIndex = index;
    });
  }

  void _initializeRoomGuests() {
    roomGuests = List.generate(
      rooms,
      (_) => <String, Object?>{
        'adults': 1,
        'children': 0,
        'childAges': <int>[],
      },
    );
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    _shimmerCtrl.dispose();
    _calPageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _loadConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final config = json.decode(raw);
      final childHotels = config['childHotels'] as List? ?? [];
      setState(() {
        this.childHotels = childHotels;
        if (childHotels.isNotEmpty) {
          final alreadySelected = hotelCtrl.selectedHotel.value;
          final alreadyCode = alreadySelected?['code'] as String?;
          if (alreadyCode != null && alreadyCode.isNotEmpty) {
            final idx = childHotels.indexWhere(
              (h) => (h['code'] as String?) == alreadyCode,
            );
            selectedHotelIndex = idx >= 0 ? idx : 0;
            final hotel =
                childHotels[selectedHotelIndex] as Map<String, dynamic>;
            propertyCode = hotel['code'] ?? config['code'] ?? '';
            hotelName = hotel['name'] ?? config['name'] ?? '';
            hotelLogoUrl =
                hotel['config']?['branding']?['logo'] ??
                config['config']?['branding']?['logo'];
          } else {
            final defaultHotel = childHotels[0] as Map<String, dynamic>;
            selectedHotelIndex = 0;
            propertyCode = defaultHotel['code'] ?? config['code'] ?? '';
            hotelName = defaultHotel['name'] ?? config['name'] ?? '';
            hotelLogoUrl =
                defaultHotel['config']?['branding']?['logo'] ??
                config['config']?['branding']?['logo'];
            hotelCtrl.setSelectedHotel(defaultHotel);
          }
        } else {
          propertyCode = config['code'] ?? '';
          hotelName = config['name'] ?? '';
          hotelLogoUrl = config['config']?['branding']?['logo'];
        }
        hotelCtrl.setChildHotels(childHotels);
      });
    } catch (e) {
      debugPrint('Config load error: $e');
    }
  }

  void _loadFromController() {
    final ctrl = Get.find<search_ctrl.AppSearchController>();
    if (ctrl.searchPayload.isNotEmpty) {
      final p = Map<String, dynamic>.from(ctrl.searchPayload);
      setState(() {
        checkIn = DateTime.parse(p['startDate']);
        checkOut = DateTime.parse(p['endDate']);
        final g = p['guests'] as Map<String, dynamic>;
        rooms = g['rooms'] as int? ?? 1;
        if (g['roomsArray'] != null) {
          roomGuests = (g['roomsArray'] as List)
              .map<Map<String, Object?>>((r) {
                final room = Map<String, Object?>.from(r as Map);
                final childAges = room['childAges'] as List?;
                return <String, Object?>{
                  'adults': room['adults'] as int? ?? 1,
                  'children': room['children'] as int? ?? 0,
                  'childAges': List<int>.from(childAges?.cast<int>() ?? <int>[]),
                };
              })
              .toList();
        } else {
          roomGuests = List.generate(
            rooms,
            (_) => <String, Object?>{
              'adults': 1,
              'children': 0,
              'childAges': <int>[],
            },
          );
        }
      });
    }
  }

  void updateRooms(int n) {
    setState(() {
      rooms = n;
      if (n > roomGuests.length) {
        roomGuests.addAll(
          List.generate(
            n - roomGuests.length,
            (_) => {'adults': 1, 'children': 0, 'childAges': <int>[]},
          ),
        );
      } else if (n < roomGuests.length) {
        roomGuests = roomGuests.sublist(0, n);
      }
    });
  }

  void updateAdults(int i, int v) {
    if (v + (roomGuests[i]['children'] as int) <= 4 && v >= 1) {
      setState(() => roomGuests[i]['adults'] = v);
    }
  }

  void updateChildren(int i, int v) {
    final currentAdults = roomGuests[i]['adults'] as int;
    final currentChildren = roomGuests[i]['children'] as int;
    final currentAges = List<int>.from(
      (roomGuests[i]['childAges'] as List?)?.cast<int>() ?? <int>[],
    );
    if (currentAdults + v <= 4 && v >= 0) {
      final updatedAges = <int>[];
      if (v > currentChildren) {
        updatedAges.addAll(currentAges);
        updatedAges.addAll(List.generate(v - currentChildren, (_) => 0));
      } else if (v < currentChildren) {
        updatedAges.addAll(currentAges.take(v));
      } else {
        updatedAges.addAll(currentAges.take(v));
      }
      setState(() {
        roomGuests[i]['children'] = v;
        roomGuests[i]['childAges'] = updatedAges;
      });
    }
  }

  void updateChildAge(int roomIndex, int childIndex, int age) {
    if (age >= 0 && age <= 15) {
      setState(() {
        final ages = List<int>.from(
          (roomGuests[roomIndex]['childAges'] as List?)?.cast<int>() ?? <int>[],
        );
        if (childIndex < ages.length) {
          ages[childIndex] = age;
          roomGuests[roomIndex]['childAges'] = ages;
        }
      });
    }
  }

  void _selectHotel(int index) {
    if (index >= childHotels.length) return;
    final selectedHotel = childHotels[index] as Map<String, dynamic>;
    hotelCtrl.setSelectedHotel(selectedHotel);
    setState(() {
      selectedHotelIndex = index;
      propertyCode = selectedHotel['code'] ?? '';
      hotelName = selectedHotel['name'] ?? '';
      hotelLogoUrl = selectedHotel['config']?['branding']?['logo'];
    });
    Get.find<search_ctrl.AppSearchController>().updateSearchPayload(_payload);
  }

  Map<String, dynamic> get _payload => {
    "propertyCode": propertyCode,
    "startDate": checkIn.toIso8601String().split('T')[0],
    "endDate": checkOut.toIso8601String().split('T')[0],
    "guests": {
      "adults": totalAdults,
      "children": totalChildren,
      "rooms": rooms,
      "roomsArray": roomGuests
          .map(
            (room) => {
              "adults": room['adults'],
              "children": room['children'],
              "childAges": room['childAges'] ?? [],
            },
          )
          .toList(),
    },
    "location": "",
    "numberOfRooms": rooms,
    "promocode": "",
  };

  /// Two-tap range selection.
  /// First tap  → pending check-in.
  /// Second tap → must be strictly after first → confirms range.
  /// Tap same / before → restart from that date.
  void _onCalendarDayTap(DateTime tapped) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (tapped.isBefore(todayDate)) return;
    setState(() {
      if (_pendingCheckIn == null) {
        _pendingCheckIn = tapped;
      } else {
        if (tapped.isAfter(_pendingCheckIn!)) {
          checkIn = _pendingCheckIn!;
          checkOut = tapped;
          _pendingCheckIn = null;
        } else {
          _pendingCheckIn = tapped;
        }
      }
    });
  }

  void _performSearch() {
    Get.find<search_ctrl.AppSearchController>().updateSearchPayload(_payload);
    if (widget.showEditText && widget.onModifySearch != null) {
      widget.onModifySearch!();
    } else {
      Get.toNamed('/rooms');
    }
    if (_showFullSearch) _togglePanel();
  }

  void _togglePanel() {
    setState(() => _showFullSearch = !_showFullSearch);
    _showFullSearch ? _panelCtrl.forward() : _panelCtrl.reverse();
  }

  void _openPanelToSection(GlobalKey key, {bool expandGuestDetails = false}) {
    final wasOpen = _showFullSearch;
    
    if (!_showFullSearch) {
      setState(() => _showFullSearch = true);
      _panelCtrl.forward();
    }
    
    if (expandGuestDetails && !_showGuestDetails) {
      setState(() => _showGuestDetails = true);
    }
    
    // If panel was already open, scroll immediately
    // If just opened, wait for animation to complete
    final delay = wasOpen 
      ? Duration.zero 
      : const Duration(milliseconds: 420);
    
    Future.delayed(delay, () {
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
        alignment: 0.12,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  // ── helpers ──────────────────────────────────
  static String _mon(int m) => const [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ][m - 1];

  static String _monthName(int m) => const [
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
  ][m - 1];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// How many rows does this month need in a Mon-start grid?
  int _rowsInMonth(DateTime month) {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon
    final leadingBlanks = firstWeekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    return ((leadingBlanks + daysInMonth) / 7.0).ceil();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactBar(),
            _buildShimmerLine(),
            AnimatedSize(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOut,
              child: _showFullSearch
                  ? FadeTransition(
                      opacity: _panelFade,
                      child: _buildExpandedPanel(),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  COMPACT BAR
  // ─────────────────────────────────────────────
  Widget _buildCompactBar() {
    return Obx(() {
      final _ = hotelCtrl.selectedHotel.value;
      return GestureDetector(
        onTap: _togglePanel,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogo(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotelName.isNotEmpty ? hotelName : 'Search Rooms',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _T.textPrimary,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          childHotels.length > 1
                              ? '${childHotels.length} hotels'
                              : 'Tap to modify',
                          style: TextStyle(fontSize: 10, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showFullSearch ? 0.5 : 0,
                    duration: const Duration(milliseconds: 320),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.secondary,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _chip(
                      label: 'STAY',
                      value:
                          '${_mon(checkIn.month)} ${checkIn.day}  —  ${_mon(checkOut.month)} ${checkOut.day}',
                      icon: Icons.date_range_rounded,
                      onTap: () => _openPanelToSection(_calendarSectionKey),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _chip(
                    label: 'NIGHTS',
                    value: '$totalNights',
                    icon: Icons.nightlight_round,
                    fixedWidth: 70,
                    onTap: () => _openPanelToSection(_calendarSectionKey),
                  ),
                  const SizedBox(width: 4),
                  _chip(
                    label: 'GUESTS',
                    value: '$totalGuests · ${rooms}rm',
                    icon: Icons.people_outline_rounded,
                    fixedWidth: 74,
                    onTap: () => _openPanelToSection(
                      _guestSectionKey,
                      expandGuestDetails: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 60,
      height: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: (hotelLogoUrl != null && hotelLogoUrl!.isNotEmpty)
            ? Image.network(
                hotelLogoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallbackLogo(),
              )
            : _fallbackLogo(),
      ),
    );
  }

  Widget _fallbackLogo() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_T.goldDim, _T.gold],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 20),
  );

  Widget _chip({
    required String label,
    required String value,
    required IconData icon,
    double? fixedWidth,
    VoidCallback? onTap,
  }) {
    final inner = Container(
      width: fixedWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 9, color: _T.gold),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.2,
                  color: _T.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: _T.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    if (onTap == null) {
      return fixedWidth != null ? inner : Expanded(flex: 5, child: inner);
    }
    final clickable = GestureDetector(onTap: onTap, child: inner);
    return fixedWidth != null ? clickable : Expanded(flex: 5, child: clickable);
  }

  Widget _buildShimmerLine() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        final t = _shimmerCtrl.value;
        return Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Colors.transparent,
                _T.goldDim,
                _T.goldLight,
                _T.goldDim,
                Colors.transparent,
              ],
              stops: [
                0.0,
                (t - 0.25).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.25).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  EXPANDED PANEL
  // ─────────────────────────────────────────────
  Widget _buildExpandedPanel() {
    return Container(
      color: _T.panel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 0.8, color: _T.goldDim.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
            child: Row(
              children: [
                Text(
                  'MODIFY SEARCH',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.8,
                    color: AppColor.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _T.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _T.border, width: 1),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: _T.textMuted,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineRangeCalendar(),
                const SizedBox(height: 18),
                _goldDivider(),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GUESTS & ROOMS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2.2,
                            color: _T.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$totalAdults adults'
                          '${totalChildren > 0 ? ' · $totalChildren children' : ''}'
                          ' · $rooms ${rooms == 1 ? 'room' : 'rooms'}',
                          style: TextStyle(fontSize: 12, color: _T.textSub),
                        ),
                      ],
                    ),
                    _editDoneButton(
                      label: _showGuestDetails ? 'DONE' : 'EDIT',
                      active: _showGuestDetails,
                      onTap: () => setState(
                        () => _showGuestDetails = !_showGuestDetails,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  child: _showGuestDetails
                      ? _buildGuestPanel()
                      : const SizedBox(height: 4),
                ),
                const SizedBox(height: 18),
                if (childHotels.length > 1) ...[
                  _goldDivider(),
                  const SizedBox(height: 16),
                  _buildVerticalHotelSelector(),
                  const SizedBox(height: 18),
                ],
                _buildSearchButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  INLINE RANGE CALENDAR (FIXED)
  // ─────────────────────────────────────────────
  Widget _buildInlineRangeCalendar() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final activeCheckIn = _pendingCheckIn ?? checkIn;
    final activeCheckOut = _pendingCheckIn == null ? checkOut : null;

    return Container(
      key: _calendarSectionKey,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── status header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded, size: 14, color: _T.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: _pendingCheckIn != null
                      ? Text(
                          'Now select CHECK-OUT date',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            color: AppColor.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 10, color: _T.textMuted),
                            children: [
                              TextSpan(
                                text: '${_mon(checkIn.month)} ${checkIn.day}',
                                style: const TextStyle(
                                  color: _T.gold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(text: '  →  '),
                              TextSpan(
                                text: '${_mon(checkOut.month)} ${checkOut.day}',
                                style: const TextStyle(
                                  color: _T.gold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '   $totalNights night${totalNights == 1 ? '' : 's'}',
                                style: TextStyle(color: _T.textMuted),
                              ),
                            ],
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _pendingCheckIn != null
                        ? AppColor.secondary.withOpacity(0.08)
                        : _T.gold.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _pendingCheckIn != null
                          ? AppColor.secondary.withOpacity(0.3)
                          : _T.gold.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _pendingCheckIn != null ? 'SELECT OUT' : 'SELECT IN',
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: _pendingCheckIn != null
                          ? AppColor.secondary
                          : _T.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 0.6, color: _T.border),

          // ── month grid ──
          SizedBox(
            height: 350, // Fixed reasonable height that accommodates 6 rows
            child: PageView.builder(
              controller: _calPageCtrl,
              onPageChanged: (page) => setState(() => _calMonthOffset = page),
              itemBuilder: (context, page) {
                final monthDate = DateTime(today.year, today.month + page, 1);
                return _buildMonthGrid(
                  monthDate,
                  todayDate,
                  activeCheckIn,
                  activeCheckOut,
                );
              },
            ),
          ),

          // ── navigation row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _calNavBtn(
                  icon: Icons.chevron_left_rounded,
                  enabled: _calMonthOffset > 0,
                  onTap: () => _calPageCtrl.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
                if (_pendingCheckIn != null)
                  GestureDetector(
                    onTap: () => setState(() => _pendingCheckIn = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _T.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _T.border, width: 1),
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: _T.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                _calNavBtn(
                  icon: Icons.chevron_right_rounded,
                  enabled: true,
                  onTap: () => _calPageCtrl.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calNavBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? _T.gold.withOpacity(0.10) : _T.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? _T.gold.withOpacity(0.4) : _T.border,
            width: 1,
          ),
        ),
        child: Icon(icon, size: 20, color: enabled ? _T.gold : _T.textMuted),
      ),
    );
  }

  // FIXED: Proper month grid that shows all dates
  Widget _buildMonthGrid(
    DateTime monthDate,
    DateTime todayDate,
    DateTime activeCheckIn,
    DateTime? activeCheckOut,
  ) {
    final daysInMonth = DateUtils.getDaysInMonth(
      monthDate.year,
      monthDate.month,
    );
    final firstWeekday = DateTime(
      monthDate.year,
      monthDate.month,
      1,
    ).weekday; // 1=Mon
    final leadingBlanks = firstWeekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final rowsNeeded = (totalCells / 7).ceil();
    const double cellSize = 45.0;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month + year title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${_monthName(monthDate.month)} ${monthDate.year}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _T.gold,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            // Weekday headers
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _T.textMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // Day grid - using Column with Rows for perfect display
            Container(
              child: Column(
                children: [
                  for (int row = 0; row < rowsNeeded; row++)
                    SizedBox(
                      height: cellSize,
                      child: Row(
                        children: List.generate(7, (col) {
                          final cellIndex = row * 7 + col;
                          if (cellIndex >= leadingBlanks && 
                              cellIndex < leadingBlanks + daysInMonth) {
                            final day = cellIndex - leadingBlanks + 1;
                            final date = DateTime(monthDate.year, monthDate.month, day);
                            return Expanded(
                              child: _buildDayCell(
                                date,
                                todayDate,
                                activeCheckIn,
                                activeCheckOut,
                              ),
                            );
                          } else {
                            return const Expanded(child: SizedBox.shrink());
                          }
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    DateTime todayDate,
    DateTime activeCheckIn,
    DateTime? activeCheckOut,
  ) {
    final isPast = date.isBefore(todayDate);
    final isCheckIn = _isSameDay(date, activeCheckIn);
    final isCheckOut =
        activeCheckOut != null && _isSameDay(date, activeCheckOut);
    final isInRange =
        activeCheckOut != null &&
        date.isAfter(activeCheckIn) &&
        date.isBefore(activeCheckOut);
    final isPendingStart =
        _pendingCheckIn != null && _isSameDay(date, _pendingCheckIn!);
    final isToday = _isSameDay(date, todayDate);

    final isEndCap = isCheckIn || isCheckOut || isPendingStart;

    Color? bgColor;
    Color textColor = isPast ? _T.textMuted.withOpacity(0.35) : _T.textPrimary;

    if (isEndCap) {
      bgColor = _T.gold;
      textColor = Colors.white;
    } else if (isInRange) {
      bgColor = _T.gold.withOpacity(0.13);
    }

    return GestureDetector(
      onTap: isPast ? null : () => _onCalendarDayTap(date),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: isEndCap
              ? BorderRadius.circular(8)
              : isInRange
              ? BorderRadius.zero
              : BorderRadius.circular(6),
          border: isToday && !isEndCap && !isInRange
              ? Border.all(color: _T.gold.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isEndCap ? FontWeight.w900 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HOTEL SELECTOR
  // ─────────────────────────────────────────────
  Widget _buildVerticalHotelSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_T.goldDim, _T.gold],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SELECT PROPERTY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: _T.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(childHotels.length, (index) {
            final hotel = childHotels[index] as Map<String, dynamic>;
            final isSelected = index == selectedHotelIndex;
            final name = hotel['name'] as String? ?? 'Hotel ${index + 1}';
            final logoUrl = hotel['config']?['branding']?['logo'] as String?;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < childHotels.length - 1 ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => _selectHotel(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _T.gold.withOpacity(0.07) : _T.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _T.gold : _T.border,
                      width: isSelected ? 1.6 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _T.gold.withOpacity(0.14),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? _T.gold.withOpacity(0.5)
                                : _T.border,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: (logoUrl != null && logoUrl.isNotEmpty)
                              ? Image.network(
                                  logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _smallFallbackLogo(),
                                )
                              : _smallFallbackLogo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? _T.textPrimary : _T.textSub,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? _T.gold : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? _T.gold : _T.border,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _smallFallbackLogo() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_T.goldDim, _T.gold],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Icon(Icons.hotel_rounded, color: Colors.white, size: 16),
  );

  // ─────────────────────────────────────────────
  //  GUEST PANEL
  // ─────────────────────────────────────────────
  Widget _buildGuestPanel() {
    return Container(
      key: _guestSectionKey,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.panelDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCounter(
            'ROOMS',
            rooms,
            Icons.meeting_room_outlined,
            () => updateRooms(rooms > 1 ? rooms - 1 : 1),
            () => updateRooms(rooms < 10 ? rooms + 1 : rooms),
            minusEnabled: rooms > 1,
            addEnabled: rooms < 10,
          ),
          _panelDivider(),
          if (rooms == 1) ...[
            _buildGuestConfiguration(0),
          ] else
            ...List.generate(
              rooms,
              (idx) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 13,
                        decoration: BoxDecoration(
                          color: _T.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ROOM ${idx + 1}',
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          color: _T.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildGuestConfiguration(idx),
                  if (idx < rooms - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Container(height: 0.8, color: _T.border),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: _T.goldDim),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Maximum 4 guests per room · Children ages 0–15',
                  style: TextStyle(
                    fontSize: 10,
                    color: _T.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: _T.goldDim),
              const SizedBox(width: 7),
              Text(
                '$remainingSlots slot${remainingSlots == 1 ? '' : 's'} remaining',
                style: TextStyle(
                  fontSize: 10,
                  color: _T.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestConfiguration(int roomIndex) {
    final room = roomGuests[roomIndex];
    final adults = room['adults'] as int;
    final children = room['children'] as int;
    final childAges = List<int>.from(
      (room['childAges'] as List?)?.cast<int>() ?? <int>[],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCounter(
          'ADULTS',
          adults,
          Icons.person_outline_rounded,
          () => updateAdults(roomIndex, adults - 1),
          () => updateAdults(roomIndex, adults + 1),
          minusEnabled: adults > 1,
          addEnabled: adults + children < 4,
        ),
        _panelDivider(),
        _buildCounter(
          'CHILDREN (0–15)',
          children,
          Icons.child_care_rounded,
          () => updateChildren(roomIndex, children - 1),
          () => updateChildren(roomIndex, children + 1),
          minusEnabled: children > 0,
          addEnabled: adults + children < 4,
        ),
        if (children > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.border.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cake_outlined, size: 14, color: _T.goldDim),
                    const SizedBox(width: 6),
                    Text(
                      'CHILD AGES',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: _T.goldDim,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(children, (childIndex) {
                  final age = childIndex < childAges.length
                      ? childAges[childIndex]
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _T.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${childIndex + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _T.goldDim,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Child ${childIndex + 1} age',
                            style: TextStyle(fontSize: 11, color: _T.textSub),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _T.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: age,
                              isDense: true,
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: _T.goldDim,
                              ),
                              items: List.generate(16, (i) => i).map((ageVal) {
                                return DropdownMenuItem<int>(
                                  value: ageVal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      ageVal == 0
                                          ? '< 1 yr (Infant)'
                                          : '$ageVal yr${ageVal > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _T.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newAge) {
                                if (newAge != null) {
                                  updateChildAge(roomIndex, childIndex, newAge);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SHARED WIDGETS
  // ─────────────────────────────────────────────
  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _performSearch,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A84C), Color(0xFFE0C26E), Color(0xFFC9A84C)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _T.gold.withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              widget.showEditText ? 'UPDATE SEARCH' : 'SEARCH ROOMS',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(
    String label,
    int value,
    IconData icon,
    VoidCallback onDec,
    VoidCallback onInc, {
    required bool minusEnabled,
    required bool addEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: _T.goldDim),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: _T.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _ctrBtn(Icons.remove_rounded, onDec, minusEnabled),
              SizedBox(
                width: 42,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                  ),
                ),
              ),
              _ctrBtn(Icons.add_rounded, onInc, addEnabled),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctrBtn(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColor.secondary : _T.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppColor.secondary : _T.border,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled ? Colors.white : _T.textMuted,
        ),
      ),
    );
  }

  Widget _goldDivider() => Container(
    height: 0.8,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, _T.goldDim, Colors.transparent],
      ),
    ),
  );

  Widget _panelDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Container(height: 0.6, color: _T.divider),
  );

  Widget _editDoneButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_T.goldDim, _T.gold])
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _T.gold : _T.border, width: 1),
          boxShadow: active
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColor.secondary,
          ),
        ),
      ),
    );
  }
}