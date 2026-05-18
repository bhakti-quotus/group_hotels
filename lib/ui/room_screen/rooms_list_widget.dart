import 'dart:async';
import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/search_controller.dart'
    as search_ctrl;
import 'package:royalcontinent/group/controllers/hotel_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final Map<String, dynamic>? propertyDetails;
  final Map<String, dynamic>? propertyVideos;
  final Map<String, dynamic>? loyaltyConfig;

  /// Called after user picks an alternate hotel in the empty state.
  /// Parent screen should re-call its fetch/API method here.
  final VoidCallback? onHotelSelected;

  const RoomsListWidget({
    super.key,
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
    this.propertyDetails,
    this.propertyVideos,
    this.loyaltyConfig,
    this.onHotelSelected,
  });

  @override
  State<RoomsListWidget> createState() =>
      _RoomsListWidgetState();
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
    if (widget.isLoading && !oldWidget.isLoading) {
      setState(() => _showSkeleton = true);
      _fadeController.reset();
      _timer?.cancel();
      return;
    }
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
    if (widget.isLoading || _showSkeleton)
      return _buildSkeletonUI();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: AppColor.background,
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 14),
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
                  final validRooms =
                      widget.rooms.where((room) {
                    final hasValidRate =
                        room['hasValidRate'] == true;
                    final roomPrice =
                        room['roomPrice'] as List? ?? [];
                    return hasValidRate &&
                        roomPrice.isNotEmpty;
                  }).toList();

                  if (validRooms.isEmpty)
                    return _buildEmptyState();

                  return Column(
                    children: validRooms
                        .asMap()
                        .entries
                        .map(
                          (entry) => _RoyalRoomCard(
                            room: entry.value,
                            index: entry.key,
                            totalGuests: widget.totalGuests,
                            propertyCode:
                                widget.propertyCode,
                            hotelName: widget.hotelName,
                            propertyId: widget.propertyId,
                            propertyDetails:
                                widget.propertyDetails,
                            propertyVideos:
                                widget.propertyVideos,
                            loyaltyConfig:
                                widget.loyaltyConfig,
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

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 24,
                height: 1.5,
                color: AppColor.primary),
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
            Container(
                width: 40,
                height: 2.5,
                color: AppColor.primary),
            const SizedBox(width: 6),
            Container(
                width: 12,
                height: 2.5,
                color: AppColor.secondary),
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48,
                color: AppColor.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              widget.errorMessage!,
              style: const TextStyle(
                  color: AppColor.textLight,
                  fontSize: 15,
                  height: 1.5),
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

  // ── Empty State with alternate hotel picker ───────────
  Widget _buildEmptyState() {
    final hotelCtrl = Get.find<HotelController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // No rooms message
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          AppColor.primary.withOpacity(0.3),
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
                Obx(() => Text(
                      hotelCtrl.childHotels.length > 1
                          ? 'No rooms match your dates.\nTry one of our other properties below.'
                          : 'Please refine your search or check back later.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.textLight,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        ),

        // Alternate hotel picker
        Obx(() {
          final hotels = hotelCtrl.childHotels;
          if (hotels.length <= 1)
            return const SizedBox.shrink();

          final currentCode =
              hotelCtrl.selectedHotel.value?['code']
                  as String? ??
              '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primary
                                .withOpacity(0.6),
                            AppColor.primary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius:
                            BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'EXPLORE OTHER PROPERTIES',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Hotel cards
              Column(
                children:
                    hotels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hotel =
                      entry.value as Map<String, dynamic>;
                  final code =
                      hotel['code'] as String? ?? '';
                  final name = hotel['name'] as String? ??
                      'Hotel ${index + 1}';
                  final logoUrl = hotel['config']
                      ?['branding']?['logo'] as String?;
                  final isSelected = code == currentCode;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index < hotels.length - 1 ? 10 : 0,
                    ),
                    child: GestureDetector(
                      onTap: isSelected
                          ? null
                          : () {
                              // 1. Update HotelController
                              hotelCtrl
                                  .setSelectedHotel(hotel);

                              // 2. Update payload propertyCode
                              final searchCtrl = Get.find<search_ctrl
                                  .AppSearchController>();
                              final current =
                                  Map<String, dynamic>.from(
                                searchCtrl
                                    .searchPayload.value,
                              );
                              current['propertyCode'] = code;
                              searchCtrl
                                  .updateSearchPayload(current);

                              // 3. Tell parent to re-fetch
                              widget.onHotelSelected?.call();
                            },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primary
                                  .withOpacity(0.07)
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.primary
                                : AppColor.cardBorder,
                            width: isSelected ? 1.6 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColor.primary
                                      .withOpacity(0.12)
                                  : Colors.black
                                      .withOpacity(0.04),
                              blurRadius:
                                  isSelected ? 12 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Logo
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.primary
                                          .withOpacity(0.4)
                                      : AppColor.cardBorder,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(9),
                                child: (logoUrl != null &&
                                        logoUrl.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: logoUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __,
                                                ___) =>
                                            _hotelFallbackIcon(),
                                      )
                                    : _hotelFallbackIcon(),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Name + subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColor.text
                                          : AppColor.textLight,
                                      letterSpacing: 0.1,
                                    ),
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Currently selected',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColor.primary
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Radio
                            AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColor.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.primary
                                      : AppColor.cardBorder,
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
                }).toList(),
              ),

              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }

  Widget _hotelFallbackIcon() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withOpacity(0.6),
              AppColor.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.hotel_rounded,
            color: Colors.white, size: 18),
      );

  Widget _buildSkeletonUI() {
    return Container(
      color: AppColor.background,
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 14),
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

  BoxDecoration _skeletonBox({double radius = 6}) =>
      BoxDecoration(
        color: AppColor.cardBorder.withOpacity(0.4),
        borderRadius: BorderRadius.circular(radius),
      );

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColor.cardBorder, width: 1),
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
                    top: Radius.circular(20)),
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
    this.propertyDetails,
    this.propertyVideos,
    this.loyaltyConfig,
  });

  @override
  State<_RoyalRoomCard> createState() =>
      _RoyalRoomCardState();
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
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 0.982).animate(
      CurvedAnimation(
          parent: _pressController,
          curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final images = room['images'] as List? ?? [];
    final roomName = room['roomName'] ??
        room['room_name'] ??
        room['name'] ??
        'Luxury Suite';
    final roomType =
        room['roomType'] ?? room['room_type'] ?? '';
    final roomSize =
        room['roomSize'] ?? room['room_size'] ?? 0;
    final roomUnit =
        room['roomUnit'] ?? room['room_unit'] ?? 'sq ft';
    final roomView =
        room['roomView'] ?? room['room_view'] ?? '';
    final maxOccupancy =
        room['maxOccupancy'] ?? room['max_occupancy'] ?? 0;
    final description = room['description'] ?? '';

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
            border: Border.all(
                color: AppColor.cardBorder, width: 1),
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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _RoyalImageCarousel(
                    images: images, roomType: roomType),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
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
                      Wrap(
                        spacing: 18,
                        runSpacing: 10,
                        children: [
                          if (roomSize > 0)
                            _MetaChip(
                                icon:
                                    Icons.straighten_rounded,
                                label: '$roomSize $roomUnit'),
                          if (roomView.isNotEmpty)
                            _MetaChip(
                                icon:
                                    Icons.landscape_rounded,
                                label: roomView),
                          if (maxOccupancy > 0)
                            _MetaChip(
                                icon: Icons
                                    .people_outline_rounded,
                                label:
                                    'Up to $maxOccupancy guests'),
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
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColor.primary.withOpacity(0.3),
                        AppColor.secondary
                            .withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.25, 0.75, 1],
                    ),
                  ),
                ),
                _ViewDetailsButton(
                  room: room,
                  totalGuests: widget.totalGuests,
                  propertyCode: widget.propertyCode,
                  hotelName: widget.hotelName,
                  propertyId: widget.propertyId,
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
//  Image Carousel
// ─────────────────────────────────────────────
class _RoyalImageCarousel extends StatefulWidget {
  final List images;
  final String roomType;

  const _RoyalImageCarousel(
      {required this.images, required this.roomType});

  @override
  State<_RoyalImageCarousel> createState() =>
      _RoyalImageCarouselState();
}

class _RoyalImageCarouselState
    extends State<_RoyalImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

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
        : [
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=1200'
          ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_resolvedUrls.length > 1) _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) {
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
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (i) {
              if (mounted) setState(() => _currentPage = i);
            },
            itemBuilder: (_, index) => CachedNetworkImage(
              imageUrl: urls[index],
              fit: BoxFit.cover,
              memCacheWidth: 600,
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
              errorWidget: (context, url, error) =>
                  Container(
                color:
                    AppColor.cardBorder.withOpacity(0.15),
                child: Icon(Icons.image_rounded,
                    color: AppColor.cardBorder, size: 48),
              ),
            ),
          ),
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
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.35),
                  ],
                ),
              ),
            ),
          ),
          if (widget.roomType.isNotEmpty)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
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
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
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
          if (urls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 3),
                    width: active ? 20 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColor.primary
                          : Colors.white.withOpacity(0.5),
                      borderRadius:
                          BorderRadius.circular(3),
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
  final Map<String, dynamic>? propertyDetails;
  final Map<String, dynamic>? propertyVideos;
  final Map<String, dynamic>? loyaltyConfig;

  const _ViewDetailsButton({
    required this.room,
    required this.totalGuests,
    required this.propertyCode,
    required this.hotelName,
    required this.propertyId,
    this.propertyDetails,
    this.propertyVideos,
    this.loyaltyConfig,
  });

  @override
  State<_ViewDetailsButton> createState() =>
      _ViewDetailsButtonState();
}

