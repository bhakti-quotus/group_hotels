import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:sunswept/group/controllers/search_controller.dart' as search_ctrl;
import 'package:sunswept/ui/room_screen/addons_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../booking_page/booking_page_new.dart';
import 'package:sunswept/group/controllers/api_controller.dart';
import 'package:sunswept/group/controllers/hotel_controller.dart';
import 'dart:async';
import './loyality_program_card.dart'; // Add this import

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT DISCOUNT SESSION
// Static fields survive screen rebuilds and navigation push/pop.
// Cleared only when the user explicitly taps "Logout".
// ─────────────────────────────────────────────────────────────────────────────

class DiscountSession {
  static String? guestEmail;
  static bool discountApplied = false;
  static int discountPercentage = 0;

  static void apply({required String email, required int percentage}) {
    guestEmail = email;
    discountApplied = true;
    discountPercentage = percentage;
  }

  static void clear() {
    guestEmail = null;
    discountApplied = false;
    discountPercentage = 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ComboEntry {
  final String label;
  final List<dynamic> addons;
  final double totalAmount;
  final Map<String, dynamic> rawRatePlan;

  const _ComboEntry({
    required this.label,
    required this.addons,
    required this.totalAmount,
    required this.rawRatePlan,
  });
}

class _GroupedPlan {
  final String ratePlanCode;
  final String ratePlanName;
  final String currencyCode;
  final Map<String, dynamic>? policy;
  final Map<String, dynamic>? touristTax;
  final List<dynamic> appliedDiscounts;
  final List<_ComboEntry> combos;

  const _GroupedPlan({
    required this.ratePlanCode,
    required this.ratePlanName,
    required this.currencyCode,
    this.policy,
    this.touristTax,
    required this.appliedDiscounts,
    required this.combos,
  });
}

List<_GroupedPlan> _groupRatePlans(List roomPrice) {
  final Map<String, _GroupedPlan> map = {};
  for (final rp in roomPrice) {
    if (rp is! Map<String, dynamic>) continue;
    final code = rp['ratePlanCode'] as String? ?? '';
    final name = rp['ratePlanName'] as String? ?? 'Standard Rate';
    final currency = rp['currencyCode'] as String? ?? 'USD';
    final policy = rp['policy'] as Map<String, dynamic>?;
    final touristTax = rp['touristTax'] as Map<String, dynamic>?;
    final appliedDiscounts = rp['appliedDiscounts'] as List? ?? [];
    final total = (rp['totalAmount'] as num?)?.toDouble() ?? 0;
    final addons = rp['addons'] as List? ?? [];
    final String label = addons.isEmpty
        ? 'Room Only'
        : (addons.first is Map
              ? (addons.first['name'] ?? 'Add-on').toString()
              : 'Add-on');
    final combo = _ComboEntry(
      label: label,
      addons: addons,
      totalAmount: total,
      rawRatePlan: rp,
    );
    if (map.containsKey(code)) {
      map[code]!.combos.add(combo);
    } else {
      map[code] = _GroupedPlan(
        ratePlanCode: code,
        ratePlanName: name,
        currencyCode: currency,
        policy: policy,
        touristTax: touristTax,
        appliedDiscounts: appliedDiscounts,
        combos: [combo],
      );
    }
  }
  return map.values.toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({Key? key}) : super(key: key);

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  late List<String> images;
  int? _expandedPolicyIndex;
  final Map<int, GlobalKey> _policyKeys = {};
  OverlayEntry? _overlayEntry;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLoadingDiscount = false;
  bool _isLoadingAddons = false;
  bool _isAppBarCollapsed = false;
  final Set<String> _expandedCombos = {};

  // Convenience getters that read from the static session
  bool get _discountApplied => DiscountSession.discountApplied;
  int get _discountPercentage => DiscountSession.discountPercentage;
  String? get _guestEmail => DiscountSession.guestEmail;

  // Loyalty data from API
  Map<String, dynamic>? _loyaltyData;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 240;
      if (collapsed != _isAppBarCollapsed) {
        setState(() => _isAppBarCollapsed = collapsed);
      }
    });

