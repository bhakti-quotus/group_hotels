// lib/ui/gallery_page/gallery_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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
              delegate: _GalleryHeaderDelegate(
                expandedHeight: 200,
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
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _hotels[index];
                          final isLast = index == _hotels.length - 1;
                          return _HotelGallerySection(
                            hotel: hotel,
                            showDivider: !isLast,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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

  // ─── HEADER WITH COLLAPSE ANIMATIONS ────────────────────────────────────────

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
    final double descriptionHeight = lerpDouble(90.0, 0.0, t)!;

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
                                    Icons.photo_library,
                                    color: const Color(0xFFAD9064),
                                    size: brandIconSize,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'GALLERY',
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
                                'Explore the stunning beauty of Stella Di Mare Hotels through our curated collection of premium imagery. From luxurious suites to breathtaking views, discover what makes each of our properties uniquely spectacular.',
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
}

// ─── PINNED HEADER DELEGATE ─────────────────────────────────────────────

class _GalleryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _GalleryHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_GalleryHeaderDelegate oldDelegate) => true;

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

// ─── HOTEL DATA MODEL ────────────────────────────────────────────────────────

class HotelGallery {
  final String name;
  final String description;
  final List<String> imagePaths;

  const HotelGallery({
    required this.name,
    required this.description,
    required this.imagePaths,
  });
}

// ─── HOTEL GALLERY DATA ──────────────────────────────────────────────────────

const List<HotelGallery> _hotels = [
  HotelGallery(
    name: 'Dubai Marina Hotel',
    description:
        'Standing tall in the heart of Dubai Marina, our property offers breathtaking views of the marina skyline and the Arabian Gulf. Experience modern luxury with world-class amenities.',
    imagePaths: [
      'assets/images/dmh1.png',
      'assets/images/dmh2.png',
      'assets/images/dmh3.png',
      'assets/images/dmh4.png',
      'assets/images/dmh5.png',
      'assets/images/dmh6.png',
      'assets/images/dmh7.png',
      'assets/images/dmh8.png',
    ],
  ),
  HotelGallery(
    name: 'Beach Hotel & Spa',
    description:
        'Nestled along pristine shores, our Beach Hotel & Spa offers the perfect blend of relaxation and recreation. Enjoy stunning sea views, luxurious spa treatments, and direct beach access.',
    imagePaths: [
      'assets/images/bhs1.png',
      'assets/images/bhs2.png',
      'assets/images/bhs3.png',
      'assets/images/bhs4.png',
      'assets/images/bhs5.png',
      'assets/images/bhs6.png',
      'assets/images/bhs7.png',
      'assets/images/bhs8.png',
    ],
  ),
  HotelGallery(
    name: 'Grand Hotel',
    description:
        'Epitomizing elegance and grandeur, our flagship property features magnificent architecture, lavish interiors, and unparalleled service. Perfect for discerning travelers seeking the extraordinary.',
    imagePaths: [
      'assets/images/gh1.png',
      'assets/images/gh2.png',
      'assets/images/gh3.png',
      'assets/images/gh4.png',
      'assets/images/gh5.png',
      'assets/images/gh6.png',
      'assets/images/gh7.png',
      'assets/images/gh8.png',
    ],
  ),
];

// ─── HOTEL GALLERY SECTION WIDGET ────────────────────────────────────────────

class _HotelGallerySection extends StatelessWidget {
  final HotelGallery hotel;
  final bool showDivider;

  const _HotelGallerySection({required this.hotel, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        // Hotel name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            hotel.name,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1A1A),
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Hotel description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            hotel.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Grid of images - 2 per row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Square images
            ),
            itemCount: hotel.imagePaths.length,
            itemBuilder: (context, index) {
              return _GalleryImageCard(
                imagePath: hotel.imagePaths[index],
                heroTag: '${hotel.name}_$index',
              );
            },
          ),
        ),

        // Divider between sections
        if (showDivider)
          Container(
            margin: const EdgeInsets.fromLTRB(22, 32, 22, 0),
            height: 1,
            color: const Color(0xFFE8E0D4),
          ),
      ],
    );
  }
}

// ─── GALLERY IMAGE CARD WIDGET ───────────────────────────────────────────────

class _GalleryImageCard extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const _GalleryImageCard({required this.imagePath, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context, imagePath, heroTag);
      },
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEEE8DE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
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