class _ViewDetailsButtonState
    extends State<_ViewDetailsButton> {
  bool _pressed = false;

  void _navigate() {
    try {
      final searchController =
          Get.find<search_ctrl.AppSearchController>();
      final searchPayload = Map<String, dynamic>.from(
          searchController.searchPayload.value);
      final shortPropertyCode =
          searchPayload['PropertyCode'] as String? ??
              searchPayload['propertyCode'] as String? ??
              widget.propertyCode;

      final loyaltyConfig = widget.loyaltyConfig;
      final propertyVideos = widget.propertyVideos;
      final propertyDetails = widget.propertyDetails;
      final basicLoyaltyProgram =
          loyaltyConfig?['BasicLoyaltyProgram'];
      final loyaltyConditions =
          loyaltyConfig?['loyaltyConditions'] as List?;
      final loyaltySpecialConditions =
          loyaltyConfig?['loyaltySpecialConditions'] as List?;

      String? termsText;
      if (loyaltyConditions != null &&
          loyaltyConditions.isNotEmpty) {
        final first = loyaltyConditions[0];
        if (first is Map)
          termsText = first['text'] as String?;
      }

      String? benefitsTitle;
      String? benefitsSubtitle;
      if (loyaltySpecialConditions != null &&
          loyaltySpecialConditions.isNotEmpty) {
        final first = loyaltySpecialConditions[0];
        if (first is Map) {
          benefitsTitle = first['title'] as String?;
          benefitsSubtitle = first['subTitle'] as String?;
        }
      }

      String? logoUrl;
      if (basicLoyaltyProgram != null) {
        final logoList =
            basicLoyaltyProgram['logo'] as List?;
        if (logoList != null && logoList.isNotEmpty) {
          logoUrl = logoList[0] as String?;
        }
      }

      final loyaltyData = {
        'discountValue':
            loyaltyConfig?['discountValue'] ?? 10,
        'termsText': termsText ??
            "Member-Only Rates\nEnjoy special discounted prices.",
        'benefitsTitle': benefitsTitle ?? "VIP Perks",
        'benefitsSubtitle': benefitsSubtitle ??
            "Exclusive benefits for members.",
        'videoUrl': propertyVideos?['url'],
        'videoThumbnail': propertyVideos?['thumbnail'],
        'logoUrl': logoUrl,
        'propertyName':
            propertyDetails?['propertyName'] ??
                widget.hotelName,
      };

      Get.toNamed(
        '/room-details',
        arguments: {
          'room': {
            ...widget.room,
            'invTypeCode': widget.room['roomType'] ??
                widget.room['room_type'] ??
                widget.room['invTypeCode'] ??
                '',
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
            'termsText':
                "Member-Only Rates\nEnjoy special discounted prices.",
            'benefitsTitle': "VIP Perks",
            'benefitsSubtitle':
                "Exclusive benefits for members.",
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
      onTapCancel: () =>
          setState(() => _pressed = false),
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
                    color:
                        AppColor.primary.withOpacity(0.28),
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
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded,
                size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Outlined Button
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
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColor.primary, width: 1.5),
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
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(
          parent: _ctrl, curve: Curves.easeInOut),
    );
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