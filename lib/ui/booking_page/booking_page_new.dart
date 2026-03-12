import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'package:group/group/models/booking_data_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_page.dart';
import '../../ui/dialog/dialog.dart';
import 'price_breakdown_widget.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> room;
  final Map<String, dynamic> ratePlan;
  final int totalGuests;
  final int adults;
  final int children;
  final String startDate;
  final String endDate;
  final String propertyId;
  final String propertyCode;
  final String hotelName;
  final List<Map<String, dynamic>>? addons;
  final bool discountApplied;
  final int discountedPrice;
  final String? guestEmail;

  const BookingPage({
    Key? key,
    required this.room,
    required this.ratePlan,
    required this.totalGuests,
    required this.adults,
    required this.children,
    required this.startDate,
    required this.endDate,
    required this.propertyId,
    required this.propertyCode,
    required this.hotelName,
    this.addons,
    this.discountApplied = false,
    this.discountedPrice = 0,
    this.guestEmail,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _priceData;
  List<Map<String, dynamic>> _selectedAddons = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<Map<String, TextEditingController>> _adultControllers = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    if (widget.addons != null) {
      _selectedAddons = List<Map<String, dynamic>>.from(widget.addons!);
    }

    if (widget.guestEmail != null && widget.guestEmail!.isNotEmpty) {
      _emailController.text = widget.guestEmail!;
    }

    for (int i = 0; i < widget.adults; i++) {
      _adultControllers.add({
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'dob': TextEditingController(),
      });
    }
    _getPrice();
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (var controllers in _adultControllers) {
      controllers['firstName']?.dispose();
      controllers['lastName']?.dispose();
      controllers['dob']?.dispose();
    }
    super.dispose();
  }

  Future<void> _getPrice() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final BuildContext currentContext = context; // capture context before async

    try {
      final Map<String, dynamic> payload = {
        "propertyCode": widget.propertyCode,
        "invTypeCode":
            widget.room['room_type'] ?? widget.room['invTypeCode'] ?? '',
        "ratePlanCode": widget.ratePlan['ratePlanCode'] ?? '',
        "startDate": widget.startDate,
        "endDate": widget.endDate,
        "noOfAdults": widget.adults,
        "noOfChildren": widget.children,
        "noOfRooms": 1,
        "promoCode": "",
      };

      if (widget.discountApplied && widget.guestEmail != null) {
        payload['guestEmail'] = widget.guestEmail;
      }

      if (_selectedAddons.isNotEmpty) {
        final List<Map<String, dynamic>> parsedAddons = [];
        for (var addon in _selectedAddons) {
          parsedAddons.add({
            "addOnId": addon['id'] ?? '',
            "availability": [
              {
                "date": "${widget.startDate}T00:00:00.000Z",
                "quantity": addon['quantity'] ?? 1,
              },
            ],
          });
        }
        payload['parsedAddons'] = parsedAddons;
        payload['includedAddons'] = _selectedAddons
            .map((addon) => addon['id'] ?? '')
            .toList();
      }

      final result = await Get.find<ApiController>().getPrice(payload);

      if (!mounted) return; // check after await

      if (result['success'] == true) {
        setState(() {
          _priceData = result['data'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        _showError(
          currentContext,
          result['error'] ?? result['message'] ?? 'Failed to get price',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError(currentContext, 'Error getting price: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper method for pretty printing
  void _prettyPrintJson(dynamic json) {
    try {
      String prettyString = const JsonEncoder.withIndent('  ').convert(json);
      print(prettyString);
    } catch (e) {
      print('Error formatting JSON: $e');
      print(json);
    }
  }

  void _showError(BuildContext context, String message) {
    if (!mounted) return;

    setState(() => _isLoading = false);

    showErrorDialog(
      context,
      message,
      onPressed: () {
        Navigator.of(context).pop(); // Pop the dialog
        Get.offNamed('/rooms'); // Navigate directly to rooms page
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime today = DateTime.now();
    final DateTime seventeenyearsago = DateTime(
      today.year - 17,
      today.month,
      today.day,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 17, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: seventeenyearsago,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: AppColor.primary)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  int _calculateNights() {
    try {
      final start = DateTime.parse(widget.startDate);
      final end = DateTime.parse(widget.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 1;
    }
  }

  double _calculateAddonsTotal() {
    if (_selectedAddons.isEmpty) return 0;
    return _selectedAddons.fold<double>(
      0,
      (sum, addon) =>
          sum +
          ((addon['price'] as num) * (addon['quantity'] as num)).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addonsTotal = _calculateAddonsTotal();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Column(
        children: [
          _buildRoyalHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGuestSection(),
                      const SizedBox(height: 10),
                      _buildContactSection(),
                      if (_selectedAddons.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildAddonsSection(addonsTotal),
                      ],
                      if (_priceData != null) ...[
                        const SizedBox(height: 10),
                        _buildPriceSummarySection(addonsTotal),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildRoyalFooter(),
    );
  }

  // ─── Royal Header ────────────────────────────────────────────────────────────

  Widget _buildRoyalHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.primary,
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => {Get.back(), Get.back()},
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'RESERVATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  if (widget.discountApplied)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '10% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            _buildHotelBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                      widget.hotelName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _pillBadge(
                          icon: Icons.bed_outlined,
                          label:
                              widget.room['room_type'] ??
                              widget.room['invTypeCode'] ??
                              'Room',
                        ),
                        const SizedBox(width: 8),
                        _pillBadge(
                          icon: Icons.nights_stay_outlined,
                          label: '${_calculateNights()} Nights',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.startDate.substring(5).replaceAll('-', '/'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      height: 1,
                      width: 28,
                      color: Colors.white30,
                    ),
                    Text(
                      widget.endDate.substring(5).replaceAll('-', '/'),
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
          const SizedBox(height: 14),
          _buildProgressRow(),
        ],
      ),
    );
  }

  Widget _pillBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow() {
    return Row(
      children: [
        _progressStep(label: 'Room', isActive: false, isDone: true),
        _progressConnector(isDone: true),
        _progressStep(label: 'Details', isActive: true, isDone: false),
        _progressConnector(isDone: false),
        _progressStep(label: 'Payment', isActive: false, isDone: false),
      ],
    );
  }

  Widget _progressStep({
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColor.secondary
                : isActive
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            border: Border.all(
              color: isActive ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : isActive
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive || isDone
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _progressConnector({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDone
                ? [AppColor.secondary, AppColor.secondary.withOpacity(0.5)]
                : [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
          ),
        ),
      ),
    );
  }

  // ─── Sections ─────────────────────────────────────────────────────────────────

  Widget _buildGuestSection() {
    return _buildRoyalCard(
      sectionTitle: 'GUEST INFORMATION',
      sectionIcon: Icons.person_outline_rounded,
      child: Column(
        children: List.generate(widget.adults, (index) {
          return Column(
            children: [
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 1,
                        width: 24,
                        color: AppColor.primary.withOpacity(0.15),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GUEST ${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primary.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColor.primary.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _buildElegantField(
                      controller: _adultControllers[index]['firstName']!,
                      label: 'First Name',
                      icon: Icons.badge_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'First name is required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildElegantField(
                      controller: _adultControllers[index]['lastName']!,
                      label: 'Last Name',
                      icon: Icons.badge_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Last name is required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () =>
                    _selectDate(context, _adultControllers[index]['dob']!),
                borderRadius: BorderRadius.circular(10),
                child: IgnorePointer(
                  child: _buildElegantField(
                    controller: _adultControllers[index]['dob']!,
                    label: 'Date of Birth',
                    icon: Icons.cake_outlined,
                    readOnly: true,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildRoyalCard(
      sectionTitle: 'CONTACT DETAILS',
      sectionIcon: Icons.alternate_email_rounded,
      child: Column(
        children: [
          _buildElegantField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            readOnly: widget.guestEmail != null,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter an email address';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                return 'Please enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildElegantField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter a phone number';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddonsSection(double addonsTotal) {
    return _buildRoyalCard(
      sectionTitle: 'SELECTED PRIVILEGES',
      sectionIcon: Icons.workspace_premium_outlined,
      child: Column(
        children: _selectedAddons.map((addon) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.primary.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColor.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon['name'] ?? 'Add-on',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (addon['variant'] != null &&
                          addon['variant'].toString().isNotEmpty)
                        Text(
                          addon['variant'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.primary.withOpacity(0.5),
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
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '×${addon['quantity']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${addon['currencyCode'] ?? 'USD'} ${addon['price']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSummarySection(double addonsTotal) {
    return _buildRoyalCard(
      sectionTitle: 'PRICE SUMMARY',
      sectionIcon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          PriceBreakdownWidget(priceData: _priceData!),

          if (addonsTotal > 0)
            _buildSummaryRow(
              icon: Icons.workspace_premium_outlined,
              label: 'Total Add-ons',
              value:
                  '${_priceData?['currencyCode'] ?? 'USD'} ${addonsTotal.toInt()}',
            ),

          if (widget.discountApplied) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.secondary.withOpacity(0.08),
                    AppColor.secondary.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      color: AppColor.secondary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exclusive Discount Applied',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'You are saving 10% on this reservation',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.secondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.primary.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColor.primary.withOpacity(0.6)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Royal Card Wrapper ───────────────────────────────────────────────────────

  Widget _buildRoyalCard({
    required String sectionTitle,
    required IconData sectionIcon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: AppColor.primary.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(sectionIcon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  // ─── Elegant Text Field ───────────────────────────────────────────────────────

  Widget _buildElegantField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(
        color: readOnly ? AppColor.primary.withOpacity(0.5) : AppColor.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      cursorColor: AppColor.secondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColor.primary.withOpacity(0.5),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColor.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            icon,
            size: 18,
            color: readOnly
                ? AppColor.primary.withOpacity(0.3)
                : AppColor.secondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        filled: true,
        fillColor: readOnly ? AppColor.primary.withOpacity(0.03) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.primary.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.primary.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.secondary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        errorStyle: const TextStyle(fontSize: 11),
        counterText: '',
      ),
      validator: validator,
    );
  }

  // ─── Royal Footer ─────────────────────────────────────────────────────────────

  Widget _buildRoyalFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColor.primary.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Get.toNamed('/rooms'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: AppColor.primary.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary.withOpacity(0.5),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    disabledBackgroundColor: AppColor.primary.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'PROCEED TO PAYMENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Business Logic (unchanged) ───────────────────────────────────────────────

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Please fill in all required fields');
      return;
    }
    List<Map<String, dynamic>> guestDetails = [];
    for (var controllers in _adultControllers) {
      guestDetails.add({
        'type': 'adult',
        'firstName': controllers['firstName']?.text ?? '',
        'lastName': controllers['lastName']?.text ?? '',
        'dateOfBirth': controllers['dob']?.text ?? '',
      });
    }

    final numberOfNights = _calculateNights();

    final totalAmount =
        (widget.discountApplied
                ? widget.discountedPrice
                : (_priceData?['totalAmount'] ??
                      widget.ratePlan['totalAmount'] ??
                      0))
            as num;

    List<Map<String, dynamic>> taxBreakdown = [];
    if (_priceData != null && _priceData!['tax'] != null) {
      taxBreakdown = List<Map<String, dynamic>>.from(_priceData!['tax']);
    } else {
      taxBreakdown = [
        {'name': 'VAT', 'taxedAmount': 15, 'currencyCode': 'USD'},
        {'name': 'Service Charge', 'taxedAmount': 31.5, 'currencyCode': 'USD'},
        {
          'name': 'Municipality Fee',
          'taxedAmount': 24.255,
          'currencyCode': 'USD',
        },
      ];
    }

    double totalTaxAmount = 0;
    for (var tax in taxBreakdown) {
      totalTaxAmount += (tax['taxedAmount'] as num?)?.toDouble() ?? 0;
    }

    List<Map<String, dynamic>> addonBreakdown = [];
    if (_selectedAddons.isNotEmpty) {
      addonBreakdown = _selectedAddons.map((addon) {
        final price = (addon['price'] as num?) ?? 0;
        final quantity = (addon['quantity'] as num?) ?? 1;
        return {
          'addonId': addon['id'] ?? '',
          'name': addon['name'] ?? '',
          'amount': price,
          'quantity': quantity,
          'totalAmount': price * quantity,
          'currencyCode': addon['currencyCode'] ?? 'USD',
          'date': _formatDateForApi(widget.startDate),
        };
      }).toList();
    }

    double addonsTotal = 0;
    for (var addon in addonBreakdown) {
      addonsTotal += (addon['totalAmount'] as num?)?.toDouble() ?? 0;
    }

    List<Map<String, dynamic>> dailyBreakdown = [];
    if (_priceData != null && _priceData!['dailyBreakdown'] != null) {
      dailyBreakdown =
          (_priceData!['dailyBreakdown'] as List?)?.map((day) {
            final baseRate =
                (day['baseRate'] as num?) ??
                (day['baseChargesAmount'] as num?) ??
                300;
            final totalPerRoom =
                (day['totalPerRoom'] as num?) ??
                (day['totalAmount'] as num?) ??
                totalAmount;
            return {
              'date': _formatDateForApi(day['date'] ?? widget.startDate),
              'dayOfWeek': _getDayOfWeek(day['date'] ?? widget.startDate),
              'ratePlanCode': widget.ratePlan['ratePlanCode'] ?? '',
              'baseRate': baseRate,
              'baseRatePerNight': baseRate,
              'baseChargesAmount':
                  (day['baseChargesAmount'] as num?) ?? baseRate,
              'additionalChargesAmount':
                  (day['additionalChargesAmount'] as num?) ?? 0,
              'totalPerRoom': totalPerRoom,
              'totalForAllRooms':
                  (day['totalForAllRooms'] as num?) ?? totalPerRoom,
              'totalAmount': (day['totalAmount'] as num?) ?? totalAmount,
              'totalDailyTaxedAmount':
                  (day['totalDailyTaxedAmount'] as num?) ?? totalTaxAmount,
              'currencyCode': day['currencyCode'] ?? 'USD',
              'taxBrakeDown': taxBreakdown,
              'addOnBrakeDown': [],
            };
          }).toList() ??
          [];
    } else {
      dailyBreakdown = [
        {
          'date': _formatDateForApi(widget.startDate),
          'dayOfWeek': _getDayOfWeek(widget.startDate),
          'ratePlanCode': widget.ratePlan['ratePlanCode'] ?? '',
          'baseRate': 300,
          'baseRatePerNight': 300,
          'baseChargesAmount': 300,
          'additionalChargesAmount': 0,
          'totalPerRoom': totalAmount,
          'totalForAllRooms': totalAmount,
          'totalAmount': totalAmount,
          'totalDailyTaxedAmount': totalTaxAmount,
          'currencyCode': 'USD',
          'taxBrakeDown': taxBreakdown,
          'addOnBrakeDown': [],
        },
      ];
    }

    List<Map<String, dynamic>> dailyPriceBreakdown = [];
    if (_priceData != null && _priceData!['dailyPriceBrakeDown'] != null) {
      dailyPriceBreakdown = List<Map<String, dynamic>>.from(
        _priceData!['dailyPriceBrakeDown'] as List? ?? [],
      );
    } else {
      dailyPriceBreakdown = [
        {
          'date': _formatDateForApi(widget.startDate),
          'baseChargesAmount': 300,
          'additionalChargesAmount': 0,
          'totalAmount': (totalAmount as num) - addonsTotal,
          'currencyCode': 'USD',
          'totalDailyTaxedAmount': totalTaxAmount,
          'taxBrakeDown': taxBreakdown,
          'addOnBrakeDown': addonBreakdown,
        },
      ];
    }

    final discountAmount = widget.discountApplied
        ? ((totalAmount as num) * 0.1)
        : 0;

    final enhancedFinalPrice = {
      'totalAmount': totalAmount,
      'amountBeforeTax': (_priceData?['amountBeforeTax'] as num?) ?? 300,
      'taxedAmount': totalTaxAmount,
      'totalAddonAmount': addonsTotal,
      'totalPromotionAmount': discountAmount,
      'currentChargeableAmount': (totalAmount as num) - discountAmount,
      'latterpayableAmount': discountAmount,
      'loyalityDiscount': 0,
      'promoCodeDiscount': 0,
      'currencyCode': widget.ratePlan['currencyCode'] ?? 'USD',
      'numberOfNights': numberOfNights,
      'baseRatePerNight': (_priceData?['baseRatePerNight'] as num?) ?? 300,
      'requestedRooms': 1,
      'additionalGuestCharges':
          (_priceData?['additionalGuestCharges'] as num?) ?? 0,
      'totalTaxAmount': totalTaxAmount,
      'taxBrakeDown': taxBreakdown,
      'addonBrakeDown': addonBreakdown,
      'promotionBrakeDown': widget.discountApplied
          ? [
              {
                'id': 'discount-${DateTime.now().millisecondsSinceEpoch}',
                'promotionType': 'normal',
                'name': '10% Discount',
                'discountType': 'percentage',
                'discountValue': 10,
                'currencyCode': 'USD',
                'discountAmount': discountAmount,
                'restrictionType': 'payNow',
              },
            ]
          : [],
      'dailyBreakdown': dailyBreakdown,
      'dailyPriceBrakeDown': dailyPriceBreakdown,
    };

    final bookingDetails = {
      'startDate': widget.startDate,
      'endDate': widget.endDate,
      'propertyCode': widget.propertyCode,
      'hotelName': widget.hotelName,
      'roomTypeCode': widget.room['room_type'],
      'numberOfRooms': 1,
      'currency': widget.ratePlan['currencyCode'] ?? 'USD',
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'finalPrice': enhancedFinalPrice,
      'guests': {
        'rooms': 1,
        'adults': widget.adults,
        'children': widget.children,
      },
      'guestDetails': guestDetails,
      'ratePlanCode': widget.ratePlan['ratePlanCode'],
      'paymentMethod': 'pay_at_hotel',
      'bookingSource': 'direct',
      'selectedPromotions': widget.discountApplied ? ['10% Discount'] : [],
      'selectedAddons': _selectedAddons.map((a) => a['id']).toList(),
      'promoCode': null,
    };

    Get.to(
      () => PaymentPage(
        priceData: enhancedFinalPrice,
        paymentData: {},
        bookingDetails: bookingDetails,
        propertyId: widget.propertyId,
      ),
    );
  }

  String _formatDateForApi(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      List<String> months = [
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
      List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      String dayName = days[dateTime.weekday % 7];
      String monthName = months[dateTime.month - 1];
      String day = dateTime.day.toString().padLeft(2, '0');
      String year = dateTime.year.toString();
      return '$dayName $monthName $day $year';
    } catch (e) {
      return date;
    }
  }

  String _getDayOfWeek(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      List<String> days = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];
      return days[dateTime.weekday % 7];
    } catch (e) {
      return 'Saturday';
    }
  }
}
