import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/hotel_controller.dart';
import 'package:royalcontinent/group/controllers/auth_controller.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';


class FeaturedHotelsSection extends StatefulWidget {
  final List<dynamic> hotels;

  const FeaturedHotelsSection({super.key, required this.hotels});

  @override
  State<FeaturedHotelsSection> createState() => _FeaturedHotelsSectionState();
}

class _FeaturedHotelsSectionState extends State<FeaturedHotelsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 20, height: 2, color: AppColor.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'OUR PROPERTIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.secondary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose \n Accommodation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColor.text,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/hotels'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Hotel cards
        ...widget.hotels.asMap().entries.map(
          (e) => HotelCard(hotel: e.value, index: e.key),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Hotel Card ───────────────────────────────────────────────────────────────

class HotelCard extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final int index;

  const HotelCard({super.key, required this.hotel, required this.index});

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressController;
  }

  String? _resolveHeroImage(
    Map<String, dynamic> hotelConfig,
    Map<String, dynamic> hotelBranding,
    List<dynamic> rooms,
  ) {
    // 1️⃣ heroBanner section — proper hotel photo
    final sections = hotelConfig['home']?['sections'] as List<dynamic>?;
    final heroBannerImg =
        sections?.firstWhere(
              (s) => s['type'] == 'heroBanner',
              orElse: () => null,
            )?['data']?['image']
            as String?;
    if (heroBannerImg != null && heroBannerImg.trim().isNotEmpty) {
      return heroBannerImg.trim();
    }

    // 2️⃣ First room image
    if (rooms.isNotEmpty) {
      final imgs = rooms.first['images'] as List?;
      final roomImg = imgs?.isNotEmpty == true
          ? (imgs!.first as String?)?.trim()
          : null;
      if (roomImg != null && roomImg.isNotEmpty) return roomImg;
    }

    // 3️⃣ Gallery
    final galleryItems = hotelConfig['gallery']?['items'] as List<dynamic>?;
    final galleryImg = galleryItems?.isNotEmpty == true
        ? (galleryItems!.first['url'] as String?)?.trim()
        : null;
    if (galleryImg != null && galleryImg.isNotEmpty) return galleryImg;

    // 4️⃣ splashImage as last resort only
    final splash = (hotelBranding['splashImage'] as String?)?.trim();
    if (splash != null && splash.isNotEmpty) return splash;

    return null;
  }

  int _roomTypeCount(List<dynamic> rooms) {
    final uniqueKeys = <String>{};
    for (final room in rooms) {
      if (room is Map) {
        final key = (room['roomTypeCode'] ?? room['roomType'] ?? room['roomName'] ?? room['name'] ?? room['id'])
            ?.toString()
            .trim();
        if (key != null && key.isNotEmpty) {
          uniqueKeys.add(key);
        }
      }
    }
    return uniqueKeys.length;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressController.reverse();
  void _onTapUp(_) => _pressController.forward();
  void _onTapCancel() => _pressController.forward();

  @override
  Widget build(BuildContext context) {
    final config = widget.hotel['config'] as Map<String, dynamic>? ?? {};
    final branding = config['branding'] as Map<String, dynamic>? ?? {};
    final contact = config['contact'] as Map<String, dynamic>? ?? {};
    final rooms = config['rooms'] as List<dynamic>? ?? [];
    final amenities = config['amenities'] as List<dynamic>? ?? [];

    final lowestPrice = rooms.isNotEmpty
        ? rooms
                  .map((r) => r['basePrice'] as int?)
                  .where((p) => p != null)
                  .reduce((a, b) => a! < b! ? a : b) ??
              0
        : 0;

    // Pick hero image using the multi-fallback resolver
    final heroImage = _resolveHeroImage(config, branding, rooms);

    final roomCount = rooms.length;
    final amenityCount = amenities.length;

    return GestureDetector(
      onTap: () {
        final hotelController = Get.find<HotelController>();
        hotelController.setSelectedHotel(widget.hotel);
        hotelController.setConfig(widget.hotel['config']);
        BrandingColors.loadFromConfig(
          config,
        ); // ✅ ADD THIS (config = widget.hotel['config'])
        Get.toNamed(AppRoutes.home, arguments: widget.hotel);
      },

      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image with overlay badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: heroImage != null
                        ? Image.network(
                            heroImage,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                  // Dark gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Top-right: logo badge
                  if (branding['logo'] != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          branding['logo'],
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.hotel, size: 20),
                        ),
                      ),
                    ),
                ],
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel name + arrow
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.hotel['name'] ?? 'Hotel',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColor.text,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColor.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact['address'] ?? 'Dubai, UAE',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.textLight,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.secondary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(Icons.hotel, size: 48, color: Colors.grey.shade300),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColor.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
