import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:intl/intl.dart';

class BookingDetailsPage extends StatefulWidget {
  final String? bookingCode;
  final String? propertyCode;

  const BookingDetailsPage({Key? key, this.bookingCode, this.propertyCode})
    : super(key: key);

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage>
    with SingleTickerProviderStateMixin {
  final ApiController _apiController = Get.find<ApiController>();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _hasSearched = false;
  Map<String, dynamic>? _bookingData;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // AppRoutes extracts bookingCode + propertyCode from Get.arguments and
    // passes them as constructor params. If both are present (came from
    // PaymentPage after a successful booking), skip the search screen and
    // fetch details immediately.
    final code = widget.bookingCode ?? '';
    final prop = widget.propertyCode ?? '';

    if (code.isNotEmpty && prop.isNotEmpty) {
      _searchController.text = code;
      _hasSearched = true;
      _loadBookingDetails(bookingCode: code, propertyCode: prop);
    } else {
      // Direct / standalone visit — show the search screen.
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetails({
    String? bookingCode,
    String? propertyCode,
  }) async {
    final code = bookingCode ?? _searchController.text.trim();
    final prop = propertyCode ?? widget.propertyCode ?? '';

    if (code.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
      _bookingData = null;
    });
    _animController.reset();

    try {
      final result = await _apiController.fetchBookingDetails(
        bookingCode: code,
        propertyCode: prop,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _bookingData = result['data'];
          _isLoading = false;
        });
        _animController.forward();
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'No booking found for this code.';
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
      _animController.forward();
    }
  }

