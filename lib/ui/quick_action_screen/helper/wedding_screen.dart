// lib/ui/wedding_page/wedding_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeddingPage extends StatefulWidget {
  const WeddingPage({super.key});

  @override
  State<WeddingPage> createState() => _WeddingPageState();
}

class _WeddingPageState extends State<WeddingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _WeddingHeaderDelegate(
                expandedHeight: 220,
                collapsedHeight: 76,
                builder: (t) => _buildHeader(context, t),
              ),
            ),
          ];
        },
        body: Builder(
          builder: (context) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      _buildImageTextRow(),
                      const SizedBox(height: 25),
                      _buildVenueSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double t) {
    // t = 0.0 (expanded) → 1.0 (collapsed)

    // Padding animations
    final double topPadding = lerpDouble(30, 12, t)!;
    final double bottomPadding = lerpDouble(1, 20, t)!;

    // Brand row animations
    final double brandRowOpacity = lerpDouble(1.0, 0.0, t)!;
    final double brandRowHeight = lerpDouble(30, 0, t)!;
    final double brandTextSize = lerpDouble(18, 0, t)!;
    final double brandIconSize = lerpDouble(16, 0, t)!;
    final double brandContainerSize = lerpDouble(35, 0, t)!;

    // Description animation
    final double descriptionOpacity = lerpDouble(1.0, 0.0, t)!;
    final double descriptionHeight = lerpDouble(120.0, 0.0, t)!;

    // Divider animation
    final double dividerOpacity = lerpDouble(1.0, 0.0, t)!;

    // Back button animations
    final double backButtonTopMargin = lerpDouble(0, 20, t)!;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, bottomPadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2E5C), Color(0xFF0D5399), Color(0xFF1A6ABF)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative background circles - fade out on scroll
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: lerpDouble(1.0, 0.0, t)!,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0DFFFFFF),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Opacity(
              opacity: lerpDouble(1.0, 0.0, t)!,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0AFFFFFF),
                ),
              ),
            ),
          ),

          // Main header content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand badge row - animates out
                        SizedBox(
                          height: brandRowHeight,
                          child: Opacity(
                            opacity: brandRowOpacity.clamp(0.0, 1.0),
                            child: Row(
                              children: [
                                Container(
                                  width: brandContainerSize,
                                  height: brandContainerSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0x26FFD700),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: const Color(0x4DFFD700),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: const Color(0xFFAD9064),
                                    size: brandIconSize,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'WEDDINGS',
                                  style: TextStyle(
                                    fontSize: brandTextSize,
                                    color: const Color(0xFFAD9064),
                                    letterSpacing: 2.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Description text - animates out
                        if (descriptionOpacity > 0)
                          SizedBox(
                            height: descriptionHeight,
                            child: Opacity(
                              opacity: descriptionOpacity.clamp(0.0, 1.0),
                              child: Text(
                                'Stella Di Mare Hotels specialize in all things celebratory, from intimate gatherings with friends & family to elegant extravaganzas. A place where luxury defines not only the fine amenities and attention to detail but the attentive way we cater to you.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                  height: 1.3,
                                ),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Back button
                  Padding(
                    padding: EdgeInsets.only(top: backButtonTopMargin),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Gold shimmer divider - fades out
              if (dividerOpacity > 0) ...[
                const SizedBox(height: 16),
                Opacity(
                  opacity: dividerOpacity.clamp(0.0, 1.0),
                  child: Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x66FFD700),
                          Color(0x99FFD700),
                          Color(0x66FFD700),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── IMAGE + TEXT IN ROW ───────────────────────────────────────────────────

  Widget _buildImageTextRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFEEE8DE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/images/weddingP.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.photo_camera_outlined,
                  size: 48,
                  color: Color(0xFFBBB0A0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text content on the right
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Services',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '• Venue rental\n• Room reservations\n• Free parking\n• Pre-wedding reception/cocktail\n• Decorations: flowers, center pieces and entrance\n• Photography/videography\n• Lights and sound system\n• Entertainment (DJ + oriental or classical Zaffa)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF444444),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FIND YOUR WEDDING VENUE SECTION ───────────────────────────────────────

  Widget _buildVenueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Find Your Wedding Venue',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Gold shimmer divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0x66FFD700),
                  Color(0x99FFD700),
                  Color(0x66FFD700),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Horizontal scrollable cards
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: _venues.length,
            itemBuilder: (context, index) {
              final venue = _venues[index];
              final isLast = index == _venues.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 4 : 12),
                child: _VenueCard(venue: venue),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── VENUE DATA MODEL ────────────────────────────────────────────────────────

class Venue {
  final String imagePath;
  final String title;
  final String description;

  const Venue({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

// ─── VENUE DATA ──────────────────────────────────────────────────────────────

const List<Venue> _venues = [
  Venue(
    imagePath: 'assets/images/grandHotel.png',
    title: 'Grand Hotel',
    description:
        'Crystal water with gentle waves of the Red Sea, deep-sea fishing, and a relaxing environment are what you need to pick some rest and revive energy. Ain Soukhna enjoys a splendid moderate atmosphere throughout the year and is not limited to a specific season.\nYou can enjoy spending your holidays at any time of the year.',
  ),
  Venue(
    imagePath: 'assets/images/marinaHotel.png',
    title: 'Dubai Marina Hotel',
    description:
        'In case of planning a perfect business or adventure with non-stop excitation and delightful moments, doubtless, Dubai must be the first city your mind picks up. The most prestigious city in the world and a popular attraction spot for tourists, with unmatched surroundings, tallest building on our planet, charming beaches and exotic activities.',
  ),
  Venue(
    imagePath: 'assets/images/beachHS.png',
    title: 'Beach Hotel & Spa',
    description:
        'Step into the desert of the Sinai Peninsula and reveal life experience of clear enchanted water with coral reefs and golden beaches.\nWhether you\'re planning a romantic weekend getaway, a family vacation, or even a business retreat, there\'s something for everyone to enjoy at Stella Di Mare Beach Hotel & Spa Sharm El Sheikh.',
  ),
];

// ─── VENUE CARD WIDGET ───────────────────────────────────────────────────────

class _VenueCard extends StatelessWidget {
  final Venue venue;

  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.asset(
                venue.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEEE8DE),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 48,
                    color: Color(0xFFBBB0A0),
                  ),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A2E5C),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  venue.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PINNED HEADER DELEGATE ───────────────────────────────────────────────

class _WeddingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _WeddingHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_WeddingHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return SizedBox(height: expandedHeight, child: builder(t));
  }
}
