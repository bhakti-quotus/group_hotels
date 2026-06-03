// lib/ui/dining_page/dining_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiningPage extends StatefulWidget {
  const DiningPage({super.key});

  @override
  State<DiningPage> createState() => _DiningPageState();
}

class _DiningPageState extends State<DiningPage> {
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
              delegate: _DiningHeaderDelegate(
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
                      _buildSectionHeader(),
                      const SizedBox(height: 20),
                      _buildRestaurantsGrid(),
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

  // ─── HEADER (WITH COLLAPSE ANIMATIONS) ─────────────────────────────────────

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
    final double brandContainerSize = lerpDouble(28, 0, t)!;

    // Description animation
    final double descriptionOpacity = lerpDouble(1.0, 0.0, t)!;
    final double descriptionHeight = lerpDouble(100.0, 0.0, t)!;

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
                                    Icons.restaurant,
                                    color: const Color(0xFFAD9064),
                                    size: brandIconSize,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DINING',
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
                                'Enjoy the best meals with the ultimate destination for a wide variety of world-class buffets and other delectable dining options. While witnessing the creative preparation and cultural ritual that goes into making every dish with relaxing music to enjoy while indulging an iconic dining experience.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                  height: 1.3,
                                ),
                                maxLines: 8,
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

  // ─── SECTION HEADER (ABOVE GRID) ───────────────────────────────────────────

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hotel Restaurants',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF5E6A3)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RESTAURANTS GRID (2 PER ROW) ─────────────────────────────────────────

  Widget _buildRestaurantsGrid() {
    final restaurants = _restaurantsData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.75,
        ),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return _RestaurantCard(restaurant: restaurant);
        },
      ),
    );
  }
}

// ─── PINNED HEADER DELEGATE ─────────────────────────────────────────────

class _DiningHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _DiningHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_DiningHeaderDelegate oldDelegate) => true;

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

// ─── RESTAURANT DATA MODEL ───────────────────────────────────────────────────

class RestaurantItem {
  final String name;
  final String cuisine;
  final String imagePath;
  final String heroTag;

  const RestaurantItem({
    required this.name,
    required this.cuisine,
    required this.imagePath,
    required this.heroTag,
  });
}

// ─── RESTAURANTS DATA (9 IMAGES) ─────────────────────────────────────────────

const List<RestaurantItem> _restaurantsData = [
  RestaurantItem(
    name: 'Yemaya',
    cuisine: 'Seafood',
    imagePath: 'assets/images/dinning1.png',
    heroTag: 'restaurant_0',
  ),
  RestaurantItem(
    name: 'La Fontana',
    cuisine: 'International',
    imagePath: 'assets/images/dinning2.png',
    heroTag: 'restaurant_1',
  ),
  RestaurantItem(
    name: 'La Terrazza',
    cuisine: 'International cuisine',
    imagePath: 'assets/images/dinning3.png',
    heroTag: 'restaurant_2',
  ),
  RestaurantItem(
    name: 'II Proverbio',
    cuisine: 'International',
    imagePath: 'assets/images/dinning4.png',
    heroTag: 'restaurant_3',
  ),
  RestaurantItem(
    name: 'La Scogliera',
    cuisine: 'Asia cuisine',
    imagePath: 'assets/images/dinning5.png',
    heroTag: 'restaurant_4',
  ),
  RestaurantItem(
    name: 'Hisaya',
    cuisine: 'Japanese cuisine',
    imagePath: 'assets/images/dinning6.png',
    heroTag: 'restaurant_5',
  ),
  RestaurantItem(
    name: '70s Restaurant',
    cuisine: 'International cuisine',
    imagePath: 'assets/images/dinning7.png',
    heroTag: 'restaurant_6',
  ),
  RestaurantItem(
    name: 'Ponte Vecchio',
    cuisine: 'Italian cuisine',
    imagePath: 'assets/images/dinning8.png',
    heroTag: 'restaurant_7',
  ),
  RestaurantItem(
    name: 'Corallo Rosso',
    cuisine: 'Mediterranean cuisine',
    imagePath: 'assets/images/dinning9.png',
    heroTag: 'restaurant_8',
  ),
];

// ─── RESTAURANT CARD (WITH TEXT OVERLAY - LEFT ALIGNED) ──────────────────────

class _RestaurantCard extends StatelessWidget {
  final RestaurantItem restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context, restaurant.imagePath, restaurant.heroTag);
      },
      child: Hero(
        tag: restaurant.heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                restaurant.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEEE8DE),
                  child: const Icon(
                    Icons.broken_image,
                    size: 32,
                    color: Color(0xFFBBB0A0),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.cuisine,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imagePath,
    String heroTag,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            _FullScreenImageView(imagePath: imagePath, heroTag: heroTag),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

// ─── FULL SCREEN IMAGE VIEW (TAP TO CLOSE) ───────────────────────────────────

class _FullScreenImageView extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const _FullScreenImageView({required this.imagePath, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black.withOpacity(0.95),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