    // Extract loyalty data from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractLoyaltyData();
    });
  }

  void _extractLoyaltyData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final loyaltyData = args['loyaltyData'] as Map<String, dynamic>?;
      if (loyaltyData != null) {
        setState(() {
          _loyaltyData = loyaltyData;
        });
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _pageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Utility ────────────────────────────────────────────────────────────────

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _expandedPolicyIndex = null);
  }

  /// No API call — just wipes the static session and rebuilds.
  void _handleLogout() {
    DiscountSession.clear();
    if (mounted) setState(() {});
  }

  /// Applies discount % to a base price.
  double _discounted(double base) {
    if (!_discountApplied) return base;
    return base * (1 - _discountPercentage / 100);
  }

  // ─── Share ───────────────────────────────────────────────────────────────────

  Future<void> _shareImage() async {
    if (images.isEmpty) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preparing image...'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      final response = await http.get(Uri.parse(images[_currentImageIndex]));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/shared_room_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(response.bodyBytes);
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Check out this beautiful room!');
        Future.delayed(
          const Duration(seconds: 30),
          () => file.existsSync() ? file.deleteSync() : null,
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Failed to share image',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ─── Policy overlay ──────────────────────────────────────────────────────────

  void _showPolicyOverlay(BuildContext ctx, String description, int index) {
    _removeOverlay();
    final key = _policyKeys[index];
    if (key == null) return;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: pos.dy + size.height + 8,
            right: 20,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              shadowColor: AppColor.primary.withOpacity(0.15),
              child: Container(
                width: MediaQuery.of(ctx).size.width - 120,
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.primary.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.policy_rounded,
                            size: 16,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cancellation Policy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColor.text,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _removeOverlay,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(ctx).insert(_overlayEntry!);
    setState(() => _expandedPolicyIndex = index);
  }

  // ─── UNIFIED DISCOUNT FLOW ───────────────────────────────────────────────────
  //
  // This method is called from:
  // 1. The rate plan card's "Member Rate Available" banner
  // 2. The LoyaltyProgramCard's join button
  //
  // It shows a single form to collect user details and handles both
  // registration and discount application in one flow.

  void _openDiscountRegistration({
    required String propertyId,
    required String propertyName,
  }) {
    // Already signed in — discount is already applied
    if (_discountApplied) return;

    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (_, setDlg) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.card_membership_rounded,
                          color: AppColor.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Member Rate',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.text,
                              ),
                            ),
                            Text(
                              'Sign up to unlock exclusive rates!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Fields ──
                  _buildFormField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    hint: 'Enter your name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    controller: emailCtrl,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!GetUtils.isEmail(v)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    controller: mobileCtrl,
                    label: 'Mobile Number',
                    hint: 'Enter mobile',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 10) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dlgCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoadingDiscount
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setDlg(() => _isLoadingDiscount = true);

                                  final email = emailCtrl.text.trim();
                                  final name = nameCtrl.text.trim();
                                  final mobile = mobileCtrl.text.trim();

                                  // Step 1 — check if already a member
                                  final checkResult = await _callCheckDiscount(
                                    email: email,
                                    propertyId: propertyId,
                                  );

                                  if (checkResult['eligible'] == true) {
                                    // Already a member — close dialog, apply discount
                                    if (mounted) {
                                      setState(
                                        () => _isLoadingDiscount = false,
                                      );
                                    }
                                    if (!mounted) return;
                                    Navigator.pop(dlgCtx);
                                    _applyDiscount(
                                      email: email,
                                      percentage:
                                          checkResult['percentage'] as int,
                                    );
                                    return;
                                  }

                                  // Step 2 — not a member, register
                                  final regResult = await _callRegister(
                                    email: email,
                                    propertyId: propertyId,
                                    guestName: name,
                                    mobileNumber: mobile,
                                  );

                                  if (mounted) {
                                    setState(() => _isLoadingDiscount = false);
                                  }
                                  if (!mounted) return;
                                  Navigator.pop(dlgCtx);

                                  if (regResult['eligible'] == true) {
                                    _applyDiscount(
                                      email: email,
                                      percentage:
                                          regResult['percentage'] as int,
                                    );
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  regResult['message']
                                                          as String? ??
                                                      'Something went wrong. Try again.',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.red[700],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoadingDiscount
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Get Discount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Check membership (email + propertyId only, no metadata).
  Future<Map<String, dynamic>> _callCheckDiscount({
    required String email,
    required String propertyId,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/loyalty/guest/check-discount',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'propertyId': propertyId}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final msg = (data['message'] as String? ?? '').toLowerCase();

        if (msg.contains('already registered')) {
          final pct =
              (data['data']?['discount']?['value'] as num?)?.toInt() ?? 10;
          return {'eligible': true, 'percentage': pct};
        }

        if (data['success'] == true && data['data'] != null) {
          final d = data['data'];
          if (d['isLoyaltyMember'] == true) {
            final pct = (d['discount']?['value'] as num?)?.toInt() ?? 10;
            return {'eligible': true, 'percentage': pct};
          }
        }
      }
    } catch (_) {}
    return {'eligible': false};
  }

  /// Register with full metadata.
  Future<Map<String, dynamic>> _callRegister({
    required String email,
    required String propertyId,
    required String guestName,
    required String mobileNumber,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/loyalty/guest/check-discount',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'propertyId': propertyId,
              'metadata': {
                'Guest Name': guestName,
                'Mobile Number': mobileNumber,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final msg = (data['message'] as String? ?? '').toLowerCase();

        if (msg.contains('already registered')) {
          final pct =
              (data['data']?['discount']?['value'] as num?)?.toInt() ?? 10;
          return {'eligible': true, 'percentage': pct};
        }

        if (data['success'] == true) {
          final d = data['data'];
          final pct = (d?['discount']?['value'] as num?)?.toInt() ?? 10;
          return {'eligible': true, 'percentage': pct};
        }

        return {
          'eligible': false,
          'message': data['message'] ?? 'Not eligible',
        };
      }
      return {'eligible': false, 'message': 'Server error'};
    } catch (_) {
      return {'eligible': false, 'message': 'Network error. Try again.'};
    }
  }

  /// Saves to static session, closes any open loaders, rebuilds screen silently.
  void _applyDiscount({required String email, required int percentage}) {
    DiscountSession.apply(email: email, percentage: percentage);

    // Close any GetX loading dialog that may still be open
    if (Get.isDialogOpen ?? false) Get.back();

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                '$percentage% member discount applied!',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  Future<void> _fetchAndShowAddons({
  required String propertyCode,
  required String startDate,
  required String endDate,
  required String ratePlanCode,
  required Map<String, dynamic> room,
  required Map<String, dynamic> ratePlan,
  required int adults,
  required int children,
  required int totalGuests,
  required String propertyId,
  required String hotelName,
  required double discountedPrice,
}) async {
  setState(() => _isLoadingAddons = true);
  try {
    // Debug print to verify propertyCode
    print('=== FETCH ADDONS DEBUG ===');
    print('propertyCode: $propertyCode');
    print('propertyId: $propertyId');
    print('startDate: $startDate');
    print('endDate: $endDate');
    print('ratePlanCode: $ratePlanCode');
    print('==========================');
    
    // Ensure propertyCode is not empty
    String finalPropertyCode = propertyCode;
    if (finalPropertyCode.isEmpty) {
      print('ERROR: propertyCode is empty!');
      // Try to get from hotel controller or room data
      final hotelController = Get.find<HotelController>();
      final hotel = hotelController.getSelectedHotel();
      final fallbackCode = hotel?['code'] as String? ?? 
                          room['propertyCode'] as String? ?? 
                          propertyCode;
      print('Using fallback propertyCode: $fallbackCode');
      finalPropertyCode = fallbackCode;
    }
    
    final result = await Get.find<ApiController>().getAvailableAddons(
      propertyCode: finalPropertyCode,
      startDate: startDate,
      endDate: endDate,
      ratePlanCode: ratePlanCode,
    );

    if (result['success'] == true && result['data'] != null) {
      final addonsData = result['data'] as List;
      
      // 🔥 CRITICAL FIX: Check if addons are empty or null
      if (addonsData.isEmpty) {
        print('No addons available - proceeding directly to booking');
        // Directly proceed to booking without showing addons screen
        _proceedToBooking(
          room: room,
          ratePlan: ratePlan,
          adults: adults,
          children: children,
          totalGuests: totalGuests,
          startDate: startDate,
          endDate: endDate,
          propertyId: propertyId,
          propertyCode: finalPropertyCode,
          hotelName: hotelName,
          discountedPrice: discountedPrice,
          selectedAddons: [], // Empty addons list
        );
      } else {
        print('Addons available - showing addons screen');
        // Show addons screen when addons are available
        if (context.mounted) {
          Get.to(
            () => const AddonsScreen(),
            arguments: {
              'addons': addonsData,
              'startDate': startDate,
              'endDate': endDate,
              'onAdd': (List<Map<String, dynamic>> sel) => _proceedToBooking(
                room: room,
                ratePlan: ratePlan,
                adults: adults,
                children: children,
                totalGuests: totalGuests,
                startDate: startDate,
                endDate: endDate,
                propertyId: propertyId,
                propertyCode: finalPropertyCode,
                hotelName: hotelName,
                discountedPrice: discountedPrice,
                selectedAddons: sel,
              ),
              'onSkip': () => _proceedToBooking(
                room: room,
                ratePlan: ratePlan,
                adults: adults,
                children: children,
                totalGuests: totalGuests,
                startDate: startDate,
                endDate: endDate,
                propertyId: propertyId,
                propertyCode: finalPropertyCode,
                hotelName: hotelName,
                discountedPrice: discountedPrice,
                selectedAddons: [],
              ),
            },
          );
        }
      }
    } else {
      // If API fails or returns error, proceed without addons
      print('Addons API failed or returned error - proceeding without addons');
      _proceedToBooking(
        room: room,
        ratePlan: ratePlan,
        adults: adults,
        children: children,
        totalGuests: totalGuests,
        startDate: startDate,
        endDate: endDate,
        propertyId: propertyId,
        propertyCode: finalPropertyCode,
        hotelName: hotelName,
        discountedPrice: discountedPrice,
        selectedAddons: [],
      );
    }
  } catch (e) {
    print('Error fetching addons: $e - proceeding without addons');
    // On error, proceed without addons
    _proceedToBooking(
      room: room,
      ratePlan: ratePlan,
      adults: adults,
      children: children,
      totalGuests: totalGuests,
      startDate: startDate,
      endDate: endDate,
      propertyId: propertyId,
      propertyCode: propertyCode,
      hotelName: hotelName,
      discountedPrice: discountedPrice,
      selectedAddons: [],
    );
  } finally {
    if (mounted) setState(() => _isLoadingAddons = false);
  }
}

  void _proceedToBooking({
    required Map<String, dynamic> room,
    required Map<String, dynamic> ratePlan,
    required int adults,
    required int children,
    required int totalGuests,
    required String startDate,
    required String endDate,
    required String propertyId,
    required String propertyCode,
    required String hotelName,
    required double discountedPrice,
    required List<Map<String, dynamic>> selectedAddons,
  }) {
    _removeOverlay();
    Get.to(
      () => BookingPage(
        room: room,
        ratePlan: ratePlan,
        totalGuests: totalGuests,
        adults: adults,
        children: children,
        startDate: startDate,
        endDate: endDate,
        propertyId: propertyId,
        propertyCode: propertyCode,
        hotelName: hotelName,
        discountApplied: _discountApplied,
        discountedPrice: discountedPrice.toInt(),
        guestEmail: _guestEmail,
        addons: selectedAddons,
      ),
    );
  }

  // ─── Loyalty Card Builder ────────────────────────────────────────────────────

  Widget _buildLoyaltyCard({
    required String propertyId,
    required String propertyName,
  }) {
    if (_loyaltyData == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: LoyaltyProgramCard(
        discountValue: _loyaltyData!['discountValue'] ?? 10,
        termsText:
            _loyaltyData!['termsText'] ??
            "Member-Only Rates\nEnjoy special discounted prices you won't find anywhere else.",
        benefitsTitle: _loyaltyData!['benefitsTitle'] ?? "VIP Perks",
        benefitsSubtitle:
            _loyaltyData!['benefitsSubtitle'] ??
            "✅ Exclusive discounted room rates\n✅ Early check-in & late check-out\n✅ Dining & spa discounts\n✅ Priority reservations",
        videoUrl: _loyaltyData!['videoUrl'],
        videoThumbnail: _loyaltyData!['videoThumbnail'],
        logoUrl: _loyaltyData!['logoUrl'],
        propertyName: _loyaltyData!['propertyName'] ?? propertyName,
        propertyId: propertyId,
        isJoined: _discountApplied,
        joinedDiscountPercentage: _discountPercentage,
        onJoinSuccess: (email, percentage) {
          _applyDiscount(email: email, percentage: percentage);
        },
        onLogout: () {
          _handleLogout();
        },
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      return _buildErrorScaffold('Loading.....');
    }
    final room = args['room'] as Map<String, dynamic>?;
    if (room == null)
      return _buildErrorScaffold('Room information not available');

    final totalGuests = args['totalGuests'] as int? ?? 1;
    final propertyCode = args['propertyCode'] as String? ?? '';
    final hotelName = args['hotelName'] as String? ?? '';
    final propertyId = args['propertyId'] as String? ?? '';

    final sc = Get.find<search_ctrl.AppSearchController>();
    final sp = Map<String, dynamic>.from(sc.searchPayload.value);
    final guests = sp['guests'] as Map<String, dynamic>? ?? {};
    final adults = guests['adults'] as int? ?? 1;
    final children = guests['children'] as int? ?? 0;
    final now = DateTime.now();
    final startDate =
        sp['startDate'] as String? ??
        now.add(const Duration(days: 1)).toIso8601String().split('T')[0];
    final endDate =
        sp['endDate'] as String? ??
        now.add(const Duration(days: 2)).toIso8601String().split('T')[0];

    // Use camelCase keys for all room data
    final roomName =
        room['roomName'] ?? room['room_name'] ?? room['name'] ?? '';
    final roomSize = room['roomSize'] ?? room['room_size'] ?? 0;
    final roomUnit = room['roomUnit'] ?? room['room_unit'] ?? 'sq ft';
    final roomView = room['roomView'] ?? room['room_view'] ?? '';
    final maxOccupancy = room['maxOccupancy'] ?? room['max_occupancy'] ?? 0;
    final description = room['description'] ?? '';
    final roomPrice = room['roomPrice'] as List? ?? [];

    images = [];
    final rawImages = room['images'];
    if (rawImages is List) {
      for (var img in rawImages) {
        if (img is String)
          images.add(img);
        else if (img is Map && img['url'] != null)
          images.add(img['url'].toString());
      }
    }

    final amenities = room['amenities'] as List? ?? [];
    final groupedPlans = _groupRatePlans(roomPrice);

    DateTime? checkIn, checkOut;
    try {
      checkIn = DateTime.parse(startDate);
      checkOut = DateTime.parse(endDate);
    } catch (_) {}
    final nights = (checkIn != null && checkOut != null)
        ? checkOut.difference(checkIn).inDays
        : 1;

    const months = [
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
    final checkInStr = checkIn != null
        ? '${checkIn.day} ${months[checkIn.month - 1]}'
        : startDate;
    final checkOutStr = checkOut != null
        ? '${checkOut.day} ${months[checkOut.month - 1]}'
        : endDate;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              stretch: true,
              backgroundColor: AppColor.primary,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: _buildNavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  _removeOverlay();
                  Get.back();
                },
              ),
              actions: [
                _buildNavButton(icon: Icons.share_rounded, onTap: _shareImage),
                if (_discountApplied)
                  _buildNavButton(
                    icon: Icons.logout_rounded,
                    onTap: _handleLogout,
                    color: Colors.orange,
                  ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: _buildHeroImageArea(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  height: 0,
                  decoration: BoxDecoration(
                    color: AppColor.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                color: AppColor.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Loyalty Program Card
                    _buildLoyaltyCard(
                      propertyId: propertyId,
                      propertyName: hotelName,
                    ),
                    _buildTitleBlock(
                      roomName,
                      hotelName,
                      '',
                      checkInStr,
                      checkOutStr,
                      nights,
                      adults + children,
                    ),
                    _buildQuickStats(
                      roomSize,
                      roomUnit,
                      roomView,
                      maxOccupancy,
                    ),
                    _buildStayDetailsCard(
                      checkInStr,
                      checkOutStr,
                      nights,
                      adults,
                      children,
                    ),
                    if (description.isNotEmpty)
                      _buildSection(
                        'About This Room',
                        _buildDescriptionBlock(description),
                      ),
                    if (amenities.isNotEmpty)
                      _buildSection(
                        'Amenities',
                        _buildAmenitiesGrid(amenities),
                      ),
                    _buildAppliedDiscountsBanner(roomPrice),
                    if (groupedPlans.isNotEmpty)
                      _buildSection(
                        'Rate Plans',
                        Column(
                          children: groupedPlans.asMap().entries.map((e) {
                            _policyKeys.putIfAbsent(e.key, () => GlobalKey());
                            return _buildGroupedPlanCard(
                              plan: e.value,
                              planIndex: e.key,
                              room: room,
                              adults: adults,
                              children: children,
                              totalGuests: totalGuests,
                              startDate: startDate,
                              endDate: endDate,
                              propertyCode: propertyCode,
                              hotelName: hotelName,
                              propertyId: propertyId,
                              nights: nights,
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: roomPrice.isEmpty
          ? _buildFloatingBookButton(
              onPressed: () {
                _removeOverlay();
                Get.to(
                  () => BookingPage(
                    room: room,
                    ratePlan: {},
                    totalGuests: totalGuests,
                    adults: adults,
                    children: children,
                    startDate: startDate,
                    endDate: endDate,
                    propertyId: propertyId,
                    propertyCode: propertyCode,
                    hotelName: hotelName,
                    discountApplied: false,
                    discountedPrice: 0,
                    guestEmail: null,
                    addons: [],
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────────────────

  Widget _buildHeroImageArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (images.isNotEmpty)
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (_, i) => Image.network(
              images[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColor.primary.withOpacity(0.3),
                child: Icon(
                  Icons.hotel_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          )
        else
          Container(
            color: AppColor.primary,
            child: Icon(
              Icons.hotel_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0, 0.25, 0.55, 1],
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = i == _currentImageIndex;
                  return GestureDetector(
                    onTap: () => _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: active ? 68 : 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          width: active ? 2.5 : 1.5,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          images[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (images.length > 1)
          Positioned(
            top: 80,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color ?? Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTitleBlock(
    String roomName,
    String hotelName,
    String roomType,
    String checkIn,
    String checkOut,
    int nights,
    int totalGuests,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
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
                    if (hotelName.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 1.5,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hotelName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    Text(
                      roomName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColor.text,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(width: 36, height: 2.5, color: AppColor.primary),
              const SizedBox(width: 5),
              Container(width: 10, height: 2.5, color: AppColor.secondary),
              const SizedBox(width: 5),
              Container(
                width: 5,
                height: 2.5,
                color: AppColor.secondary.withOpacity(0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    int roomSize,
    String roomUnit,
    String roomView,
    int maxOccupancy,
  ) {
    final stats = <Map<String, dynamic>>[];
    if (roomSize > 0)
      stats.add({
        'icon': Icons.straighten_rounded,
        'label': '$roomSize $roomUnit',
        'sub': 'Room Size',
      });
    if (roomView.isNotEmpty)
      stats.add({
        'icon': Icons.landscape_rounded,
        'label': _capitalize(roomView),
        'sub': 'View',
      });
    if (maxOccupancy > 0)
      stats.add({
        'icon': Icons.people_outline_rounded,
        'label': '$maxOccupancy Guests',
        'sub': 'Max Capacity',
      });
    if (stats.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final s = e.value;
          final isLast = e.key == stats.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          s['icon'] as IconData,
                          size: 18,
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColor.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s['sub'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColor.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(width: 1, height: 48, color: Colors.grey[200]),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStayDetailsCard(
    String checkIn,
    String checkOut,
    int nights,
    int adults,
    int children,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColor.primary, AppColor.primary]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkIn,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'From 14:00',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '$nights',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  nights == 1 ? 'Night' : 'Nights',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'CHECK-OUT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkOut,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.end,
                ),
                Text(
                  'Until 12:00',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(width: 36, height: 2, color: AppColor.primary),
            const SizedBox(width: 4),
            Container(width: 10, height: 2, color: AppColor.secondary),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionBlock(String description) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.7,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildAmenitiesGrid(List amenities) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: amenities.map((a) {
        final name = a is Map
            ? (a['amenityName'] ?? a['name'] ?? '')
            : a.toString();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColor.primary.withOpacity(0.14),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getAmenityIcon(name), size: 14, color: AppColor.primary),
              const SizedBox(width: 7),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColor.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppliedDiscountsBanner(List roomPrice) {
    final geoDiscounts = <String>[];
    for (final rp in roomPrice) {
      final list = rp['appliedDiscounts'] as List? ?? [];
      for (final d in list) {
        final s = '${d['promotionName'] ?? ''} (${d['discountValue']}% off)';
        if (!geoDiscounts.contains(s)) geoDiscounts.add(s);
      }
    }
    if (geoDiscounts.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.secondary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.secondary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discounts Applied',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.text,
                  ),
                ),
                const SizedBox(height: 4),
                ...geoDiscounts.map(
                  (d) => Text(
                    '• $d',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PLAN CARD ───────────────────────────────────────────────────────────────

  Widget _buildGroupedPlanCard({
    required _GroupedPlan plan,
    required int planIndex,
    required Map<String, dynamic> room,
    required int adults,
    required int children,
    required int totalGuests,
    required String startDate,
    required String endDate,
    required String propertyCode,
    required String hotelName,
    required String propertyId,
    required int nights,
  }) {
    final cancellationPolicy =
        plan.policy?['cancellationPolicy'] as Map<String, dynamic>?;
    final policyDescription =
        cancellationPolicy?['description'] as String? ?? '';
    final touristTaxAmount =
        (plan.touristTax?['calculatedTaxAmount'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _discountApplied
              ? AppColor.secondary.withOpacity(0.4)
              : Colors.grey[200]!,
          width: _discountApplied ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.ratePlanName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColor.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (_discountApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$_discountPercentage%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'TAX NOT INCLUDED · TOURISM FEE: ${plan.currencyCode} ${touristTaxAmount.toInt()} · PAY AT THE HOTEL',
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                ),
                if (policyDescription.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    key: _policyKeys[planIndex],
                    onTap: () => _expandedPolicyIndex == planIndex
                        ? _removeOverlay()
                        : _showPolicyOverlay(
                            context,
                            policyDescription,
                            planIndex,
                          ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.policy_outlined,
                          size: 13,
                          color: AppColor.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Booking conditions →',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          _expandedPolicyIndex == planIndex
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: AppColor.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Combo rows ─────────────────────────────────────
          ...plan.combos.asMap().entries.map((comboEntry) {
            final ci = comboEntry.key;
            final combo = comboEntry.value;
            final isLast = ci == plan.combos.length - 1;
            final double basePrice = combo.totalAmount;
            final double discountedPrice = _discounted(basePrice);
            final double savings = basePrice - discountedPrice;
            final double? addonPrice =
                combo.addons.isNotEmpty && combo.addons.first is Map
                ? (combo.addons.first['price'] as num?)?.toDouble()
                : null;
            final double roomOnlyPrice = addonPrice != null
                ? basePrice - addonPrice
                : basePrice;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ci > 0)
                  Divider(height: 1, color: Colors.grey[100], thickness: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  combo.addons.isEmpty ? '↳ ' : '+ ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    combo.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: combo.addons.isEmpty
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                      color: combo.addons.isEmpty
                                          ? Colors.grey[700]
                                          : AppColor.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (combo.addons.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Base price: ${plan.currencyCode} ${roomOnlyPrice.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_discountApplied && savings > 0)
                            Text(
                              '${plan.currencyCode} ${basePrice.toInt()}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                '${plan.currencyCode} ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColor.primary,
                                ),
                              ),
                              Text(
                                '${discountedPrice.toInt()}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.primary,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          if (_discountApplied && savings > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Save ${plan.currencyCode} ${savings.toInt()}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.secondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // ADD button
                      GestureDetector(
                        onTap: () async {
                          _removeOverlay();
                          await _fetchAndShowAddons(
                            propertyCode: propertyCode,
                            startDate: startDate,
                            endDate: endDate,
                            ratePlanCode: plan.ratePlanCode,
                            room: room,
                            ratePlan: combo.rawRatePlan,
                            adults: adults,
                            children: children,
                            totalGuests: totalGuests,
                            propertyId: propertyId,
                            hotelName: hotelName,
                            discountedPrice: discountedPrice,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.secondary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'ADD',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLast)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: Text(
                      'Direct payment at hotel: TOURISM FEE — ${plan.currencyCode} ${touristTaxAmount.toInt()}',
                      style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                    ),
                  ),
              ],
            );
          }).toList(),

          // ── Geo-discount chips ─────────────────────────────
          if (plan.appliedDiscounts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: plan.appliedDiscounts
                    .map(
                      (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
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
                              Icons.sell_rounded,
                              size: 11,
                              color: AppColor.secondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${d['promotionName'] ?? ''} (${d['discountValue']}% off)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // ── BOTTOM BANNER ──────────────────────────────────
          // Not signed in → "Member Rate Available" CTA (full banner)
          if (!_discountApplied)
            GestureDetector(
              onTap: () => _openDiscountRegistration(
                propertyId: propertyId,
                propertyName: hotelName,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColor.secondary.withOpacity(0.06),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColor.secondary.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.card_membership_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member Rate Available',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColor.text,
                            ),
                          ),
                          Text(
                            'Sign up once — discount on all plans',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColor.secondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Floating button ─────────────────────────────────────────────────────────

  Widget _buildFloatingBookButton({required VoidCallback onPressed}) {
    return Container(
      width: MediaQuery.of(context).size.width - 48,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.secondary, AppColor.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Reserve Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ─── Form field ───────────────────────────────────────────────────────────────

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColor.primary, fontSize: 13),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: AppColor.secondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }

  // ─── Error scaffold ───────────────────────────────────────────────────────────

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hotel_rounded,
                  size: 48,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  IconData _getAmenityIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('wifi') || n.contains('internet')) return Icons.wifi_rounded;
    if (n.contains('tv') || n.contains('television')) return Icons.tv_rounded;
    if (n.contains('ac') || n.contains('air')) return Icons.ac_unit_rounded;
    if (n.contains('parking')) return Icons.local_parking_rounded;
    if (n.contains('pool')) return Icons.pool_rounded;
    if (n.contains('gym') || n.contains('fitness'))
      return Icons.fitness_center_rounded;
    if (n.contains('breakfast') || n.contains('food'))
      return Icons.restaurant_rounded;
    if (n.contains('bath') || n.contains('shower'))
      return Icons.bathtub_rounded;
    if (n.contains('kitchen')) return Icons.kitchen_rounded;
    if (n.contains('pet')) return Icons.pets_rounded;
    if (n.contains('balcony') || n.contains('terrace'))
      return Icons.balcony_rounded;
    if (n.contains('safe') || n.contains('lock')) return Icons.lock_rounded;
    if (n.contains('coffee') || n.contains('tea')) return Icons.coffee_rounded;
    if (n.contains('desk') || n.contains('work')) return Icons.desk_rounded;
    if (n.contains('phone') || n.contains('telephone'))
      return Icons.phone_rounded;
    if (n.contains('curtain') || n.contains('blackout'))
      return Icons.blinds_rounded;
    if (n.contains('slipper') || n.contains('bathrobe'))
      return Icons.checkroom_rounded;
    if (n.contains('alarm') || n.contains('clock')) return Icons.alarm_rounded;
    if (n.contains('iron')) return Icons.iron_rounded;
    if (n.contains('sound')) return Icons.volume_off_rounded;
    if (n.contains('seating')) return Icons.chair_rounded;
    if (n.contains('toiletries')) return Icons.wash_rounded;
    return Icons.check_circle_outline_rounded;
  }
}
