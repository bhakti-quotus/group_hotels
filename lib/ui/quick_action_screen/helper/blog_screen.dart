// lib/ui/offers_page/offers_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/blog_helper/AdvanceBookingDetailPage.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/blog_helper/BlackFridayDetailPage.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/blog_helper/MinimumStayDetailPage.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
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
              delegate: _BlogHeaderDelegate(
                expandedHeight: 150,
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
                        itemCount: offerSections.length,
                        itemBuilder: (context, index) {
                          final offer = offerSections[index];
                          final isLast = index == offerSections.length - 1;
                          return _OfferCard(offer: offer, showDivider: !isLast);
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

    // Sub heading animation
    final double subHeadingOpacity = lerpDouble(1.0, 0.0, t)!;
    final double subHeadingHeight = lerpDouble(36.0, 0.0, t)!;

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
                                    Icons.local_offer_outlined,
                                    color: const Color(0xFFAD9064),
                                    size: brandIconSize,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'BLOG',
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

                        // Sub heading - animates out
                        if (subHeadingOpacity > 0)
                          SizedBox(
                            height: subHeadingHeight,
                            child: Opacity(
                              opacity: subHeadingOpacity.clamp(0.0, 1.0),
                              child: const Text(
                                'It\'s Going to Get Better from Here, Stay Tuned.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xB3FFFFFF),
                                  fontWeight: FontWeight.w400,
                                ),
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

class _BlogHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _BlogHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_BlogHeaderDelegate oldDelegate) => true;

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

// ─── OFFER DATA MODEL ──────────────────────────────────────────────────────
class OfferSection {
  final String title;
  final String badge;
  final String validUntil;
  final String imagePath;

  const OfferSection({
    required this.title,
    required this.badge,
    required this.validUntil,
    required this.imagePath,
  });
}

// ─── OFFER DATA (3 CARDS AS REQUESTED) ─────────────────────────────────────
const List<OfferSection> offerSections = [
  OfferSection(
    title: 'Black Friday Sale',
    badge: 'Blog',
    validUntil: 'September 26, 2025',
    imagePath: 'assets/images/offer1.png',
  ),
  OfferSection(
    title: 'Advance Booking',
    badge: 'Blog',
    validUntil: 'July 18, 2025',
    imagePath: 'assets/images/offer2.png',
  ),
  OfferSection(
    title: 'Minimum Stay Offer',
    badge: 'Blog',
    validUntil: 'November 17, 2024',
    imagePath: 'assets/images/offer3.png',
  ),
];

// ─── OFFER CARD WIDGET WITH READ MORE BUTTON ALIGNED TO RIGHT ───────────────
class _OfferCard extends StatelessWidget {
  final OfferSection offer;
  final bool showDivider;

  const _OfferCard({required this.offer, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // ── Card container with image and overlay text ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with rounded top corners and overlay gradient
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Image
                    SizedBox(
                      width: double.infinity,
                      height: 260,
                      child: Image.asset(
                        offer.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEEE8DE),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Color(0xFFBBB0A0),
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay for better text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Offer badge (top left)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          offer.badge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2A3A),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                offer.validUntil,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 139, 139, 138),
                ),
              ),
              const SizedBox(height: 5),

              // Title and Read More button in the same row (title left, button right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title (serif italic, matching reference) - Takes remaining space
                  Expanded(
                    child: Text(
                      offer.title,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Read More Button - Aligned to right
                  GestureDetector(
                    onTap: () {
                      _navigateToDetailPage(context, offer);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2E5C), // Navy blue background
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A2E5C).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Read More',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),

        // ── Warm divider line between sections ──
        if (showDivider)
          Container(
            margin: const EdgeInsets.fromLTRB(22, 28, 22, 0),
            height: 1,
            color: const Color(0xFFE8E0D4),
          ),
      ],
    );
  }

  // Navigation method
  void _navigateToDetailPage(BuildContext context, OfferSection offer) {
    switch (offer.title) {
      case 'Black Friday Sale':
        Get.to(() => BlackFridayDetailPage());
        break;
      case 'Advance Booking':
        Get.to(() => AdvanceBookingDetailPage());
        break;
      case 'Minimum Stay Offer':
        Get.to(() => MinimumStayDetailPage());
        break;
      default:
        Get.snackbar(
          'Navigate',
          'Navigate to ${offer.title} page',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0A2E5C),
          colorText: Colors.white,
        );
        break;
    }
  }
}
