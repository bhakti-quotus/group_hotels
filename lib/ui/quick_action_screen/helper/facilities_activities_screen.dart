// lib/ui/facilities_page/facilities_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FacilitiesPage extends StatefulWidget {
  const FacilitiesPage({super.key});

  @override
  State<FacilitiesPage> createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE0),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _FacilitiesHeaderDelegate(
                expandedHeight: 280,
                collapsedHeight: 72,
                builder: (t) => _buildHeader(context, t),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    final isLast = index == _sections.length - 1;
                    return _SectionBlock(
                      section: section,
                      showDivider: !isLast,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double t) {
    // t = 0.0 (expanded) → 1.0 (collapsed)

    // Padding animations
    final double topPadding = lerpDouble(20, 28, t)!;
    final double bottomPadding = lerpDouble(28, 12, t)!;

    // Text animations
    final double titleFontSize = lerpDouble(18, 14, t)!;
    final double descriptionFontSize = lerpDouble(13, 0, t)!;
    final double descriptionOpacity = lerpDouble(0.6, 0.0, t)!;

    // Brand row animations
    final double brandRowOpacity = lerpDouble(1.0, 0.0, t)!;
    final double brandRowHeight = lerpDouble(60, 0, t)!;
    final double brandTextSize = lerpDouble(18, 0, t)!;
    final double brandIconSize = lerpDouble(16, 0, t)!;
    final double brandContainerSize = lerpDouble(28, 0, t)!;

    // Divider animation
    final double dividerOpacity = lerpDouble(1.0, 0.0, t)!;

    // Back button animations
    final double backButtonSize = lerpDouble(34, 34, t)!;
    final double backButtonIconSize = lerpDouble(16, 16, t)!;
    final double backButtonTopMargin = lerpDouble(
      10,
      0,
      t,
    )!; // Change this value

    return Container(
      padding: EdgeInsets.fromLTRB(10, topPadding, 10, bottomPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2E5C), Color(0xFF0D5399), Color(0xFF1A6ABF)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative background circles
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
                                    Icons.workspace_premium,
                                    color: const Color(0xFFAD9064),
                                    size: brandIconSize,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Facilities & Activities',
                                  style: TextStyle(
                                    fontSize: brandTextSize,
                                    color: const Color(0xFFAD9064),
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Description text
                        Opacity(
                          opacity: descriptionOpacity.clamp(0.0, 1.0),
                          child: Text(
                            'Stella Di Mare Hotels Egypt have mesmerizing views of sparkling sapphire waters, stretching over the horizon, whereas Stella Di Mare Dubai stands tall in the heart of Dubai Marina. The hotel\'s collection offers over 1200+ rooms and suites, spacious meeting and event venues, luxurious spas, pools, private beaches & Marina lifestyle in 3 geographically dynamic destinations coming with exceptional Food & Beverage options to make you enjoy luxury in its purest forms.',
                            style: TextStyle(
                              fontSize: descriptionFontSize,
                              color: Colors.white.withOpacity(0.6),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Back button with top margin
                  Padding(
                    padding: EdgeInsets.only(top: backButtonTopMargin),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: backButtonSize,
                        height: backButtonSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: backButtonIconSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Gold shimmer divider
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

// ─── DATA MODEL ───────────────────────────────────────────────────────────────

class FacilitySection {
  final String title;
  final List<String> paragraphs;
  final String imagePath;

  const FacilitySection({
    required this.title,
    required this.paragraphs,
    required this.imagePath,
  });
}

// ─── SECTION DATA ─────────────────────────────────────────────────────────────

const List<FacilitySection> _sections = [
  FacilitySection(
    title: 'Spa & Sports',
    paragraphs: [
      'Awaken your body, mind and spirit and enter a tranquil space where simple, natural elements will captivate your senses. Stella Di Mare Hotels signature spas experiences draw from the best methods in wellness & relaxation and use only the finest products along with state-of-the-art equipment.',
    ],
    imagePath: 'assets/images/spa_sport.png',
  ),
  FacilitySection(
    title: 'Meetings & Events',
    paragraphs: [
      'Our Meetings & Events team at Stella Di Mare Hotels are experienced in creating bespoke events that cater to your particular need, whether it’s a dream wedding on the beach in Sharm El Shaikh or a corporate event in Dubai.\n\nFlexible rooms spaces are a key feature of our events spaces, making them ideal for board meetings to large conferences and receptions.',
    ],
    imagePath: 'assets/images/meeting.png',
  ),
  FacilitySection(
    title: 'Weddings',
    paragraphs: [
      'Stella Di Mare Hotels specialize in all things celebratory, from intimate gatherings with friends & family to elegant extravaganzas. A place where luxury defines not only the fine amenities and attention to detail but the attentive way we cater to you.',
    ],
    imagePath: 'assets/images/wedding.png',
  ),
  FacilitySection(
    title: 'Golf',
    paragraphs: [
      'A unique golfing experience not found anywhere else with challenging 18 holes, as your only distraction should be the panoramic scenery and choosing your next club. Stella Di Mare is a fairway from your usual hotel.',
    ],
    imagePath: 'assets/images/golf.png',
  ),
  FacilitySection(
    title: 'Diving',
    paragraphs: [
      'The red sea is a top destination among divers. With its exquisite warm water, it’s a great place to see mantas rays, sharks and an incredibly rich array of colorful reefs and colorful fishes. At Stella Di Mare Hotels, you can start from basic fun diving to become a PADI certified dive master. Enjoy an unforgettable vacation experience with the world’s most popular diving destinations.',
    ],
    imagePath: 'assets/images/diving.png',
  ),
];

// ─── SECTION BLOCK WIDGET ─────────────────────────────────────────────────────

class _SectionBlock extends StatelessWidget {
  final FacilitySection section;
  final bool showDivider;

  const _SectionBlock({required this.section, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Full-width image with rounded corners
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 230,
              child: Image.asset(
                section.imagePath,
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
          ),
        ),

        // Text body
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
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
              const SizedBox(height: 16),
              ...section.paragraphs.map(
                (para) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    para,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.75,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Warm divider line between sections
        if (showDivider)
          Container(
            margin: const EdgeInsets.fromLTRB(10, 14, 10, 0),
            height: 1,
            color: const Color(0xFFE8E0D4),
          ),
      ],
    );
  }
}

// ─── PINNED HEADER DELEGATE ───────────────────────────────────────────────

class _FacilitiesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _FacilitiesHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_FacilitiesHeaderDelegate oldDelegate) => true;

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
