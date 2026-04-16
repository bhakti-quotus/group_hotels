import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/api_controller.dart';
import 'package:royalcontinent/ui/dialog/dialog.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'price_breakdown_widget.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic>
  priceData; // This comes from get-price API via BookingPage
  final Map<String, dynamic> paymentData;
  final Map<String, dynamic> bookingDetails;
  final String propertyId;

  const PaymentPage({
    super.key,
    required this.priceData,
    required this.paymentData,
    required this.bookingDetails,
    required this.propertyId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  bool _isLoadingPaymentData = true;
  Map<String, dynamic>? _fetchedPaymentData;
  String? _errorMessage;
  String? _selectedPaymentMethod;
  File? _paymentScreenshot;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingBooking = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final GlobalKey _priceInfoIconKey = GlobalKey();
  final GlobalKey<PriceBreakdownWidgetState> _priceWidgetKey =
      GlobalKey<PriceBreakdownWidgetState>();

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

    // Print the price data received from BookingPage for debugging
    print('=== PAYMENT PAGE: PRICE DATA FROM API ===');
    print('Price Data: ${json.encode(widget.priceData)}');
    print('=========================================');

    _fetchPaymentDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentDetails() async {
    setState(() {
      _isLoadingPaymentData = true;
      _errorMessage = null;
    });

    try {
      final result = await Get.find<ApiController>().fetchPaymentDetails(
        widget.propertyId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _fetchedPaymentData = result['data'];
          _isLoadingPaymentData = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoadingPaymentData = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching payment details';
        _isLoadingPaymentData = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text('$label copied'),
          ],
        ),
        backgroundColor: AppColor.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() => _paymentScreenshot = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() => _paymentScreenshot = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeScreenshot() => setState(() => _paymentScreenshot = null);

  bool get _isCompleteBookingEnabled {
    if (_isProcessingBooking) return false;
    if (_selectedPaymentMethod == null) return false;
    if (_selectedPaymentMethod == 'payAtHotel') return true;
    if (_selectedPaymentMethod == 'upi' ||
        _selectedPaymentMethod == 'bankTransfer') {
      return _paymentScreenshot != null;
    }
    if (_selectedPaymentMethod == 'gateway') return true;
    return false;
  }

  String _getHintText() {
    if (_isProcessingBooking) return 'Processing your reservation...';
    if (_selectedPaymentMethod == null) {
      return 'Please select a payment method to continue';
    }
    if ((_selectedPaymentMethod == 'upi' ||
            _selectedPaymentMethod == 'bankTransfer') &&
        _paymentScreenshot == null) {
      return 'Please upload payment proof to continue';
    }
    return '';
  }

  // Simple helper to safely get double values - NO CALCULATIONS
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '—';
    try {
      final d = DateTime.parse(date);
      final months = [
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
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  int _calculateNights() {
    try {
      final start = DateTime.parse(widget.bookingDetails['startDate'] ?? '');
      final end = DateTime.parse(widget.bookingDetails['endDate'] ?? '');
      return end.difference(start).inDays;
    } catch (_) {
      return 1;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReservationSummaryCard(),
                    const SizedBox(height: 10),
                    _buildGuestDetailsCard(),
                    const SizedBox(height: 10),
                    _buildRoyalCard(
                      sectionTitle: 'PRICE SUMMARY',
                      sectionIcon: Icons.receipt_long_outlined,
                      trailingAction: GestureDetector(
                        key: _priceInfoIconKey,
                        onTap: () => _priceWidgetKey.currentState
                            ?.showPriceDetailsPopup(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColor.primary.withOpacity(0.15),
                            ),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                      child: PriceBreakdownWidget(
                        key: _priceWidgetKey,
                        priceData: widget.priceData,
                        infoIconKey: _priceInfoIconKey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOptionsCard(),
                    if (_selectedPaymentMethod == 'upi' ||
                        _selectedPaymentMethod == 'bankTransfer') ...[
                      const SizedBox(height: 10),
                      _buildScreenshotUploadSection(),
                    ],
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'SECURE PAYMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildProgressRow(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow() {
    return Row(
      children: [
        _progressStep(label: 'Room', isActive: false, isDone: true),
        _progressConnector(isDone: true),
        _progressStep(label: 'Details', isActive: false, isDone: true),
        _progressConnector(isDone: true),
        _progressStep(label: 'Payment', isActive: true, isDone: false),
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
                ? [AppColor.secondary, AppColor.secondary.withOpacity(0.6)]
                : [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
          ),
        ),
      ),
    );
  }

  // ─── Reservation Summary ──────────────────────────────────────────────────────

  Widget _buildReservationSummaryCard() {
    final nights = _calculateNights();
    final bd = widget.bookingDetails;
    final guests = bd['guests'] as Map<String, dynamic>? ?? {};

    return _buildRoyalCard(
      sectionTitle: 'RESERVATION SUMMARY',
      sectionIcon: Icons.hotel_outlined,
      child: Column(
        children: [
          // Hotel name row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (bd['hotelName'] ?? 'Hotel').toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      bd['roomTypeCode']?.toString() ?? 'Standard Room',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.primary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _datePill(
                    label: 'CHECK-IN',
                    date: _formatDate(bd['startDate']),
                    icon: Icons.login_rounded,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$nights N',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColor.primary.withOpacity(0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _datePill(
                    label: 'CHECK-OUT',
                    date: _formatDate(bd['endDate']),
                    icon: Icons.logout_rounded,
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Guest count row
          Row(
            children: [
              _guestChip(
                icon: Icons.person_outline,
                label:
                    '${guests['adults'] ?? 1} Adult${(guests['adults'] ?? 1) > 1 ? 's' : ''}',
              ),
              if ((guests['children'] ?? 0) > 0) ...[
                const SizedBox(width: 8),
                _guestChip(
                  icon: Icons.child_care_outlined,
                  label: '${guests['children']} Child',
                ),
              ],
              const SizedBox(width: 8),
              _guestChip(
                icon: Icons.bed_outlined,
                label: '${guests['rooms'] ?? 1} Room',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePill({
    required String label,
    required String date,
    required IconData icon,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.primary.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: alignRight
              ? [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 14, color: AppColor.secondary),
                ]
              : [
                  Icon(icon, size: 14, color: AppColor.secondary),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
        ),
      ],
    );
  }

  Widget _guestChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.primary.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColor.primary.withOpacity(0.6)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Guest Details ────────────────────────────────────────────────────────────

  Widget _buildGuestDetailsCard() {
    final guestDetails = widget.bookingDetails['guestDetails'] as List? ?? [];
    final email = widget.bookingDetails['email'] ?? '';
    final phone = widget.bookingDetails['phone'] ?? '';

    // Separate adults and children
    final adults = guestDetails
        .where((g) => (g['type']?.toString().toLowerCase() ?? '') == 'adult')
        .toList();
    final children = guestDetails
        .where((g) => (g['type']?.toString().toLowerCase() ?? '') == 'child')
        .toList();

    return _buildRoyalCard(
      sectionTitle: 'GUEST DETAILS',
      sectionIcon: Icons.person_outline_rounded,
      child: Column(
        children: [
          // Adults section
          if (adults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'ADULTS (${adults.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary.withOpacity(0.6),
                ),
              ),
            ),
            ...adults.asMap().entries.map((entry) {
              final i = entry.key;
              final guest = entry.value as Map<String, dynamic>;
              final firstName = guest['firstName'] ?? '';
              final lastName = guest['lastName'] ?? '';
              final dob = guest['dateOfBirth'] ?? '';
              final fullName = '$firstName $lastName'.trim();

              return Container(
                margin: EdgeInsets.only(bottom: i < adults.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isNotEmpty
                                ? fullName
                                : 'Adult Guest ${i + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                            ),
                          ),
                          if (dob.isNotEmpty)
                            Text(
                              'DOB: ${_formatDate(dob)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.primary.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ADULT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColor.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Children section (below adults)
          if (children.isNotEmpty) ...[
            if (adults.isNotEmpty) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'CHILDREN (${children.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondary.withOpacity(0.8),
                ),
              ),
            ),
            ...children.asMap().entries.map((entry) {
              final i = entry.key;
              final guest = entry.value as Map<String, dynamic>;
              final firstName = guest['firstName'] ?? '';
              final lastName = guest['lastName'] ?? '';
              final dob = guest['dateOfBirth'] ?? '';
              final fullName = '$firstName $lastName'.trim();

              return Container(
                margin: EdgeInsets.only(
                  bottom: i < children.length - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColor.secondary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColor.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isNotEmpty
                                ? fullName
                                : 'Child Guest ${i + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                            ),
                          ),
                          if (dob.isNotEmpty)
                            Text(
                              'DOB: ${_formatDate(dob)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.primary.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'CHILD',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColor.secondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Contact info (at bottom)
          if (email.isNotEmpty || phone.isNotEmpty) ...[
            if (guestDetails.isNotEmpty) const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  if (email.isNotEmpty)
                    _contactRow(icon: Icons.mail_outline_rounded, value: email),
                  if (email.isNotEmpty && phone.isNotEmpty)
                    const SizedBox(height: 6),
                  if (phone.isNotEmpty)
                    _contactRow(icon: Icons.phone_outlined, value: phone),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColor.secondary),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.primary,
          ),
        ),
      ],
    );
  }

  // ─── Price Summary ────────────────────────────────────────────────────────────
  // This now uses the simplified PriceBreakdownWidget that directly shows API data

  Widget _buildPriceSummaryCard() {
    return _buildRoyalCard(
      sectionTitle: 'PRICE SUMMARY',
      sectionIcon: Icons.receipt_long_outlined,
      trailingAction: GestureDetector(
        key: _priceInfoIconKey,
        onTap: () =>
            _priceWidgetKey.currentState?.showPriceDetailsPopup(context),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.primary.withOpacity(0.15)),
          ),
          child: Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColor.primary,
          ),
        ),
      ),
      child: PriceBreakdownWidget(
        key: _priceWidgetKey,
        priceData: widget.priceData, // This is the raw API response data
        infoIconKey: _priceInfoIconKey,
      ),
    );
  }

  // ─── Payment Options ──────────────────────────────────────────────────────────

  Widget _buildPaymentOptionsCard() {
    return _buildRoyalCard(
      sectionTitle: 'PAYMENT METHOD',
      sectionIcon: Icons.payment_outlined,
      child: _isLoadingPaymentData
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading payment options...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.primary.withOpacity(0.5),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _errorMessage != null
          ? _buildErrorState()
          : _buildPaymentOptions(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColor.primary.withOpacity(0.4),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: AppColor.primary.withOpacity(0.6),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _fetchPaymentDetails,
            icon: Icon(Icons.refresh, color: AppColor.primary, size: 16),
            label: Text(
              'Retry',
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColor.primary.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    final paymentData = _fetchedPaymentData ?? widget.paymentData;
    final List<Widget> options = [];

    if (paymentData['payAtHotel'] == true) {
      options.add(
        _buildPaymentOptionCard(
          icon: Icons.hotel_outlined,
          title: 'Pay at Hotel',
          subtitle: 'Pay upon arrival at the property',
          paymentData: paymentData,
          paymentMethodKey: 'payAtHotel',
        ),
      );
    }

    if (paymentData['upi'] == true) {
      if (options.isNotEmpty) options.add(const SizedBox(height: 12));
      options.add(
        _buildPaymentOptionCard(
          icon: Icons.phone_android_outlined,
          title: 'UPI Payment',
          subtitle: 'Google Pay, PhonePe, Paytm & more',
          paymentData: paymentData,
          paymentMethodKey: 'upi',
        ),
      );
    }

    if (paymentData['bankTransfer'] == true) {
      if (options.isNotEmpty) options.add(const SizedBox(height: 12));
      options.add(
        _buildPaymentOptionCard(
          icon: Icons.account_balance_outlined,
          title: 'Bank Transfer',
          subtitle: 'Direct transfer to hotel account',
          paymentData: paymentData,
          paymentMethodKey: 'bankTransfer',
        ),
      );
    }

    if (paymentData['gateway'] == true) {
      if (options.isNotEmpty) options.add(const SizedBox(height: 12));
      options.add(
        _buildPaymentOptionCard(
          icon: Icons.credit_card_outlined,
          title: 'Online Payment',
          subtitle: 'Secure gateway — cards & netbanking',
          paymentData: paymentData,
          paymentMethodKey: 'gateway',
        ),
      );
    }

    return Column(children: options);
  }

  Widget _buildPaymentOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Map<String, dynamic>? paymentData,
    String? paymentMethodKey,
  }) {
    final isSelected = _selectedPaymentMethod == paymentMethodKey;
    final currentChargeableAmount = _toDouble(
      widget.priceData['currentChargeableAmount'],
    );
    final currency = widget.priceData['currencyCode'] ?? 'USD';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primary.withOpacity(0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColor.primary
                  : AppColor.primary.withOpacity(0.12),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            onTap: () => setState(() {
              _selectedPaymentMethod = paymentMethodKey;
              _paymentScreenshot = null;
            }),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : AppColor.primary.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.primary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColor.secondary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColor.secondary
                                : AppColor.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 13,
                              )
                            : null,
                      ),
                    ],
                  ),
                  if (isSelected && paymentData != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColor.primary.withOpacity(0.08),
                        ),
                      ),
                      child: paymentMethodKey == 'payAtHotel'
                          ? _buildPayAtHotelDetails(
                              paymentData,
                              currency,
                              currentChargeableAmount,
                            )
                          : paymentMethodKey == 'upi'
                          ? _buildEnhancedUpiDetails(
                              paymentData,
                              currency,
                              currentChargeableAmount,
                            )
                          : paymentMethodKey == 'bankTransfer'
                          ? _buildBankTransferDetails(
                              paymentData,
                              currency,
                              currentChargeableAmount,
                            )
                          : _buildGatewayDetails(paymentData),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // AVAILABLE badge — top right corner
        Positioned(
          top: -1,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.secondary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.secondary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 10),
                SizedBox(width: 4),
                Text(
                  'AVAILABLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Payment Detail Widgets ───────────────────────────────────────────────────

  Widget _buildPayAtHotelDetails(
    Map<String, dynamic> data,
    String currency,
    double amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('INSTRUCTIONS'),
        const SizedBox(height: 10),
        _infoNotice(
          icon: Icons.info_outline_rounded,
          text:
              'Present your booking confirmation at the front desk. '
              'Accepted: cash, debit & credit cards.',
          color: AppColor.primary,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount to pay at hotel:',
                style: TextStyle(fontSize: 12, color: AppColor.primary),
              ),
              Text(
                '$currency ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedUpiDetails(
    Map<String, dynamic> data,
    String currency,
    double amount,
  ) {
    final upiId = data['upiId'] ?? '';
    final name = data['accountHolder'] ?? '';
    final amountStr = amount.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('UPI DETAILS'),
        const SizedBox(height: 10),
        _elegantDetailRow('UPI ID', upiId, showCopy: true),
        _elegantDetailRow('Payee Name', name),
        _elegantDetailRow('Amount', '$currency $amountStr'),
        const SizedBox(height: 14),
        // QR
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.primary.withOpacity(0.15)),
            ),
            child: QrImageView(
              data:
                  'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=$amountStr&cu=INR&tn=Hotel Booking',
              size: 160,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _launchUpiApp(upiId, name, amountStr),
            icon: const Icon(Icons.payment, color: Colors.white, size: 18),
            label: const Text(
              'Open UPI App',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferDetails(
    Map<String, dynamic> data,
    String currency,
    double amount,
  ) {
    final accountHolder = data['accountHolder'] ?? '';
    final accountNumber = data['accountNumber'] ?? '';
    final ifscCode = data['ifscCode'] ?? '';
    final bankName = data['bankName'] ?? '';
    final amountStr = amount.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('BANK DETAILS'),
        const SizedBox(height: 10),
        if (accountHolder.isNotEmpty)
          _elegantDetailRow('Account Holder', accountHolder),
        if (accountNumber.isNotEmpty)
          _elegantDetailRow('Account Number', accountNumber, showCopy: true),
        if (ifscCode.isNotEmpty)
          _elegantDetailRow('IFSC Code', ifscCode, showCopy: true),
        if (bankName.isNotEmpty) _elegantDetailRow('Bank', bankName),
        _elegantDetailRow('Amount', '$currency $amountStr'),
        const SizedBox(height: 12),
        _infoNotice(
          icon: Icons.info_outline_rounded,
          text: 'Upload your payment screenshot below after the transfer.',
          color: AppColor.secondary,
        ),
      ],
    );
  }

  Widget _buildGatewayDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SECURE GATEWAY'),
        const SizedBox(height: 10),
        _infoNotice(
          icon: Icons.security_outlined,
          text:
              'You will be redirected to a secure payment gateway to complete this transaction.',
          color: AppColor.primary,
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: AppColor.primary.withOpacity(0.4),
        letterSpacing: 2,
      ),
    );
  }

  Widget _infoNotice({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _elegantDetailRow(
    String label,
    String value, {
    bool showCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColor.primary.withOpacity(0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ),
                if (showCopy && value.isNotEmpty)
                  GestureDetector(
                    onTap: () => _copyToClipboard(value, label),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: AppColor.secondary,
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

  // ─── Screenshot Upload ────────────────────────────────────────────────────────

  Widget _buildScreenshotUploadSection() {
    return _buildRoyalCard(
      sectionTitle: 'PAYMENT PROOF',
      sectionIcon: Icons.cloud_upload_outlined,
      child: Column(
        children: [
          _infoNotice(
            icon: Icons.info_outline_rounded,
            text:
                'A payment screenshot is required to confirm your reservation.',
            color: AppColor.primary,
          ),
          const SizedBox(height: 16),
          if (_paymentScreenshot == null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.primary.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 28,
                      color: AppColor.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Payment Screenshot',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG or PNG, max 5MB',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.primary.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _captureImage,
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Camera',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(
                              Icons.photo_library_outlined,
                              size: 16,
                              color: AppColor.primary,
                            ),
                            label: Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColor.primary.withOpacity(0.4),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _paymentScreenshot!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.secondary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColor.secondary,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Screenshot uploaded',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _removeScreenshot,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.swap_horiz_rounded,
                        size: 16,
                        color: AppColor.primary,
                      ),
                      label: Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColor.primary.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ─── Royal Card ───────────────────────────────────────────────────────────────

  Widget _buildRoyalCard({
    required String sectionTitle,
    required IconData sectionIcon,
    required Widget child,
    Widget? trailingAction,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (trailingAction != null) trailingAction,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isCompleteBookingEnabled && _getHintText().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _getHintText(),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.primary.withOpacity(0.4),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCompleteBookingEnabled
                      ? _completeBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    disabledBackgroundColor: AppColor.primary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isProcessingBooking
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
                              'CONFIRM RESERVATION',
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
                                Icons.check_rounded,
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

  // ─── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _launchUpiApp(String upiId, String name, String amount) async {
    if (double.tryParse(amount) == null || double.parse(amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid payment amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'upi://pay'
      '?pa=$upiId'
      '&pn=${Uri.encodeComponent(name)}'
      '&am=$amount'
      '&cu=INR'
      '&tn=${Uri.encodeComponent("Hotel Booking Payment")}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open UPI app')));
    }
  }

  // ── Complete Booking ──────────────────────────────────────────────────────────
  void _completeBooking() async {
  if (!_isCompleteBookingEnabled || _isProcessingBooking) return;

  setState(() => _isProcessingBooking = true);

  try {
    // Debug: Check property code in booking details
    print('=== COMPLETE BOOKING DEBUG ===');
    print('Booking details propertyCode: ${widget.bookingDetails['propertyCode']}');
    print('================================');
    
    // Ensure propertyCode is not empty
    String finalPropertyCode = widget.bookingDetails['propertyCode'] as String? ?? '';
    if (finalPropertyCode.isEmpty) {
      print('WARNING: propertyCode is empty in bookingDetails!');
      // Try to get from widget propertyId or other sources
      finalPropertyCode = widget.propertyId; // propertyId might be used as code
      print('Using propertyId as fallback: $finalPropertyCode');
    }
    
    final rawPriceData = widget.priceData;

    final enhancedPriceData = {
      ...rawPriceData,
      'totalAmount': _toDouble(rawPriceData['totalAmount']),
      'amountBeforeTax': _toDouble(rawPriceData['amountBeforeTax']),
      'taxedAmount': _toDouble(rawPriceData['taxedAmount']),
      'totalAddonAmount': _toDouble(rawPriceData['totalAddonAmount']),
      'totalPromotionAmount': _toDouble(
        rawPriceData['totalPromotionAmount'] ?? 0,
      ),
      'currentChargeableAmount': _toDouble(
        rawPriceData['currentChargeableAmount'],
      ),
      'latterpayableAmount': _toDouble(
        rawPriceData['latterpayableAmount'] ?? 0,
      ),
      'loyalityDiscount': _toDouble(rawPriceData['loyalityDiscount'] ?? 0),
      'promoCodeDiscount': _toDouble(rawPriceData['promoCodeDiscount'] ?? 0),
      'currencyCode': rawPriceData['currencyCode'] ?? 'USD',
      'numberOfNights': _calculateNights(),
      'baseRatePerNight': _toDouble(rawPriceData['baseRatePerNight'] ?? 0),
      'requestedRooms': rawPriceData['requestedRooms'] ?? 1,
      'additionalGuestCharges': _toDouble(
        rawPriceData['additionalGuestCharges'] ?? 0,
      ),
      'totalTaxAmount': _toDouble(rawPriceData['taxedAmount']),
      'taxBrakeDown':
          rawPriceData['taxBrakeDown'] ?? rawPriceData['taxBreakDown'] ?? [],
      'addonBrakeDown':
          rawPriceData['addonBrakeDown'] ??
          rawPriceData['addonBreakDown'] ??
          [],
      'promotionBrakeDown':
          rawPriceData['promotionBrakeDown'] ??
          rawPriceData['promotionBreakDown'] ??
          [],
      'dailyPriceBrakeDown':
          rawPriceData['dailyPriceBrakeDown'] ??
          rawPriceData['dailyBreakdown'] ??
          rawPriceData['dailyPriceBreakDown'] ??
          [],
      'dailyBreakdown':
          rawPriceData['dailyBreakdown'] ??
          rawPriceData['dailyPriceBrakeDown'] ??
          [],
    };

    // Safely build guests object with roomsArray
    final guestsRaw =
        widget.bookingDetails['guests'] as Map<String, dynamic>? ?? {};
    final roomsArray =
        guestsRaw['roomsArray'] as List? ??
        [
          {
            'adults': guestsRaw['adults'] ?? 1,
            'children': guestsRaw['children'] ?? 0,
            'childAges': [],
          },
        ];

    final guests = {
      'adults': guestsRaw['adults'] ?? 1,
      'children': guestsRaw['children'] ?? 0,
      'rooms': guestsRaw['rooms'] ?? 1,
      'roomsArray': roomsArray,
    };

    // Build selectedPromotions as objects (not strings)
    final rawPromotions = widget.bookingDetails['selectedPromotions'];
    final selectedPromotions = (rawPromotions is List)
        ? rawPromotions.whereType<Map>().toList()
        : [];

    // Build complete bookingDetails matching expected API structure
    final bookingDetails = {
      'startDate': widget.bookingDetails['startDate'],
      'endDate': widget.bookingDetails['endDate'],
      'propertyCode': finalPropertyCode, // Use the validated property code
      'hotelName': widget.bookingDetails['hotelName'],
      'roomTypeCode': widget.bookingDetails['roomTypeCode'],
      'numberOfRooms': widget.bookingDetails['numberOfRooms'] ?? 1,
      'finalPrice': enhancedPriceData,
      'promoCode': widget.bookingDetails['promoCode'],
      'currency':
          widget.bookingDetails['currency'] ??
          rawPriceData['currencyCode'] ??
          'USD',
      'email': widget.bookingDetails['email'] ?? '',
      'phone': widget.bookingDetails['phone'] ?? '',
      'guests': guests,
      'guestDetails': widget.bookingDetails['guestDetails'] ?? [],
      'ratePlanCode': widget.bookingDetails['ratePlanCode'] ?? '',
      'paymentMethod':
          widget.bookingDetails['paymentMethod'] ?? _selectedPaymentMethod,
      'bookingSource': widget.bookingDetails['bookingSource'] ?? 'direct',
      'selectedPromotions': selectedPromotions,
      'selectedAddons': widget.bookingDetails['selectedAddons'] ?? [],
    };

    final payload = {
      'data': {
        'bankDetails': _fetchedPaymentData,
        'bookingDetails': bookingDetails,
        'priceData': enhancedPriceData,
        'guestDetails': widget.bookingDetails['guestDetails'] ?? [],
        'paymentMethod': _selectedPaymentMethod,
        'paymentScreenshot': _paymentScreenshot != null
            ? base64Encode(await _paymentScreenshot!.readAsBytes())
            : null,
      },
    };

    print('=== COMPLETE BOOKING FINAL PAYLOAD ===');
    print('Payload being sent: ${json.encode(payload)}');
    print('======================================');

    final result = await Get.find<ApiController>().completeBooking(payload);

    if (!mounted) return;

    if (result['success'] == true) {
      final bookingData = result['data'] as Map<String, dynamic>? ?? {};
      final bookingCode = bookingData['bookingCode'] as String? ?? '';
      final propertyCode =
          bookingData['propertyCode'] as String? ??
          widget.bookingDetails['propertyCode'] as String? ??
          '';

      setState(() => _isProcessingBooking = false);

      _showBookingSuccessDialog(
        bookingCode: bookingCode,
        propertyCode: propertyCode,
      );
    } else {
      setState(() => _isProcessingBooking = false);
      showErrorDialog(context, 'Booking failed: ${result['error']}');
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _isProcessingBooking = false);
    showErrorDialog(context, 'Booking failed: $e');
  }
}

  // ── Booking Success Dialog ────────────────────────────────────────────────────
  void _showBookingSuccessDialog({
    required String bookingCode,
    required String propertyCode,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'RESERVATION CONFIRMED',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              if (bookingCode.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withOpacity(0.15)),
                  ),
                  child: Text(
                    bookingCode,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Your reservation has been successfully confirmed. Check your email for details.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.primary.withOpacity(0.5),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.offAllNamed(
                      '/bookingdetails',
                      arguments: {
                        'bookingCode': bookingCode,
                        'propertyCode': propertyCode,
                        'tab': 1,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'VIEW MY RESERVATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
