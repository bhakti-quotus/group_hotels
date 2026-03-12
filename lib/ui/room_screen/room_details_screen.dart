import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/search_controller.dart' as search_ctrl;
import 'package:group/ui/dialog/dialog.dart';
import 'package:group/ui/room_screen/addons_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../booking_page/booking_page_new.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'dart:async';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL — groups raw room_price list into plan + combos
// ─────────────────────────────────────────────────────────────────────────────

class _ComboEntry {
  final String label;
  final List<dynamic> addons;
  final double totalAmount;
  final Map<String, dynamic> rawRatePlan; // original map, passed to booking

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

    // Build combo label: if no addons → "Room Only", else addon name
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

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Discount state
  String? _globalGuestEmail;
  bool _globalDiscountApplied = false;
  double _globalDiscountedPrice = 0;
  int _globalDiscountPercentage = 0;
  bool _isLoadingDiscount = false;
  String? _globalCurrency;
  double _globalOriginalPrice = 0;
  String? _discountSourceRatePlan;

  // Add-ons
  bool _isLoadingAddons = false;
  List<dynamic> _availableAddons = [];
  String? _selectedRatePlanCode;

  // AppBar collapse
  bool _isAppBarCollapsed = false;
  final Set<String> _expandedCombos = {};

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
  }

  @override
  void dispose() {
    _removeOverlay();
    _pageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Utility ──────────────────────────────────────────────

  Future<void> _safeCloseDialog() async {
    if (Get.isDialogOpen ?? false) Get.back();
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _expandedPolicyIndex = null);
  }

  void _clearAllDiscounts() {
    setState(() {
      _globalGuestEmail = null;
      _globalDiscountApplied = false;
      _globalDiscountedPrice = 0;
      _globalDiscountPercentage = 0;
      _globalCurrency = null;
      _globalOriginalPrice = 0;
      _discountSourceRatePlan = null;
    });
    Get.snackbar(
      'Discounts Cleared',
      'All applied discounts have been removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> _shareImage() async {
    if (images.isEmpty) return;
    try {
      showSuccessDialog(context, 'Preparing image...');
      final imageUrl = images[_currentImageIndex];
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/shared_room_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(response.bodyBytes);
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Check out this beautiful room!');
        Future.delayed(const Duration(seconds: 30), () {
          if (file.existsSync()) file.deleteSync();
        });
      }
    } catch (_) {
      showErrorDialog(context, 'Failed to share image');
    }
  }

  void _showPolicyOverlay(BuildContext context, String description, int index) {
    _removeOverlay();
    final policyKey = _policyKeys[index];
    if (policyKey == null) return;
    final RenderBox? renderBox =
        policyKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
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
            top: position.dy + size.height + 8,
            right: 20,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              shadowColor: AppColor.primary.withOpacity(0.15),
              child: Container(
                width: MediaQuery.of(context).size.width - 120,
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
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _expandedPolicyIndex = index);
  }

  // ── Navigation ────────────────────────────────────────────

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
    setState(() {
      _isLoadingAddons = true;
      _selectedRatePlanCode = ratePlanCode;
    });

    try {
      final apiController = Get.find<ApiController>();
      final result = await apiController.getAvailableAddons(
        propertyCode: propertyCode,
        startDate: startDate,
        endDate: endDate,
        ratePlanCode: ratePlanCode,
      );

      if (Get.isDialogOpen ?? false) Get.back();
      await Future.delayed(const Duration(milliseconds: 300));

      if (result['success'] == true && result['data'] != null) {
        final addonsData = result['data'] as List;
        if (addonsData.isEmpty) {
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
        } else {
          if (context.mounted) {
            Get.to(
              () => const AddonsScreen(),
              arguments: {
                'addons': addonsData,
                'onAdd': (List<Map<String, dynamic>> selectedAddons) =>
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
                      selectedAddons: selectedAddons,
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
                  propertyCode: propertyCode,
                  hotelName: hotelName,
                  discountedPrice: discountedPrice,
                  selectedAddons: [],
                ),
              },
            );
          }
        }
      } else {
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
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
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
        discountApplied: _globalDiscountApplied,
        discountedPrice: discountedPrice.toInt(),
        guestEmail: _globalGuestEmail,
        addons: selectedAddons,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

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

    final searchController = Get.find<search_ctrl.AppSearchController>();
    final searchPayload = Map<String, dynamic>.from(
      searchController.searchPayload.value,
    );
    final guests = searchPayload['guests'] as Map<String, dynamic>? ?? {};
    final adults = guests['adults'] as int? ?? 1;
    final children = guests['children'] as int? ?? 0;
    final now = DateTime.now();
    final startDate =
        searchPayload['startDate'] as String? ??
        now.add(const Duration(days: 1)).toIso8601String().split('T')[0];
    final endDate =
        searchPayload['endDate'] as String? ??
        now.add(const Duration(days: 2)).toIso8601String().split('T')[0];

    // Parse room data
    final roomName = room['room_name'] ?? room['name'] ?? '';
    final roomType = room['room_type'] ?? '';
    final roomSize = room['room_size'] ?? 0;
    final roomUnit = room['room_unit'] ?? 'sq ft';
    final roomView = room['room_view'] ?? '';
    final maxOccupancy = room['max_occupancy'] ?? room['maxOccupancy'] ?? 0;
    final description = room['description'] ?? '';
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
    final roomPrice = room['room_price'] as List? ?? [];

    // ── GROUP rate plans ──
    final groupedPlans = _groupRatePlans(roomPrice);

    // Parse dates
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
            // ── Hero SliverAppBar ──────────────────────────
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
                if (_globalDiscountApplied)
                  _buildNavButton(
                    icon: Icons.discount_rounded,
                    onTap: _clearAllDiscounts,
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

            // ── Content ───────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppColor.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleBlock(
                      roomName,
                      hotelName,
                      roomType,
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

                    // ── Grouped Rate Plans ──
                    if (groupedPlans.isNotEmpty)
                      _buildSection(
                        'Rate Plans',
                        Column(
                          children: groupedPlans.asMap().entries.map((entry) {
                            _policyKeys.putIfAbsent(
                              entry.key,
                              () => GlobalKey(),
                            );
                            return _buildGroupedPlanCard(
                              plan: entry.value,
                              planIndex: entry.key,
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

                    const SizedBox(height: 120),
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

  // ── Hero Image Area ───────────────────────────────────────

  Widget _buildHeroImageArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (images.isNotEmpty)
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (_, index) => Image.network(
              images[index],
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
                itemBuilder: (_, index) {
                  final active = index == _currentImageIndex;
                  return GestureDetector(
                    onTap: () => _pageController.animateToPage(
                      index,
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
                          images[index],
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

  // ── Nav button ────────────────────────────────────────────

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

  // ── Title Block ───────────────────────────────────────────

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

  // ── Quick Stats Strip ─────────────────────────────────────

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
        children: stats.asMap().entries.map((entry) {
          final stat = entry.value;
          final isLast = entry.key == stats.length - 1;
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
                          stat['icon'] as IconData,
                          size: 18,
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColor.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat['sub'] as String,
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

  // ── Stay Details Card ─────────────────────────────────────

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
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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

  // ── Section Wrapper ───────────────────────────────────────

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

  // ── Description ───────────────────────────────────────────

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

  // ── Amenities ─────────────────────────────────────────────

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

  // ── Applied Discounts Banner ──────────────────────────────

  Widget _buildAppliedDiscountsBanner(List roomPrice) {
    final geoDiscounts = <String>[];
    for (final rp in roomPrice) {
      final appliedDiscounts = rp['appliedDiscounts'] as List? ?? [];
      for (final d in appliedDiscounts) {
        final name = d['promotionName'] ?? '';
        final val = d['discountValue'] ?? 0;
        if (!geoDiscounts.contains('$name ($val% off)')) {
          geoDiscounts.add('$name ($val% off)');
        }
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

  // ── GROUPED PLAN CARD ─────────────────────────────────────
  // One card per unique ratePlanCode; combos (Room Only / addons) listed inside.

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

    // Discount helper
    double _discounted(double base) {
      if (!_globalDiscountApplied) return base;
      return base * (1 - _globalDiscountPercentage / 100);
    }

    void _showDiscountForm(double basePrice) {
      final nameCtrl = TextEditingController();
      final emailCtrl = TextEditingController();
      final mobileCtrl = TextEditingController();
      final formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (dialogCtx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Get Exclusive Discount'),
                  const SizedBox(height: 14),
                  Text(
                    'Sign up to unlock exclusive rates on all plans!',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 22),
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
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
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => _isLoadingDiscount = true);
                            try {
                              final response = await http
                                  .post(
                                    Uri.parse(
                                      'https://bookings.revchilltech.com/api/v1/loyalty/guest/check-discount',
                                    ),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode({
                                      'email': emailCtrl.text.trim(),
                                      'propertyId': propertyId,
                                    }),
                                  )
                                  .timeout(const Duration(seconds: 10));

                              Navigator.pop(dialogCtx);

                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                if (data['success'] == true &&
                                    data['data'] != null) {
                                  final d = data['data'];
                                  if (d['isLoyaltyMember'] == true) {
                                    final discount =
                                        d['discount']?['value'] ?? 0;
                                    setState(() {
                                      _globalGuestEmail = emailCtrl.text.trim();
                                      _globalDiscountApplied = true;
                                      _globalDiscountPercentage = discount;
                                      _globalCurrency = plan.currencyCode;
                                      _globalOriginalPrice = basePrice;
                                      _globalDiscountedPrice =
                                          basePrice * (1 - discount / 100);
                                      _discountSourceRatePlan =
                                          plan.ratePlanCode;
                                      _isLoadingDiscount = false;
                                    });
                                    if (context.mounted) {
                                      showSuccessDialog(
                                        context,
                                        '🎉 $discount% discount applied!',
                                      );
                                    }
                                  } else {
                                    setState(() => _isLoadingDiscount = false);
                                    if (context.mounted) {
                                      showErrorDialog(
                                        context,
                                        'Not eligible for discount.',
                                      );
                                    }
                                  }
                                }
                              }
                            } catch (_) {
                              Navigator.pop(dialogCtx);
                              setState(() => _isLoadingDiscount = false);
                              if (context.mounted) {
                                showErrorDialog(
                                  context,
                                  'Network error. Try again.',
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
                                  'Sign Up',
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
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _globalDiscountApplied
              ? AppColor.secondary.withOpacity(0.4)
              : Colors.grey[200]!,
          width: _globalDiscountApplied ? 1.5 : 1,
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
          // ── Plan header row ──────────────────────────────
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
                    if (_globalDiscountApplied)
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
                          '-$_globalDiscountPercentage%',
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
                // Tax line
                Text(
                  'TAX NOT INCLUDED · TOURISM FEE: ${plan.currencyCode} ${touristTaxAmount.toInt()} · PAY AT THE HOTEL',
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                ),
                // Policy link
                if (policyDescription.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    key: _policyKeys[planIndex],
                    onTap: () {
                      if (_expandedPolicyIndex == planIndex) {
                        _removeOverlay();
                      } else {
                        _showPolicyOverlay(
                          context,
                          policyDescription,
                          planIndex,
                        );
                      }
                    },
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

          // ── Combo rows ───────────────────────────────────
          // ── Combo rows ───────────────────────────────────
          ...plan.combos.asMap().entries.map((comboEntry) {
            final ci = comboEntry.key;
            final combo = comboEntry.value;
            final isLast = ci == plan.combos.length - 1;
            final comboKey = '${plan.ratePlanCode}_$ci';
            final isExpanded = _expandedCombos.contains(comboKey);

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

                // ── Tappable header row ──
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedCombos.remove(comboKey);
                      } else {
                        _expandedCombos.add(comboKey);
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Row(
                      children: [
                        // Expand/collapse icon
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Label
                        Expanded(
                          child: Text(
                            combo.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.text,
                            ),
                          ),
                        ),

                        // Price (compact)
                        if (_globalDiscountApplied && savings > 0)
                          Text(
                            '${plan.currencyCode} ${basePrice.toInt()}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '${plan.currencyCode} ${discountedPrice.toInt()}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Inline expanded detail ──
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BASE PRICE card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BASE PRICE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${plan.currencyCode} ${roomOnlyPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.text,
                                    ),
                                  ),
                                  const SizedBox(width: 2),

                                  Text(
                                    '/per night',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        // Only show INCLUDED ADDONS if there are addons
                        if (combo.addons.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColor.secondary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColor.secondary.withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INCLUDED ADDONS',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.secondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...combo.addons.map((addon) {
                                  final addonName = addon is Map
                                      ? (addon['name'] ?? 'Add-on').toString()
                                      : addon.toString();
                                  final addonAmt = addon is Map
                                      ? (addon['price'] as num?)?.toDouble() ??
                                            0
                                      : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            addonName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColor.text,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          ' +${plan.currencyCode} ${addonAmt.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ADD button row (always visible below expanded or collapsed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_globalDiscountApplied && savings > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Save ${plan.currencyCode} ${savings.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColor.secondary,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () async {
                          _removeOverlay();
                          Get.dialog(
                            const Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );
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
                            horizontal: 20,
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
          // ── Applied geo-discounts chips ──────────────────
          if (plan.appliedDiscounts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: plan.appliedDiscounts.map((d) {
                  return Container(
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
                  );
                }).toList(),
              ),
            ),
          ],

          // ── Member-rate CTA ──────────────────────────────
          if (!_globalDiscountApplied)
            GestureDetector(
              onTap: () => _showDiscountForm(
                plan.combos.isNotEmpty ? plan.combos.first.totalAmount : 0,
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

  // ── Floating Book Button ──────────────────────────────────

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

  // ── Form field ────────────────────────────────────────────

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

  // ── Error scaffold ────────────────────────────────────────

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

  // ── Helpers ───────────────────────────────────────────────

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
