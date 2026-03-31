import 'dart:async';
import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/search_controller.dart' as search_ctrl;
import 'package:cached_network_image/cached_network_image.dart';

// ─────────────────────────────────────────────
//  Main Widget
// ─────────────────────────────────────────────
class RoomsListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;
  final int totalGuests;
  final String propertyCode;
  final String hotelName;
  final Map<String, dynamic> roomKeys;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Color primaryColor;
  final String propertyId;
  
  // Add these new parameters for loyalty data
  final Map<String, dynamic>? propertyDetails;
  final Map<String, dynamic>? propertyVideos;
  final Map<String, dynamic>? loyaltyConfig;

  const RoomsListWidget({
    Key? key,
    required this.rooms,
    this.totalGuests = 1,
    this.propertyCode = '',
    this.hotelName = '',
    required this.roomKeys,
    this.errorMessage,
    this.isLoading = false,
    this.onRefresh,
    required this.primaryColor,
    this.propertyId = '',
    
    // Add these
    this.propertyDetails,
    this.propertyVideos,
    this.loyaltyConfig,
  }) : super(key: key);

  @override
  State<RoomsListWidget> createState() => _RoomsListWidgetState();
}

class _RoomsListWidgetState extends State<RoomsListWidget>
    with SingleTickerProviderStateMixin {
  bool _showSkeleton = false;
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    if (widget.isLoading) {
      _showSkeleton = true;
    } else {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RoomsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Loading just started → show skeleton
    if (widget.isLoading && !oldWidget.isLoading) {
      setState(() => _showSkeleton = true);
      _fadeController.reset();
      _timer?.cancel();
      return;
    }

    // Loading just finished → hide skeleton immediately, fade in content
    if (!widget.isLoading && oldWidget.isLoading) {
      _timer?.cancel();
      setState(() => _showSkeleton = false);
      _fadeController.forward();
      return;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || _showSkeleton) return _buildSkeletonUI();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: AppColor.background,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 12),
            const SizedBox(height: 18),

            if (widget.errorMessage != null)
              _buildErrorState()
            else if (widget.rooms.isEmpty)
              _buildEmptyState()
            else
              Builder(
                builder: (context) {
                  final validRooms = widget.rooms.where((room) {
                    final hasValidRate = room['hasValidRate'] == true;
                    final roomPrice = room['roomPrice'] as List? ?? [];
                    return hasValidRate && roomPrice.isNotEmpty;
                  }).toList();

                  if (validRooms.isEmpty) return _buildEmptyState();

                  return Column(
                    children: validRooms
                        .asMap()
                        .entries
                        .map(
                          (entry) => _RoyalRoomCard(
                            room: entry.value,
                            index: entry.key,
                            totalGuests: widget.totalGuests,
                            propertyCode: widget.propertyCode,
                            hotelName: widget.hotelName,
                            propertyId: widget.propertyId,
                            // Pass loyalty data to room card
                            propertyDetails: widget.propertyDetails,
                            propertyVideos: widget.propertyVideos,
                            loyaltyConfig: widget.loyaltyConfig,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 1.5, color: AppColor.primary),
            const SizedBox(width: 10),
            Text(
              'CURATED SELECTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Choose Your\nSanctuary',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
            color: AppColor.text,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(width: 40, height: 2.5, color: AppColor.primary),
            const SizedBox(width: 6),
            Container(width: 12, height: 2.5, color: AppColor.secondary),
            const SizedBox(width: 6),
            Container(
              width: 5,
              height: 2.5,
              color: AppColor.secondary.withOpacity(0.35),
            ),
          ],
        ),
      ],
    );
  }

  // ── Error State ───────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColor.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: AppColor.textLight,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 24),
              _OutlinedPrimaryButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onTap: widget.onRefresh!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.hotel_rounded,
                size: 36,
                color: AppColor.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Rooms Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColor.text,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please refine your search or check back later',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton UI ───────────────────────────────────────────
  Widget _buildSkeletonUI() {
    return Container(
      color: AppColor.background,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Shimmer(
            child: Container(
              width: 180,
              height: 26,
              decoration: _skeletonBox(),
            ),
          ),
          const SizedBox(height: 10),
          _Shimmer(
            child: Container(
              width: 120,
              height: 14,
              decoration: _skeletonBox(),
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(2, (_) => _buildSkeletonCard()),
        ],
      ),
    );
  }

  BoxDecoration _skeletonBox({double radius = 6}) => BoxDecoration(
    color: AppColor.cardBorder.withOpacity(0.4),
    borderRadius: BorderRadius.circular(radius),
  );

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Shimmer(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColor.cardBorder.withOpacity(0.25),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(
                  child: Container(
                    width: 180,
                    height: 22,
                    decoration: _skeletonBox(),
                  ),
                ),
                const SizedBox(height: 10),
                _Shimmer(
                  child: Container(
                    width: 100,
                    height: 14,
                    decoration: _skeletonBox(),
                  ),
                ),
                const SizedBox(height: 16),
                _Shimmer(
                  child: Container(
                    width: double.infinity,
                    height: 12,
                    decoration: _skeletonBox(),
                  ),
                ),
                const SizedBox(height: 6),
                _Shimmer(
                  child: Container(
                    width: 220,
                    height: 12,
                    decoration: _skeletonBox(),
                  ),
                ),
                const SizedBox(height: 20),
                _Shimmer(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: _skeletonBox(radius: 12),
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

// ─────────────────────────────────────────────
//  Room Card
// ─────────────────────────────────────────────
class _RoyalRoomCard extends StatefulWidget {
  final Map<String, dynamic> room;
  final int index;
  final int totalGuests;
  final String propertyCode;
  final String hotelName;
  final String propertyId;
  
  // Add these parameters
  final Map<String, dynamic>? propertyDetails;
  final Map<String, dynamic>? propertyVideos;
  final Map<String, dynamic>? loyaltyConfig;

  const _RoyalRoomCard({
    required this.room,
    required this.index,
    required this.totalGuests,
    required this.propertyCode,
    required this.hotelName,
    required this.propertyId,
    
    // Add these
    this.propertyDetails,
    this.propertyVideos,
    this.loyaltyConfig,
  });

  @override
  State<_RoyalRoomCard> createState() => _RoyalRoomCardState();
}

class _RoyalRoomCardState extends State<_RoyalRoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.982,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    //debugPrint('roomdata from api ${room}');
    print('Room JSON: ${widget.room}');
    final images = room['images'] as List? ?? [];
final roomName = room['roomName'] ?? room['room_name'] ?? room['name'] ?? 'Luxury Suite';
final roomType = room['roomType'] ?? room['room_type'] ?? '';
final roomSize = room['roomSize'] ?? room['room_size'] ?? 0;
final roomUnit = room['roomUnit'] ?? room['room_unit'] ?? 'sq ft';
final roomView = room['roomView'] ?? room['room_view'] ?? '';
final maxOccupancy = room['maxOccupancy'] ?? room['max_occupancy'] ?? 0;
final description = room['description'] ?? '';
final amenities = room['amenities'] as List? ?? [];

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: () => _pressController.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.cardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Image carousel ──
                _RoyalImageCarousel(images: images, roomType: roomType),

                // ── Body ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room name
                      Text(
                        roomName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColor.text,
                          height: 1.2,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Feature chips
                      Wrap(
                        spacing: 18,
                        runSpacing: 10,
                        children: [
                          if (roomSize > 0)
                            _MetaChip(
                              icon: Icons.straighten_rounded,
                              label: '$roomSize $roomUnit',
                            ),
                          if (roomView.isNotEmpty)
                            _MetaChip(
                              icon: Icons.landscape_rounded,
                              label: roomView,
                            ),
                          if (maxOccupancy > 0)
                            _MetaChip(
                              icon: Icons.people_outline_rounded,
                              label: 'Up to $maxOccupancy guests',
                            ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.textLight,
                            height: 1.65,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // ── Gradient divider ──
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColor.primary.withOpacity(0.3),
                        AppColor.secondary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.25, 0.75, 1],
                    ),
                  ),
                ),

                // ── View Details CTA ──
                _ViewDetailsButton(
                  room: room,
                  totalGuests: widget.totalGuests,
                  propertyCode: widget.propertyCode,
                  hotelName: widget.hotelName,
                  propertyId: widget.propertyId,
                  // Pass loyalty data to button
                  propertyDetails: widget.propertyDetails,
                  propertyVideos: widget.propertyVideos,
                  loyaltyConfig: widget.loyaltyConfig,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Image Carousel (Optimized)
// ─────────────────────────────────────────────
class _RoyalImageCarousel extends StatefulWidget {
  final List images;
  final String roomType;

  const _RoyalImageCarousel({required this.images, required this.roomType});

  @override
  State<_RoyalImageCarousel> createState() => _RoyalImageCarouselState();
}

class _RoyalImageCarouselState extends State<_RoyalImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  final Map<int, bool> _imageLoaded = {};

  List<String> get _resolvedUrls {
    final urls = <String>[];
    for (var item in widget.images) {
      if (item is String) {
        urls.add(item);
      } else if (item is Map && item['url'] != null) {
        urls.add(item['url'].toString());
      }
    }
    return urls.isNotEmpty
        ? urls
        : ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=1200'];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_resolvedUrls.length > 1) _startAutoScroll();

    // Preload images
    _preloadImages();
  }

  void _preloadImages() async {
    for (int i = 0; i < _resolvedUrls.length; i++) {
      // Prefetch images to cache
      await precacheImage(
        CachedNetworkImageProvider(_resolvedUrls[i]),
        context,
      );
      setState(() {
        _imageLoaded[i] = true;
      });
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients && mounted) {
        _pageController.animateToPage(
          (_currentPage + 1) % _resolvedUrls.length,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _resolvedUrls;

    return SizedBox(
      height: 230,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView with Cached Images
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (i) {
              if (mounted) setState(() => _currentPage = i);
            },
            itemBuilder: (_, index) => CachedNetworkImage(
              imageUrl: urls[index],
              fit: BoxFit.cover,
              memCacheWidth: 600, // Optimize memory usage
              memCacheHeight: 400,
              placeholder: (context, url) => Container(
                color: AppColor.cardBorder.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColor.cardBorder.withOpacity(0.15),
                child: Icon(
                  Icons.image_rounded,
                  color: AppColor.cardBorder,
                  size: 48,
                ),
              ),
            ),
          ),

          // Bottom vignette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                ),
              ),
            ),
          ),

          // Room type badge
          if (widget.roomType.isNotEmpty)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.roomType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

          // Image counter
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPage + 1} / ${urls.length}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Dot indicators
          if (urls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColor.primary
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Meta Chip
// ─────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColor.primary),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColor.textLight,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  View Details Button
// ─────────────────────────────────────────────
class _ViewDetailsButton extends StatefulWidget {
  final Map<String, dynamic> room;
  final int totalGuests;
  final String propertyCode;
  final String hotelName;
  final String propertyId;
  
  // Add these parameters
  final Map<String, dynamic>? propertyDetails;
  final Map<String, dynamic>? propertyVideos;
  final Map<String, dynamic>? loyaltyConfig;

  const _ViewDetailsButton({
    required this.room,
    required this.totalGuests,
    required this.propertyCode,
    required this.hotelName,
    required this.propertyId,
    
    // Add these
    this.propertyDetails,
    this.propertyVideos,
    this.loyaltyConfig,
  });

  @override
  State<_ViewDetailsButton> createState() => _ViewDetailsButtonState();
}

class _ViewDetailsButtonState extends State<_ViewDetailsButton> {
  bool _pressed = false;

  void _navigate() {
  try {
    final searchController = Get.find<search_ctrl.AppSearchController>();
    final searchPayload = Map<String, dynamic>.from(
      searchController.searchPayload.value,
    );
    final shortPropertyCode =
        searchPayload['PropertyCode'] as String? ??
        searchPayload['propertyCode'] as String? ??
        widget.propertyCode;

    // Extract loyalty data with proper null safety
    final loyaltyConfig = widget.loyaltyConfig;
    final propertyVideos = widget.propertyVideos;
    final propertyDetails = widget.propertyDetails;
    
    final basicLoyaltyProgram = loyaltyConfig?['BasicLoyaltyProgram'];
    final loyaltyConditions = loyaltyConfig?['loyaltyConditions'] as List?;
    final loyaltySpecialConditions = loyaltyConfig?['loyaltySpecialConditions'] as List?;
    
    // Safely get terms text
    String? termsText;
    if (loyaltyConditions != null && loyaltyConditions.isNotEmpty) {
      final firstCondition = loyaltyConditions[0];
      if (firstCondition is Map) {
        termsText = firstCondition['text'] as String?;
      }
    }
    
    // Safely get benefits title and subtitle
    String? benefitsTitle;
    String? benefitsSubtitle;
    if (loyaltySpecialConditions != null && loyaltySpecialConditions.isNotEmpty) {
      final firstSpecial = loyaltySpecialConditions[0];
      if (firstSpecial is Map) {
        benefitsTitle = firstSpecial['title'] as String?;
        benefitsSubtitle = firstSpecial['subTitle'] as String?;
      }
    }
    
    // Safely get logo URL
    String? logoUrl;
    if (basicLoyaltyProgram != null) {
      final logoList = basicLoyaltyProgram['logo'] as List?;
      if (logoList != null && logoList.isNotEmpty) {
        logoUrl = logoList[0] as String?;
      }
    }
    
    // Create loyalty data object with proper fallbacks
    final loyaltyData = {
      'discountValue': loyaltyConfig?['discountValue'] ?? 10,
      'termsText': termsText ?? "Member-Only Rates\nEnjoy special discounted prices.",
      'benefitsTitle': benefitsTitle ?? "VIP Perks",
      'benefitsSubtitle': benefitsSubtitle ?? "Exclusive benefits for members.",
      'videoUrl': propertyVideos?['url'],
      'videoThumbnail': propertyVideos?['thumbnail'],
      'logoUrl': logoUrl,
      'propertyName': propertyDetails?['propertyName'] ?? widget.hotelName,
    };
    
   // print('Sending loyalty data: $loyaltyData'); // Debug print

        Get.toNamed(
      '/room-details',
      arguments: {
        'room': {
          ...widget.room,
          'invTypeCode': widget.room['roomType'] ?? widget.room['room_type'] ?? widget.room['invTypeCode'] ?? '',
        },
        'totalGuests': widget.totalGuests,
        'propertyCode': shortPropertyCode,
        'hotelName': widget.hotelName,
        'propertyId': widget.propertyId,
        'propertyDetails': propertyDetails,
        'loyaltyData': loyaltyData,
      },
    );
  } catch (e) {
   // print("Error navigating to room details: $e");
    
    // Fallback navigation with default loyalty data
    Get.toNamed(
      '/room-details',
      arguments: {
        'room': widget.room,
        'totalGuests': widget.totalGuests,
        'propertyCode': widget.propertyCode,
        'hotelName': widget.hotelName,
        'propertyId': widget.propertyId,
        'propertyDetails': widget.propertyDetails,
        'loyaltyData': {
          'discountValue': 10,
          'termsText': "Member-Only Rates\nEnjoy special discounted prices.",
          'benefitsTitle': "VIP Perks",
          'benefitsSubtitle': "Exclusive benefits for members.",
          'videoUrl': null,
          'videoThumbnail': null,
          'logoUrl': null,
          'propertyName': widget.hotelName,
        },
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _navigate();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.all(10),
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _pressed
                ? [
                    AppColor.primary.withOpacity(0.8),
                    AppColor.primary.withOpacity(0.8),
                  ]
                : [AppColor.primary, AppColor.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.28),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'View Details',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Outlined Primary Button (error / retry)
// ─────────────────────────────────────────────
class _OutlinedPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlinedPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.primary,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shimmer
// ─────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppColor.cardBorder.withOpacity(0.3),
            AppColor.cardBorder.withOpacity(0.7),
            AppColor.cardBorder.withOpacity(0.3),
          ],
          stops: [
            (_anim.value - 0.5).clamp(0.0, 1.0),
            _anim.value.clamp(0.0, 1.0),
            (_anim.value + 0.5).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}