  String _formatDate(String? d) {
    if (d == null) return '—';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  String _formatDateTime(String? d) {
    if (d == null) return '—';
    try {
      return DateFormat(
        'MMM dd, yyyy  •  hh:mm a',
      ).format(DateTime.parse(d).toLocal());
    } catch (_) {
      return d;
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
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(),
      body: !_hasSearched ? _buildSearchState() : _buildResultState(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColor.primary,
      leading: IconButton(
        onPressed: () => Get.offNamed(AppRoutes.home),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: const Text(
        'Booking Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      actions: [
        if (_hasSearched && _bookingData != null)
          IconButton(
            onPressed: () => _loadBookingDetails(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
          ),
        if (_hasSearched)
          IconButton(
            onPressed: () {
              setState(() {
                _hasSearched = false;
                _bookingData = null;
                _errorMessage = null;
                _searchController.clear();
              });
              _animController.forward();
            },
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            tooltip: 'New Search',
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.15)),
      ),
    );
  }

  // ─── SEARCH STATE ─────────────────────────────────────────────────────────

  Widget _buildSearchState() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon hero
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 44,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Find Your Booking',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your booking code to view\nyour reservation details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              // Search field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g.  SR-2024-00123',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColor.primary,
                      size: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onSubmitted: (_) => _loadBookingDetails(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadBookingDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Search Booking',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not sure where to find your code?\nCheck your confirmation email.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── RESULT STATE ──────────────────────────────────────────────────────────

  Widget _buildResultState() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColor.primary),
            const SizedBox(height: 16),
            Text(
              'Loading booking details…',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) return _buildErrorState();
    if (_bookingData == null) return const SizedBox();
    return _buildDetails();
  }

  Widget _buildErrorState() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 38,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Booking Not Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loadBookingDetails,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FULL DETAILS ──────────────────────────────────────────────────────────

  Widget _buildDetails() {
    final booking = _bookingData!;
    final finalPrice = booking['finalPrice'] as Map<String, dynamic>? ?? {};
    final primaryGuest = booking['primaryGuest'] as Map<String, dynamic>?;
    final guests = booking['guests'] as List? ?? [];
    final addOns = booking['addOns'] as List? ?? [];
    final dailyBreakdown = finalPrice['dailyBreakdown'] as List? ?? [];
    final taxBreakdown = finalPrice['taxBrakeDown'] as List? ?? [];
    final promoBreakdown = finalPrice['promotionBrakeDown'] as List? ?? [];

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Status Banner ──────────────────────────────────
              _buildHeroBanner(booking),
              const SizedBox(height: 16),

              // ── Hotel & Room ────────────────────────────────────────
              _buildCard(
                icon: Icons.hotel_rounded,
                title: 'Hotel & Room',
                child: Column(
                  children: [
                    _infoTile(
                      'Hotel',
                      booking['hotelName'] ?? '—',
                      icon: Icons.business_rounded,
                    ),
                    _infoTile(
                      'Room Type',
                      booking['roomTypeCode'] ?? '—',
                      icon: Icons.bed_rounded,
                    ),
                    _infoTile(
                      'Rate Plan',
                      booking['ratePlanCode'] ?? '—',
                      icon: Icons.local_offer_rounded,
                    ),
                    _infoTile(
                      'Property Code',
                      booking['propertyCode'] ?? '—',
                      icon: Icons.pin_drop_rounded,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Stay Details ────────────────────────────────────────
              _buildCard(
                icon: Icons.calendar_month_rounded,
                title: 'Stay Details',
                child: Column(
                  children: [
                    _buildStayDates(booking, finalPrice),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _statChip(
                          Icons.nights_stay_rounded,
                          '${finalPrice['numberOfNights'] ?? 1}',
                          'Night(s)',
                        ),
                        const SizedBox(width: 12),
                        _statChip(
                          Icons.people_rounded,
                          '${guests.length}',
                          'Guest(s)',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Guests ──────────────────────────────────────────────
              if (primaryGuest != null || guests.isNotEmpty)
                _buildCard(
                  icon: Icons.people_alt_rounded,
                  title: 'Guest Information',
                  child: _buildGuestSection(primaryGuest, guests),
                ),
              if (primaryGuest != null || guests.isNotEmpty)
                const SizedBox(height: 14),

              // ── Add-ons ─────────────────────────────────────────────
              if (addOns.isNotEmpty)
                _buildCard(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Add-ons',
                  child: _buildAddOns(addOns),
                ),
              if (addOns.isNotEmpty) const SizedBox(height: 14),

              // ── Price Breakdown ─────────────────────────────────────
              _buildCard(
                icon: Icons.receipt_long_rounded,
                title: 'Price Breakdown',
                child: _buildPriceSection(
                  finalPrice,
                  booking,
                  dailyBreakdown,
                  taxBreakdown,
                  promoBreakdown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Banner ────────────────────────────────────────────────────────────

  Widget _buildHeroBanner(Map<String, dynamic> booking) {
    final status = booking['bookingStatus'] as String?;
    final color = _statusColor(status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking['bookingCode'] ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(status), size: 13, color: color),
                    const SizedBox(width: 5),
                    Text(
                      status?.toUpperCase().replaceAll('_', ' ') ?? 'UNKNOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 13,
                color: Colors.white.withOpacity(0.65),
              ),
              const SizedBox(width: 5),
              Text(
                'Booked on ${_formatDateTime(booking['bookedAt'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
          if (booking['hotelName'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 13,
                  color: Colors.white.withOpacity(0.65),
                ),
                const SizedBox(width: 5),
                Text(
                  booking['hotelName'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Stay Dates ─────────────────────────────────────────────────────────────

  Widget _buildStayDates(
    Map<String, dynamic> booking,
    Map<String, dynamic> finalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHECK-IN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(booking['checkInDate']),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${finalPrice['numberOfNights'] ?? 1}N',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColor.primary.withOpacity(0.4),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'CHECK-OUT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(booking['checkOutDate']),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColor.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Guests ─────────────────────────────────────────────────────────────────

  Widget _buildGuestSection(Map<String, dynamic>? primary, List guests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (primary != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColor.primary.withOpacity(0.12),
                  child: Text(
                    '${primary['firstName']?[0] ?? ''}${primary['lastName']?[0] ?? ''}'
                        .toUpperCase(),
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${primary['firstName'] ?? ''} ${primary['lastName'] ?? ''}'
                            .trim(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (primary['email'] != null)
                        Text(
                          primary['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (primary['phoneNumber'] != null)
                        Text(
                          primary['phoneNumber'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (guests.length > 1) ...[
          const SizedBox(height: 12),
          Text(
            'All Guests',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...guests.map((g) {
            final name = '${g['firstName'] ?? ''} ${g['lastName'] ?? ''}'
                .trim();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name.isNotEmpty ? name : 'Guest',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (g['dateOfBirth'] != null)
                    Text(
                      _formatDate(g['dateOfBirth']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  // ── Add-ons ────────────────────────────────────────────────────────────────

  Widget _buildAddOns(List addOns) {
    return Column(
      children: addOns.map((addon) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColor.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addon['name'] ?? 'Add-on',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(addon['date']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '×${addon['quantity']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '${addon['currencyCode'] ?? 'USD'} ${addon['unitPrice']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Price Section ──────────────────────────────────────────────────────────

  Widget _buildPriceSection(
    Map<String, dynamic> finalPrice,
    Map<String, dynamic> booking,
    List dailyBreakdown,
    List taxBreakdown,
    List promoBreakdown,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily breakdown
        if (dailyBreakdown.isNotEmpty) ...[
          _sectionLabel('Daily Charges'),
          const SizedBox(height: 8),
          ...dailyBreakdown.map((day) => _buildDayCharge(day)).toList(),
          const SizedBox(height: 8),
        ],

        // Taxes
        if (taxBreakdown.isNotEmpty) ...[
          _sectionLabel('Taxes & Fees'),
          const SizedBox(height: 8),
          ...taxBreakdown.map(
            (t) => _priceRow(
              t['name'] ?? 'Tax',
              '${t['currencyCode'] ?? 'USD'} ${(t['taxedAmount'] ?? 0.0).toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Promotions
        if (promoBreakdown.isNotEmpty) ...[
          _sectionLabel('Promotions Applied'),
          const SizedBox(height: 8),
          ...promoBreakdown.map(
            (p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    size: 15,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p['name'] ?? 'Promotion',
                      style: TextStyle(fontSize: 13, color: Colors.green[800]),
                    ),
                  ),
                  Text(
                    '-${p['currencyCode'] ?? 'USD'} ${(p['discountAmount'] ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Totals summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _priceRow(
                'Subtotal',
                '${finalPrice['currencyCode'] ?? 'USD'} ${(finalPrice['amountBeforeTax'] ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _priceRow(
                'Taxes & Fees',
                '${finalPrice['currencyCode'] ?? 'USD'} ${(finalPrice['taxedAmount'] ?? 0).toStringAsFixed(2)}',
              ),
              if ((finalPrice['totalAddonAmount'] ?? 0) > 0) ...[
                const SizedBox(height: 6),
                _priceRow(
                  'Add-ons',
                  '${finalPrice['currencyCode'] ?? 'USD'} ${(finalPrice['totalAddonAmount'] ?? 0).toStringAsFixed(2)}',
                ),
              ],
              if ((finalPrice['totalPromotionAmount'] ?? 0) > 0) ...[
                const SizedBox(height: 6),
                _priceRow(
                  'Discount',
                  '-${finalPrice['currencyCode'] ?? 'USD'} ${(finalPrice['totalPromotionAmount'] ?? 0).toStringAsFixed(2)}',
                  valueColor: Colors.green[700],
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(thickness: 1.5, color: Colors.grey[300]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${finalPrice['currencyCode'] ?? 'USD'} ${(finalPrice['totalAmount'] ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Payment info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _infoTile(
                'Payment Method',
                booking['paymentMethod']?.replaceAll('_', ' ').toUpperCase() ??
                    'N/A',
                icon: Icons.credit_card_rounded,
              ),
              _infoTile(
                'Paid Amount',
                '${booking['currencyCode'] ?? 'USD'} ${(booking['paidAmount'] ?? 0).toStringAsFixed(2)}',
                icon: Icons.check_circle_outline_rounded,
                valueColor: Colors.green[700],
              ),
              _infoTile(
                'Extra to Pay',
                '${booking['currencyCode'] ?? 'USD'} ${(booking['extraAmountToPay'] ?? 0).toStringAsFixed(2)}',
                icon: Icons.pending_outlined,
                valueColor: (booking['extraAmountToPay'] ?? 0) > 0
                    ? Colors.orange[700]
                    : Colors.green[700],
                isLast: (booking['refundAmount'] ?? 0) <= 0,
              ),
              if ((booking['refundAmount'] ?? 0) > 0)
                _infoTile(
                  'Refund Amount',
                  '${booking['currencyCode'] ?? 'USD'} ${(booking['refundAmount'] ?? 0).toStringAsFixed(2)}',
                  icon: Icons.replay_rounded,
                  valueColor: Colors.green[700],
                  isLast: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCharge(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day['date'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${day['currencyCode'] ?? 'USD'} ${(day['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Rate',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                '${day['currencyCode'] ?? 'USD'} ${(day['baseRate'] ?? 0.0).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if ((day['additionalChargesAmount'] ?? 0) > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Additional',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  '${day['currencyCode'] ?? 'USD'} ${(day['additionalChargesAmount'] ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColor.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: Colors.grey[400]),
                const SizedBox(width: 10),
              ],
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      ],
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
