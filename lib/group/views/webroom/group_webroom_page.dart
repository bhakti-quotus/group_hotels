import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:group/group/common/bottom_navitem/bottom_navitem_list.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/ui/bottom_navbar/bottom_navbar.dart';

class GroupWebRoomPage extends StatelessWidget {
  const GroupWebRoomPage({super.key});

  Color _parsePrimaryColor(Map<String, dynamic> config) {
    final branding = (config['branding'] as Map<String, dynamic>?) ?? {};
    final hex = branding['primaryColor'] as String?;
    if (hex != null && hex.isNotEmpty) {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    }
    return const Color(0xFF000000);
  }

  Color _parseSecondaryColor(Map<String, dynamic> config) {
    final branding = (config['branding'] as Map<String, dynamic>?) ?? {};
    final hex = branding['secondaryColor'] as String?;
    if (hex != null && hex.isNotEmpty) {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    }
    return const Color(0xFFad9064);
  }

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();
    final rootConfig = hotelController.getRootConfig() ?? hotelController.getConfig() ?? {};
    final groupConfig = (rootConfig['config'] as Map<String, dynamic>?) ?? {};
    final groupBranding = (groupConfig['branding'] as Map<String, dynamic>?) ?? {};

    // Royal Continental branding from config
    final primaryColor = _parsePrimaryColor(groupConfig);
    final accentColor = _parseSecondaryColor(groupConfig); // #ad9064 gold
    final groupLogo = groupBranding['logo'] as String?;

    final childHotels = (rootConfig['childHotels'] as List<dynamic>?) ?? [];

