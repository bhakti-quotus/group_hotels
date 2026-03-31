import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'package:group/group/controllers/search_controller.dart' as search_ctrl;
import 'package:group/group/controllers/hotel_controller.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ModifyBookingPage extends StatefulWidget {
  const ModifyBookingPage({Key? key}) : super(key: key);

  @override
  State<ModifyBookingPage> createState() => _ModifyBookingPageState();
}

class _ModifyBookingPageState extends State<ModifyBookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiController _apiController = Get.find<ApiController>();

  // Date controllers
  late DateTime _checkInDate;
  late DateTime _checkOutDate;

  // Booking data from arguments
  Map<String, dynamic>? _bookingData;
  String? _bookingCode;

  // Guest data
  List<Map<String, dynamic>> _guests = [];
  Map<String, dynamic>? _primaryGuest;

// New guest form data
  final List<Map<String, dynamic>> _newAdults = [];
  final List<Map<String, dynamic>> _newChildren = [];

  String? _invTypeCode;
  String? _ratePlanCode;

  // Loading state
  bool _isLoading = false;
  bool _isLoadingPrice = false;

  // Price data
  Map<String, dynamic>? _priceData;

  // Track if price has been fetched
  bool _priceFetched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookingData();
  }

  DateTime? _safeParse(dynamic value) {
    if (value == null) return null;
    try {
      final s = value.toString().trim();
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      try {
        final parts = value.toString().split(RegExp(r'[-/]'));
        if (parts.length == 3 && parts[0].length == 2) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
      return null;
    }
  }

  void _loadBookingData() {
    final args = Get.arguments;
    Map<String, dynamic>? booking;
    if (args is Map<String, dynamic>) {
      booking = args['bookingData'] as Map<String, dynamic>?;
    }

    print('=== MODIFY BOOKING: RAW ARGUMENTS ===');
    print('Arguments: $args');
    print('bookingData extracted: ${booking != null}');
    if (booking != null) {
      print('Raw booking data (JSON): ${jsonEncode(booking)}');
    }
    print('========================================');

    if (booking != null) {
      _bookingData = booking;
      _bookingCode = booking['bookingCode'] as String?;

      _checkInDate = _safeParse(booking['checkInDate']) ?? DateTime.now();
      _checkOutDate =
          _safeParse(booking['checkOutDate']) ??
          DateTime.now().add(const Duration(days: 1));

      _primaryGuest = booking['primaryGuest'] as Map<String, dynamic>?;

      // Sanitize guests — convert empty dateOfBirth strings to null
      final guestsList = booking['guests'] as List? ?? [];
      _guests = List<Map<String, dynamic>>.from(
        guestsList.map((g) {
          final guest = Map<String, dynamic>.from(g);
          final dob = guest['dateOfBirth'];
          if (dob != null && dob.toString().trim().isEmpty) {
            guest['dateOfBirth'] = null;
          }
          return guest;
        }),
      );

      // Sanitize primaryGuest dateOfBirth too
      if (_primaryGuest != null) {
        _primaryGuest = Map<String, dynamic>.from(_primaryGuest!);
        final dob = _primaryGuest!['dateOfBirth'];
        if (dob != null && dob.toString().trim().isEmpty) {
          _primaryGuest!['dateOfBirth'] = null;
        }
      }

      _priceData = booking['finalPrice'] as Map<String, dynamic>?;

      // Set correct room type (invTypeCode)
      _invTypeCode = booking['roomTypeCode'] ?? booking['roomType'] ?? booking['roomName'];
      _ratePlanCode = booking['ratePlanCode'];

      print("INIT invTypeCode: $_invTypeCode");
      print("INIT ratePlanCode: $_ratePlanCode");
      
      // Print full processed booking data
      print('=== MODIFY BOOKING: PROCESSED DATA ===');
      print('_bookingCode: $_bookingCode');
      print('_primaryGuest: ${jsonEncode(_primaryGuest)}');
      print('Guests count: ${_guests.length}');
      print('Full _bookingData (JSON): ${jsonEncode(_bookingData)}');
      print('Price data: ${jsonEncode(_priceData)}');
      print('=====================================');
    } else {
      _checkInDate = DateTime.now();
      _checkOutDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  Future<void> _fetchModifiedPrice() async {
    if (_bookingData == null || _bookingCode == null) return;

    setState(() {
      _isLoadingPrice = true;
    });

    // Safety check
    if (_invTypeCode == null || _invTypeCode!.isEmpty) {
      Get.snackbar(
        'Error',
        'Room type not chosen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => _isLoadingPrice = false);
      return;
    }

    try {
      final payload = {
        'bookingCode': _bookingCode,
'propertyCode': (Get.find<HotelController>().getSelectedHotel()?['code'] as String?) ?? (_bookingData!['propertyCode'] ?? ''),
'invTypeCode': _invTypeCode ?? '',
        'ratePlanCode': _bookingData!['ratePlanCode'] ?? '',
        'startDate': _checkInDate.toIso8601String().split('T')[0],
        'endDate': _checkOutDate.toIso8601String().split('T')[0],
        'noOfAdults': _guests.length + _newAdults.length + 1,
        'noOfChildrens': _newChildren.length,
        'noOfRooms': 1,
        'previousRooms': 1,
      };

      // Add guestDistribution from fetchRoomsAPI searchCriteria.guests equivalent (roomsArray)
      final searchController = Get.find<search_ctrl.AppSearchController>();
      payload['guestDistribution'] =
          searchController.searchPayload['guests']?['roomsArray'] ?? [];

      final result = await _apiController.getPrice(payload);

      if (result['success'] == true && mounted) {
        setState(() {
          _priceData = result['data'];
          _isLoadingPrice = false;
          _priceFetched = true;
        });
        // Switch to Price tab
        _tabController.animateTo(1);
      } else if (mounted) {
        setState(() {
          _isLoadingPrice = false;
        });
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to get updated price',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrice = false;
        });
        Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate.isBefore(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
        _priceFetched = false;
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
        _priceFetched = false;
      });
    }
  }

  void _addAdult() {
    setState(() {
      _newAdults.add({'firstName': '', 'lastName': '', 'dateOfBirth': null});
      _priceFetched = false;
    });
  }

  void _addChild() {
    setState(() {
      _newChildren.add({'firstName': '', 'lastName': '', 'dateOfBirth': null});
      _priceFetched = false;
    });
  }

  void _removeAdult(int index) {
    setState(() {
      _newAdults.removeAt(index);
      _priceFetched = false;
    });
  }

  void _removeChild(int index) {
    setState(() {
      _newChildren.removeAt(index);
      _priceFetched = false;
    });
  }

  Future<void> _selectDateOfBirth(bool isChild, int index) async {
    final DateTime now = DateTime.now();
    DateTime firstDate;
    DateTime maxDate;
    DateTime initialDate;

    if (isChild) {
      // Child: age 0 (maxDate=now) to max age 12 (firstDate=now-12yrs)
      firstDate = DateTime(now.year - 12, now.month, now.day);
      maxDate = now;
      initialDate = DateTime.now().subtract(Duration(days: 365 * 8));
    } else {
      // Adult: min age 16 (maxDate=now-16yrs), max age 100 (firstDate=now-100yrs)
      firstDate = DateTime(now.year - 100, now.month, now.day);
      maxDate = DateTime(now.year - 16, now.month, now.day);
      initialDate = DateTime.now().subtract(Duration(days: 365 * 30));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isChild) {
          _newChildren[index]['dateOfBirth'] = picked.toIso8601String();
        } else {
          _newAdults[index]['dateOfBirth'] = picked.toIso8601String();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.primary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'Modify Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.15)),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColor.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColor.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.edit_calendar_rounded, size: 22),
                  text: 'Modify',
                ),
                Tab(
                  icon: Icon(Icons.receipt_long_rounded, size: 22),
                  text: 'Price',
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildModifyTab(), _buildPriceTab()],
            ),
          ),
        ],
      ),
      // Bottom bar changes based on active tab
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index == 0) {
            return _buildFetchPriceBar();
          } else {
            return _buildConfirmBar();
          }
        },
      ),
    );
  }

  // ─── MODIFY TAB (Date + Guests combined) ────────────────────────────────────

  Widget _buildModifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dates Section ──
          _buildSectionHeader(
            icon: Icons.date_range_rounded,
            title: 'Stay Dates',
            subtitle: 'Select your new check-in and check-out dates',
          ),
          const SizedBox(height: 16),

          // Date row
          Row(
            children: [
              Expanded(
                child: _buildDateCard(
                  icon: Icons.login_rounded,
                  label: 'Check-in',
                  date: _checkInDate,
                  onTap: _selectCheckInDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateCard(
                  icon: Icons.logout_rounded,
                  label: 'Check-out',
                  date: _checkOutDate,
                  onTap: _selectCheckOutDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nights pill
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.nights_stay_rounded,
                    color: AppColor.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_checkOutDate.difference(_checkInDate).inDays} Night(s)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Existing Guests Section ──
          _buildSectionHeader(
            icon: Icons.people_alt_rounded,
            title: 'Guest Information',
            subtitle: 'Existing guests and add new ones',
          ),
          const SizedBox(height: 16),

          if (_primaryGuest != null) ...[
            _buildSectionLabel('PRIMARY GUEST'),
            const SizedBox(height: 8),
            _buildGuestCard(
              firstName: _primaryGuest!['firstName'] ?? '',
              lastName: _primaryGuest!['lastName'] ?? '',
              email: _primaryGuest!['email'],
              phone: _primaryGuest!['phoneNumber'],
              dateOfBirth: _primaryGuest!['dateOfBirth'],
              isPrimary: true,
            ),
            const SizedBox(height: 16),
          ],

          if (_guests.isNotEmpty) ...[
            _buildSectionLabel('ADDITIONAL GUESTS'),
            const SizedBox(height: 8),
            ...List.generate(_guests.length, (index) {
              final guest = _guests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildGuestCard(
                  firstName: guest['firstName'] ?? '',
                  lastName: guest['lastName'] ?? '',
                  dateOfBirth: guest['dateOfBirth'],
                  isPrimary: false,
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // ── Add New Guests ──
          _buildSectionLabel('ADD NEW GUESTS'),
          const SizedBox(height: 12),

          _buildAddGuestSection(
            title: 'Adults',
            icon: Icons.person_add_rounded,
            guests: _newAdults,
            onAdd: _addAdult,
            onRemove: _removeAdult,
            onSelectDOB: (index) => _selectDateOfBirth(false, index),
            isChild: false,
          ),
          const SizedBox(height: 12),

          _buildAddGuestSection(
            title: 'Children',
            icon: Icons.child_care_rounded,
            guests: _newChildren,
            onAdd: _addChild,
            onRemove: _removeChild,
            onSelectDOB: (index) => _selectDateOfBirth(true, index),
            isChild: true,
          ),

          // Bottom padding so content isn't hidden behind bottom bar
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColor.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDateCard({
    required IconData icon,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColor.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                Icon(Icons.edit_rounded, color: Colors.grey[400], size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGuestSection({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> guests,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Function(int) onSelectDOB,
    required bool isChild,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColor.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (guests.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            ...List.generate(guests.length, (index) {
              final guest = guests[index];
              final singularTitle = title.substring(
                0,
                title.length - 1,
              ); // Adult / Child
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$singularTitle ${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => onRemove(index),
                          child: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            hint: 'First Name',
                            value: guest['firstName'],
                            onChanged: (v) => guest['firstName'] = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextField(
                            hint: 'Last Name',
                            value: guest['lastName'],
                            onChanged: (v) => guest['lastName'] = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => onSelectDOB(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              guest['dateOfBirth'] != null
                                  ? _formatDate(
                                      DateTime.parse(guest['dateOfBirth']),
                                    )
                                  : 'Date of Birth',
                              style: TextStyle(
                                fontSize: 13,
                                color: guest['dateOfBirth'] != null
                                    ? Colors.black87
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required String value,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primary),
        ),
      ),
      style: const TextStyle(fontSize: 13),
      onChanged: onChanged,
    );
  }

  Widget _buildGuestCard({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    required bool isPrimary,
  }) {
    final name = '$firstName $lastName'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColor.primary.withOpacity(0.1),
                child: Text(
                  '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                      .toUpperCase(),
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name.isNotEmpty ? name : 'Guest',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'PRIMARY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                    if (phone != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (dateOfBirth != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.cake_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'DOB: ',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  _formatDate(DateTime.parse(dateOfBirth)),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── PRICE TAB ──────────────────────────────────────────────────────────────

  Widget _buildPriceTab() {
    if (_isLoadingPrice) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColor.primary),
            const SizedBox(height: 16),
            Text(
              'Calculating updated price...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (!_priceFetched && _priceData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No price fetched yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Go back and tap "Fetch Updated Price"',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    final priceData = _priceData!;
    final currency = priceData['currencyCode'] ?? 'USD';
    final amountBeforeTax =
        (priceData['amountBeforeTax'] as num?)?.toDouble() ?? 0.0;
    final taxedAmount = (priceData['taxedAmount'] as num?)?.toDouble() ?? 0.0;
    final totalAmount = (priceData['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final dailyBreakdown = priceData['dailyPriceBrakeDown'] as List? ?? [];
    final taxBreakdown = priceData['taxBrakeDown'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary banner
          _buildSectionHeader(
            icon: Icons.receipt_long_rounded,
            title: 'Price Breakdown',
            subtitle: 'Updated pricing for your modified booking',
          ),
          const SizedBox(height: 20),

          // Dates summary chip row
          Row(
            children: [
              _buildInfoChip(Icons.login_rounded, _formatDate(_checkInDate)),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.logout_rounded, _formatDate(_checkOutDate)),
            ],
          ),
          const SizedBox(height: 20),

          // Base amount
          _buildPriceRow(
            label: 'Base Amount',
            value: '$currency ${amountBeforeTax.toStringAsFixed(2)}',
            isSubtitle: true,
          ),
          const Divider(height: 24),

          // Daily Breakdown
          if (dailyBreakdown.isNotEmpty) ...[
            _buildSectionLabel('DAILY CHARGES'),
            const SizedBox(height: 10),
            ...dailyBreakdown.map((day) {
              final date = day['date'] ?? '';
              final base =
                  (day['baseChargesAmount'] as num?)?.toDouble() ?? 0.0;
              final total = (day['totalAmount'] as num?)?.toDouble() ?? 0.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currency ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColor.primary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Base: $currency ${base.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Taxes
          if (taxBreakdown.isNotEmpty) ...[
            _buildSectionLabel('TAXES & FEES'),
            const SizedBox(height: 10),
            ...taxBreakdown.map((tax) {
              final name = tax['name'] ?? '';
              final amount = (tax['taxedAmount'] as num?)?.toDouble() ?? 0.0;
              return _buildPriceRow(
                label: name,
                value: '+$currency ${amount.toStringAsFixed(2)}',
                valueColor: Colors.grey[700],
              );
            }),
            const SizedBox(height: 8),
          ],

          const Divider(height: 24),

          // Total card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primary, AppColor.primary.withOpacity(0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Taxes & fees included',
                      style: TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
                Text(
                  '$currency ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    bool isSubtitle = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSubtitle ? 14 : 13,
              fontWeight: isSubtitle ? FontWeight.w600 : FontWeight.w500,
              color: isSubtitle ? const Color(0xFF1A2236) : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSubtitle ? 15 : 13,
              fontWeight: FontWeight.w600,
              color:
                  valueColor ??
                  (isSubtitle ? const Color(0xFF1A2236) : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM BARS ────────────────────────────────────────────────────────────

  Widget _buildFetchPriceBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoadingPrice ? null : _fetchModifiedPrice,
            icon: _isLoadingPrice
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.price_check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
            label: Text(
              _isLoadingPrice ? 'Fetching Price...' : 'Fetch Updated Price',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back to modify link
            TextButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: Icon(Icons.edit_rounded, size: 16, color: AppColor.primary),
              label: Text(
                'Edit dates or guests',
                style: TextStyle(color: AppColor.primary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitModification,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isLoading ? 'Processing...' : 'Confirm Changes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SUBMIT ─────────────────────────────────────────────────────────────────

  Future<void> _submitModification() async {
    if (_bookingCode == null || _bookingData == null) {
      Get.snackbar(
        'Error',
        'Booking data not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> guests = [];

      for (var guest in _guests) {
        final dob = guest['dateOfBirth'] ?? '';
        if (guest['type'] == 'child') {
          guests.add({
            'type': guest['type'] ?? 'child',
            'firstName': guest['firstName'] ?? '',
            'lastName': guest['lastName'] ?? '',
            'dob': dob,
            'age': dob.isNotEmpty
                ? (DateTime.now().difference(DateTime.parse(dob)).inDays ~/ 365)
                : 0,
          });
        } else {
          guests.add({
            'type': guest['type'] ?? 'adult',
            'firstName': guest['firstName'] ?? '',
            'lastName': guest['lastName'] ?? '',
            'dateOfBirth': dob,
          });
        }
      }

      for (var adult in _newAdults) {
        final dob = adult['dateOfBirth'] != null
            ? DateTime.parse(
                adult['dateOfBirth'],
              ).toIso8601String().split('T')[0]
            : '';
        guests.add({
          'type': 'adult',
          'firstName': adult['firstName'] ?? '',
          'lastName': adult['lastName'] ?? '',
          'dateOfBirth': dob,
        });
      }

      for (var child in _newChildren) {
        final dob = child['dateOfBirth'] != null
            ? DateTime.parse(
                child['dateOfBirth'],
              ).toIso8601String().split('T')[0]
            : '';
        guests.add({
          'type': 'child',
          'firstName': child['firstName'] ?? '',
          'lastName': child['lastName'] ?? '',
          'dob': dob,
          'age': dob.isNotEmpty
              ? (DateTime.now().difference(DateTime.parse(dob)).inDays ~/ 365)
              : 0,
        });
      }

      final totalAdults = guests.where((g) => g['type'] == 'adult').length;
      final totalChildren = guests.where((g) => g['type'] == 'child').length;

      final priceData = _priceData ?? {};
      final currencyCode = priceData['currencyCode'] ?? 'USD';
      final totalAmount = (priceData['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final amountBeforeTax =
          (priceData['amountBeforeTax'] as num?)?.toDouble() ?? 0.0;
      final taxedAmount = (priceData['taxedAmount'] as num?)?.toDouble() ?? 0.0;
      final totalAddonAmount =
          (priceData['totalAddonAmount'] as num?)?.toDouble() ?? 0.0;
      final totalPromotionAmount =
          (priceData['totalPromotionAmount'] as num?)?.toDouble() ?? 0.0;
      final currentChargeableAmount =
          (priceData['currentChargeableAmount'] as num?)?.toDouble() ??
          totalAmount;
      final latterpayableAmount =
          (priceData['latterpayableAmount'] as num?)?.toDouble() ?? 0.0;

      final finalPrice = {
        'totalAmount': totalAmount,
        'amountBeforeTax': amountBeforeTax,
        'taxedAmount': taxedAmount,
        'totalAddonAmount': totalAddonAmount,
        'totalPromotionAmount': totalPromotionAmount,
        'currentChargeableAmount': currentChargeableAmount,
        'latterpayableAmount': latterpayableAmount,
        'loyalityDiscount': priceData['loyalityDiscount'] ?? 0,
        'promoCodeDiscount': priceData['promoCodeDiscount'] ?? 0,
        'currencyCode': currencyCode,
        'dailyPriceBrakeDown': priceData['dailyPriceBrakeDown'] ?? [],
        'taxBrakeDown': priceData['taxBrakeDown'] ?? [],
        'addonBrakeDown': priceData['addonBrakeDown'] ?? [],
        'promotionBrakeDown': priceData['promotionBrakeDown'] ?? [],
        'booking': {
          'finalPayable': totalAmount,
          'refundAmount': 0,
          'discount': totalPromotionAmount,
        },
      };

      final payload = {
        'propertyCode': _bookingData!['propertyCode'] ?? '',
        'checkInDate': _checkInDate.toIso8601String().split('T')[0],
        'checkOutDate': _checkOutDate.toIso8601String().split('T')[0],
        'requestedRooms': 1,
        'rooms': [
          {'adults': totalAdults, 'children': totalChildren, 'childAges': []},
        ],
        'previousRooms': 1,
        'guests': guests,
        'roomTypeCode': _bookingData!['roomTypeCode'] ?? '',
        'ratePlanCode': _bookingData!['ratePlanCode'] ?? '',
        'amount': totalAmount,
        'finalPrice': finalPrice,
        'currencyCode': currencyCode,
        'bookingUserEmail': _bookingData!['bookingUserEmail'] ?? '',
        'bookingUserPhone': _bookingData!['bookingUserPhone'] ?? '',
        'status': 'Modified',
        'extraAmountToPay': totalAmount,
        'refundAmount': 0,
      };

      final result = await _apiController.updateBooking(
        bookingCode: _bookingCode!,
        payload: payload,
      );

      if (result['success'] == true && mounted) {
        Get.back(result: {'success': true, 'modifiedData': payload});
        Get.snackbar(
          'Booking Modified',
          'Your booking changes have been submitted for processing.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else if (mounted) {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to modify booking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
