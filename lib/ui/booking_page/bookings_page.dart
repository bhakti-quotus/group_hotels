import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:royalcontinent/group/controllers/api_controller.dart';
import 'package:royalcontinent/group/controllers/auth_controller.dart';
import 'package:royalcontinent/group/controllers/hotel_controller.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:royalcontinent/group/models/booking_model.dart';
import 'package:royalcontinent/ui/booking_page/preCheckin_page.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}


class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  final ApiController _api = Get.find<ApiController>();

  late TabController _tabController;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _reservations = [];
  final HotelController _hotelCtrl = Get.find<HotelController>();

  List<String> get _groupPropertyCodes {
    final codes = <String>{};
    final selectedCode = _hotelCtrl.getSelectedHotel()?['code']?.toString();
    if (selectedCode?.isNotEmpty == true) codes.add(selectedCode!);

    final configCode = _hotelCtrl.getConfig()?['code'] as String?;
    if (configCode?.isNotEmpty == true) codes.add(configCode!);

    final childHotels = _hotelCtrl.getChildHotels();
    if (childHotels != null) {
      for (var hotel in childHotels) {
        if (hotel is Map<String, dynamic>) {
          final code = hotel['code']?.toString();
          if (code?.isNotEmpty == true) codes.add(code!);
        }
      }
    }

    return codes.toList();
  }

  List<dynamic> get _filteredReservations {
    final codes = _groupPropertyCodes;
    if (codes.isEmpty) return _reservations;
    return _reservations.where((r) {
      final map = r as Map<String, dynamic>;
      final code = map['propertyCode']?.toString() ?? '';
      return code.isNotEmpty && codes.contains(code);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _api.fetchReservations();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _reservations = (result['data'] as List?) ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error']?.toString() ?? 'Failed to fetch reservations';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _upcomingReservations {
    return _filteredReservations.where((r) {
      final map = r as Map<String, dynamic>;
      final status = map['bookingStatus']?.toString().toLowerCase() ?? '';
      return status == 'confirmed' || status == 'modified';
    }).toList();
  }

  List<dynamic> get _checkedInReservations {
    return _filteredReservations.where((r) {
      final map = r as Map<String, dynamic>;
      final status = map['bookingStatus']?.toString().toLowerCase() ?? '';
      return status == 'checked_in' || status == 'checked in';
    }).toList();
  }

  List<dynamic> get _completedReservations {
    return _filteredReservations.where((r) {
      final map = r as Map<String, dynamic>;
      final status = map['bookingStatus']?.toString().toLowerCase() ?? '';
      return status == 'checked_out' || status == 'checked out';
    }).toList();
  }

  List<dynamic> get _cancelledReservations {
    return _filteredReservations.where((r) {
      final map = r as Map<String, dynamic>;
      final status = map['bookingStatus']?.toString().toLowerCase() ?? '';
      return status == 'cancelled';
    }).toList();
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '—';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(d).toLocal());
    } catch (_) {
      return d.length >= 10 ? d.substring(0, 10) : d;
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'checked_in':
      case 'checked in':
        return const Color(0xFF1565C0);
      case 'checked_out':
      case 'checked out':
        return const Color(0xFF757575);
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFE65100);
    }
  }

  Widget _buildScrollableTab({
    required IconData icon,
    required String label,
    int? count,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Tab(
        height: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    if (!authCtrl.isLoggedIn.value) {
      return Scaffold(
        backgroundColor: AppColor.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 52, color: AppColor.primary.withOpacity(0.9)),
                const SizedBox(height: 16),
                const Text(
                  'Please log in to view your reservations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      authCtrl.ensureLoggedIn(
                        message: 'Please log in to view your reservations',
                        redirectTo: Get.currentRoute,
                        args: Get.arguments,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final body = _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColor.primary))
        : _error != null
            ? _buildError()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_upcomingReservations),
                  _buildList(_checkedInReservations),
                  _buildList(_completedReservations),
                  _buildList(_cancelledReservations),
                ],
              );

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.primary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        title: const Text(
          'My Reservations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 48,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    _buildScrollableTab(
                      icon: Icons.upcoming_rounded,
                      label: 'Upcoming',
                      count: !_isLoading && _error == null
                          ? _upcomingReservations.length
                          : null,
                    ),
                    _buildScrollableTab(
                      icon: Icons.login_rounded,
                      label: 'Checked In',
                      count: !_isLoading && _error == null
                          ? _checkedInReservations.length
                          : null,
                    ),
                    _buildScrollableTab(
                      icon: Icons.history_rounded,
                      label: 'Completed',
                      count: !_isLoading && _error == null
                          ? _completedReservations.length
                          : null,
                    ),
                    _buildScrollableTab(
                      icon: Icons.cancel_rounded,
                      label: 'Cancelled',
                      count: !_isLoading && _error == null
                          ? _cancelledReservations.length
                          : null,
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 60, color: Color(0xFFC62828)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> items) {
    final bookings = items.cast<Map<String, dynamic>>().toList();

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _load(),
        color: AppColor.primary,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const _EmptyBookingsView(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      color: AppColor.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _ReservationCard(booking: bookings[index]);
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _ReservationCard({required this.booking});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw.length >= 10 ? raw.substring(0, 10) : raw;
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'checked_in':
      case 'checked in':
        return const Color(0xFF1565C0);
      case 'checked_out':
      case 'checked out':
        return const Color(0xFF757575);
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFE65100);
    }
  }

  Color _statusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFE8F5E9);
      case 'checked_in':
      case 'checked in':
        return const Color(0xFFE3F2FD);
      case 'checked_out':
      case 'checked out':
        return const Color(0xFFF5F5F5);
      case 'cancelled':
        return const Color(0xFFEF9A9A);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  IconData _statusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'checked_in':
      case 'checked in':
        return Icons.login_rounded;
      case 'checked_out':
      case 'checked out':
        return Icons.logout_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  DateTime? _parseBookingDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isCheckInAvailable() {
    final status = booking['bookingStatus']?.toString().toLowerCase() ?? '';
    final rawStart = booking['reservationStartDate']?.toString() ?? booking['checkInDate']?.toString();
    final startDate = _parseBookingDate(rawStart);
    return status == 'confirmed' && startDate != null && _isToday(startDate);
  }

  bool _isCheckOutAvailable() {
    final status = booking['bookingStatus']?.toString().toLowerCase() ?? '';
    final rawEnd = booking['reservationEndDate']?.toString() ?? booking['checkOutDate']?.toString();
    final endDate = _parseBookingDate(rawEnd);
    return (status == 'checked_in' || status == 'checked in') && endDate != null && _isToday(endDate);
  }

  BookingModel _toBookingModel() {
    return BookingModel.fromJson({'data': booking});
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PreCheckinPage(booking: _toBookingModel()),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pre-checkin completed successfully'),
          backgroundColor: AppColor.primary,
        ),
      );
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    final bookingCode = booking['bookingCode']?.toString() ?? '';
    if (bookingCode.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Check-out'),
          content: const Text('Do you want to complete check-out for this reservation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final api = Get.find<ApiController>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Processing check-out...'),
        backgroundColor: AppColor.primary,
      ),
    );

    final result = await api.checkOutReservation(bookingCode);

    if (result['success'] == true) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Check-out completed'),
          backgroundColor: AppColor.primary,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Failed to complete check-out'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingCode = booking['bookingCode']?.toString() ?? '';
    final propertyCode = booking['propertyCode']?.toString() ?? '';
    final hotelName = booking['hotelName']?.toString() ??
        booking['propertyName']?.toString() ??
        'Hotel';
    final roomName = booking['roomName']?.toString() ?? 'Room';
    final ratePlanName = booking['ratePlanName']?.toString() ?? '';
    final status = booking['bookingStatus']?.toString() ?? 'unknown';
    final amount = booking['amount']?.toString() ??
        booking['paidAmount']?.toString() ??
        '0';
    final currency = booking['currencyCode']?.toString() ?? '';
    final start = booking['reservationStartDate']?.toString() ??
        booking['checkInDate']?.toString();
    final end = booking['reservationEndDate']?.toString() ??
        booking['checkOutDate']?.toString();

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotelName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [roomName, ratePlanName]
                            .where((e) => e.isNotEmpty)
                            .join(' • '),
                        style: TextStyle(
                          color: AppColor.textLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Booking Code: $bookingCode',
                        style: TextStyle(
                          color: AppColor.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status),
                              size: 14, color: _statusColor(status)),
                          const SizedBox(width: 6),
                          Text(
                            status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$currency $amount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Check-in',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(_formatDate(start),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Check-out',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(_formatDate(end),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Property Code: ${propertyCode.isNotEmpty ? propertyCode : '—'}',
                    style: TextStyle(color: AppColor.textLight, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: bookingCode.isEmpty
                      ? null
                      : () {
                          Get.toNamed(
                            AppRoutes.groupBookingDetails,
                            arguments: {
                              'bookingCode': bookingCode,
                              'propertyCode': propertyCode,
                            },
                          );
                        },
                  child: const Text('View details'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCheckInAvailable() ? () => _handleCheckIn(context) : null,
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Check-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCheckOutAvailable() ? () => _handleCheckOut(context) : null,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Check-out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

// Fixed empty bookings view - only one definition
class _EmptyBookingsView extends StatelessWidget {
  const _EmptyBookingsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            size: 48,
            color: AppColor.primary.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No reservations found',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your bookings will appear here',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.textLight,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pull down to refresh',
          style: TextStyle(
            color: AppColor.textLight.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}