    return FutureBuilder<List<BottomNavItem>>(
      future: BottomNavItemManager.getNavItems(config: rootConfig),
      builder: (context, snapshot) {
        final navItems = snapshot.data ?? [];
        final currentIndex = navItems.indexWhere((item) => item.route == AppRoutes.webroom);

        void onNavTap(int index) {
          if (index < navItems.length) {
            Get.offNamed(navItems[index].route);
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F6),
          body: Column(
            children: [
            

              // ── "Our Collection" subtitle bar ────────────────────────────
              Container(
                //color: Colors.white,
                //padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    //const SizedBox(height: 20),
                    Container(
  color: Colors.white,
  padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Gold centered eyebrow line
      Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: accentColor.withOpacity(0.45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'OUR COLLECTION',
              style: TextStyle(
                fontSize: 10,
                color: accentColor,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: accentColor.withOpacity(0.45),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Serif title with italic gold accent
      RichText(
        text: const TextSpan(
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: 26,
            fontWeight: FontWeight.w300,
            color: Color(0xFF111111),
            letterSpacing: 0.3,
            height: 1.1,
          ),
          children: [
            TextSpan(text: 'Choose your '),
            TextSpan(
              text: 'property',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFFad9064),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
      // Dynamic property count subtitle
      Text(
        '${childHotels.length} luxury ${childHotels.length == 1 ? 'property' : 'properties'} · Saint Lucia',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFAAAAAA),
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
        ),
      ),
    ],
  ),
),
const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

              // ── Hotel list ───────────────────────────────────────────────
              Expanded(
                child: childHotels.isEmpty
                    ? Center(
                        child: Text(
                          'No properties found.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: childHotels.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final hotel = childHotels[index] as Map<String, dynamic>;
                          return _HotelCard(
                            hotel: hotel,
                            accentColor: accentColor,
                            onTap: () {
                              final hotelConfig = hotel['config'] as Map<String, dynamic>? ?? {};
                              hotelController.setSelectedHotel(hotel);
                              hotelController.setConfig(hotelConfig);
                              BrandingColors.loadFromConfig(hotelConfig);
                              Get.toNamed(AppRoutes.webroomChildSplash, arguments: hotel);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),

          // ── Bottom nav ───────────────────────────────────────────────────
          bottomNavigationBar: navItems.isNotEmpty
              ? BottomNavbar(
                  currentIndex: currentIndex >= 0 ? currentIndex : 0,
                  onTap: onNavTap,
                  items: navItems,
                  primaryColor: primaryColor,
                )
              : null,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Group Header Widget
// ─────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.logo, required this.accentColor});

  final String? logo;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo — from config branding.logo, inverted to white
              if (logo != null && logo!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: logo!,
                  height: 28,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                  errorWidget: (_, __, ___) => const Text(
                    'Royal Continental',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                )
              else
                const Text(
                  'Royal Continental',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              Icon(Icons.notifications_none_rounded, color: accentColor, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 0.5, color: accentColor.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hotel Card Widget
// ─────────────────────────────────────────────
class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.accentColor,
    required this.onTap,
  });

  final Map<String, dynamic> hotel;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hotelConfig = (hotel['config'] as Map<String, dynamic>?) ?? {};
    final branding = (hotelConfig['branding'] as Map<String, dynamic>?) ?? {};

    final name = hotel['name'] as String? ?? 'Hotel';
    final logo = branding['logo'] as String?;
    final splashImage = branding['splash_image'] as String? ?? branding['splashImage'] as String?;
    final address = (hotelConfig['contact'] as Map<String, dynamic>?)?['address'] as String?;

    // Tags from amenities
    final amenities = (hotelConfig['amenities'] as List<dynamic>?) ?? [];
    final tags = amenities
        .take(4)
        .map((a) => (a as Map<String, dynamic>)['label'] as String? ?? '')
        .where((l) => l.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Splash image ─────────────────────────────────────────
            _SplashBanner(splashImage: splashImage, hotel: hotel),

            // ── Card body ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Hotel logo
                      _HotelLogoBox(logo: logo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontFamily: 'Cormorant',
                                fontSize: 18,
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                            if (address != null && address.isNotEmpty)
                              Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF888888),
                                  letterSpacing: 0.2,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arrow CTA
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF111111), width: 0.8),
                        ),
                        child: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF111111)),
                      ),
                    ],
                  ),

                  // ── Divider ──────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),
                  ),

                  // ── Tags ─────────────────────────────────────────────
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.asMap().entries.map((e) {
                        final isFirst = e.key == 0;
                        return _Tag(label: e.value, isGold: isFirst, accentColor: accentColor);
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Splash Banner
// ─────────────────────────────────────────────
class _SplashBanner extends StatelessWidget {
  const _SplashBanner({required this.splashImage, required this.hotel});

  final String? splashImage;
  final Map<String, dynamic> hotel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (splashImage != null && splashImage!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: splashImage!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF1A1A1A),
                child: const Icon(Icons.hotel, color: Colors.white24, size: 48),
              ),
            )
          else
            Container(
              color: const Color(0xFF1A1A1A),
              child: const Icon(Icons.hotel, color: Colors.white24, size: 48),
            ),

          // Gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
              ),
            ),
          ),

          // Location badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
              ),
              child: Text(
                _extractLocation(hotel),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractLocation(Map<String, dynamic> hotel) {
    final config = (hotel['config'] as Map<String, dynamic>?) ?? {};
    final contact = (config['contact'] as Map<String, dynamic>?) ?? {};
    final address = contact['address'] as String? ?? '';
    // Extract last part after last comma for short location
    final parts = address.split(',');
    return parts.length > 1 ? parts.last.trim() : (hotel['slug'] as String? ?? 'Hotel');
  }
}

// ─────────────────────────────────────────────
// Hotel Logo Box
// ─────────────────────────────────────────────
class _HotelLogoBox extends StatelessWidget {
  const _HotelLogoBox({required this.logo});
  final String? logo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      padding: const EdgeInsets.all(6),
      child: logo != null && logo!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: logo!,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => const Icon(Icons.hotel_outlined, size: 24, color: Color(0xFF999999)),
            )
          : const Icon(Icons.hotel_outlined, size: 24, color: Color(0xFF999999)),
    );
  }
}

// ─────────────────────────────────────────────
// Tag Chip
// ─────────────────────────────────────────────
class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.isGold, required this.accentColor});
  final String label;
  final bool isGold;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGold ? accentColor.withOpacity(0.08) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGold ? accentColor.withOpacity(0.3) : const Color(0xFFE0E0E0),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          color: isGold ? const Color(0xFF7A6234) : const Color(0xFF666666),
        ),
      ),
    );
  }
}