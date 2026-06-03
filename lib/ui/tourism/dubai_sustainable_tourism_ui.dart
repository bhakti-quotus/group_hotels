import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class AppColors {
  static const darkGreen = Color(0xFF1B5E20);
  static const mediumGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFF4CAF50);
  static const paleGreen = Color(0xFFE8F5E9);
  static const accentGreen = Color(0xFF66BB6A);
  static const gold = Color(0xFFFFCA28);
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF9FBF9);
  static const textDark = Color(0xFF1A2E1A);
  static const textMid = Color(0xFF3D5A3D);
  static const textLight = Color(0xFF6A8F6A);
}

// ─── Dubai Sustainable Tourism Page ───────────────────────────────────────────
class DubaiSustainableTourismPage extends StatefulWidget {
  const DubaiSustainableTourismPage({super.key});

  @override
  State<DubaiSustainableTourismPage> createState() =>
      _DubaiSustainableTourismPageState();
}

class _DubaiSustainableTourismPageState
    extends State<DubaiSustainableTourismPage> {
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
              delegate: _SustainabilityHeaderDelegate(
                expandedHeight: 260,
                collapsedHeight: 85,
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
                        itemCount:
                            _sustainabilityActivities.length +
                            1 +
                            _videos.length, // Activities + Carousel + Videos
                        itemBuilder: (context, index) {
                          // First section: Sustainability Activities
                          if (index < _sustainabilityActivities.length) {
                            final activity = _sustainabilityActivities[index];
                            final isLast =
                                index == _sustainabilityActivities.length - 1;
                            return _SustainabilityBlock(
                              activity: activity,
                              showDivider: !isLast,
                            );
                          }

                          // Second section: Certificate Carousel
                          if (index == _sustainabilityActivities.length) {
                            return const _CertificateCarouselSection();
                          }

                          // Third section: Videos
                          final videoIndex =
                              index - _sustainabilityActivities.length - 1;
                          final video = _videos[videoIndex];
                          final isLastVideo = videoIndex == _videos.length - 1;
                          return _VideoBlock(
                            video: video,
                            showDivider: !isLastVideo,
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

    // Background image opacity - fades out on collapse
    final double imageOpacity = lerpDouble(1.0, 0.0, t)!;

    // Overlay opacity - increases as we collapse
    final double overlayOpacity = lerpDouble(0.0, 0.85, t)!;

    // Content animations
    final double contentOpacity = lerpDouble(1.0, 0.0, t)!;
    final double contentHeight = lerpDouble(200.0, 0.0, t)!;

    // Brand row animations
    final double brandRowOpacity = lerpDouble(1.0, 0.0, t)!;
    final double brandRowHeight = lerpDouble(30, 0, t)!;
    final double brandTextSize = lerpDouble(18, 0, t)!;
    final double brandIconSize = lerpDouble(16, 0, t)!;
    final double brandContainerSize = lerpDouble(28, 0, t)!;

    // Description animation
    final double descriptionOpacity = lerpDouble(1.0, 0.0, t)!;
    final double descriptionHeight = lerpDouble(150.0, 0.0, t)!;

    // Divider animation
    final double dividerOpacity = lerpDouble(1.0, 0.0, t)!;

    // Back button animations
    final double backButtonTopMargin = lerpDouble(0, 20, t)!;
    final double backButtonBottomMargin = lerpDouble(0, 20, t)!;

    return Container(
      height: 320,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/sustainability.jpeg'),
          fit: BoxFit.cover,
          opacity: imageOpacity,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          color: Colors.black.withOpacity(overlayOpacity),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative background circles - fade out on scroll
              Positioned(
                top: -40,
                right: -40,
                child: Opacity(
                  opacity: lerpDouble(0.5, 0.0, t)!,
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
                  opacity: lerpDouble(0.5, 0.0, t)!,
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
                                        Icons.eco,
                                        color: const Color(0xFFAD9064),
                                        size: brandIconSize,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SUSTAINABILITY',
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
                                  child: const Text(
                                    'It is a known fact that hotels are significant contributors to the global tourism industry. With that knowledge, all Stella Di Mare Hotels are continually trying to become more and more environmentally friendly. In order to conserve these precious resources such as committing to reduce water, energy and waste, it becomes a consistent goal to achieve. Therefore, the implementation of activities have been taken seriously in the recent years.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Back button
                      Padding(
                        padding: EdgeInsets.only(
                          top: backButtonTopMargin,
                          bottom: backButtonBottomMargin,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                lerpDouble(0.3, 0.5, t)!,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  lerpDouble(0.3, 0.15, t)!,
                                ),
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
        ),
      ),
    );
  }
}

// ─── PINNED HEADER DELEGATE ─────────────────────────────────────────────

class _SustainabilityHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _SustainabilityHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_SustainabilityHeaderDelegate oldDelegate) => true;

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

// ─── DATA MODELS ─────────────────────────────────────────────────────────────

class SustainabilityActivity {
  final String title;
  final String description;
  final String imagePath;

  const SustainabilityActivity({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class VideoItem {
  final String title;
  final String thumbnailPath;
  final String videoUrl;

  const VideoItem({
    required this.title,
    required this.thumbnailPath,
    required this.videoUrl,
  });
}

// ─── ACTIVITIES DATA ─────────────────────────────────────────────────────────

const List<SustainabilityActivity> _sustainabilityActivities = [
  SustainabilityActivity(
    title: 'Stella Di Mare Dubai Marina Hotel\nDubai',
    description:
        'In our commitment to sustainable transportation, Stella Di Mare Hotels has installed state-of-the-art Electric Vehicle Charging Stations at our Dubai properties. This initiative encourages guests to choose eco-friendly transportation options while enjoying convenient charging facilities during their stay. Our EV charging stations are equipped with fast-charging technology and are compatible with all major electric vehicle models. By providing this green infrastructure, we aim to reduce carbon emissions and promote clean energy adoption among our guests and staff.',
    imagePath: 'assets/images/sustain2.png',
  ),
  SustainabilityActivity(
    title: 'Stella Di Mare Beach Hotel & Spa\nSharm El Sheikh',
    description:
        'On World Food Safety Day 2023, Stella Di Mare Hotels organized comprehensive workshops and awareness campaigns highlighting the importance of food safety and hygiene. Our culinary teams demonstrated best practices in food handling, storage, and preparation. We also conducted interactive sessions with guests about sustainable food choices and reducing food waste. This initiative aligns with our commitment to providing safe, healthy, and sustainable dining experiences while raising awareness about global food safety standards.',
    imagePath: 'assets/images/spa_sport.png',
  ),
  SustainabilityActivity(
    title: 'Stella Di Mare Dubai Marina\nISO Certificates',
    description:
        'Stella Di Mare Hotels has transitioned to renewable energy sources across our properties. Solar panels have been installed on rooftops, significantly reducing our carbon footprint. This green energy initiative powers our daily operations, from lighting to HVAC systems, demonstrating our commitment to combating climate change. Guests can learn about our solar energy production through interactive displays in hotel lobbies.',
    imagePath: 'assets/images/sustain9.png',
  ),
  SustainabilityActivity(
    title: 'Stella Di Mare Dubai Marina\nDubai Sustainable Tourism Stamp 2024',
    description:
        'Stella Di Mare Hotels has transitioned to renewable energy sources across our properties. Solar panels have been installed on rooftops, significantly reducing our carbon footprint. This green energy initiative powers our daily operations, from lighting to HVAC systems, demonstrating our commitment to combating climate change. Guests can learn about our solar energy production through interactive displays in hotel lobbies.',
    imagePath: 'assets/images/sustain4.png',
  ),
];

// ─── VIDEOS DATA ─────────────────────────────────────────────────────────────

const List<VideoItem> _videos = [
  VideoItem(
    title: 'Electric Vehicle Charging Station - Dubai',
    thumbnailPath: 'assets/images/ev_charging_thumb.jpg',
    videoUrl:
        'https://stelladimare.com/wp-content/uploads/2023/08/Electric_Car_Charging_Station_Stella_Di_Mare_Dubai_L.mp4',
  ),
  VideoItem(
    title: 'World Food Safety Day 2023',
    thumbnailPath: 'assets/images/food_safety_thumb.jpg',
    videoUrl:
        'https://stelladimare.com/wp-content/uploads/2023/06/Food_Safty_Day_Dubai.mp4',
  ),
];

// ─── SUSTAINABILITY BLOCK WIDGET ─────────────────────────────────────────────

class _SustainabilityBlock extends StatelessWidget {
  final SustainabilityActivity activity;
  final bool showDivider;

  const _SustainabilityBlock({
    required this.activity,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // ── Full-width image, flush edge to edge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 230,
              child: Image.asset(
                activity.imagePath,
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

        // ── Text body
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Italic serif title
              Text(
                activity.title,
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
              const SizedBox(height: 16),
              Text(
                activity.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  height: 1.75,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // ── Warm divider line between sections
        if (showDivider)
          Container(
            margin: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            height: 1,
            color: const Color(0xFFE8E0D4),
          ),
      ],
    );
  }
}

// ─── Certificate Carousel Section ──
class _CertificateCarouselSection extends StatefulWidget {
  const _CertificateCarouselSection();

  @override
  State<_CertificateCarouselSection> createState() =>
      _CertificateCarouselSectionState();
}

class _CertificateCarouselSectionState
    extends State<_CertificateCarouselSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<String> _certificateImages = [
    'assets/images/sustain1.png',
    'assets/images/sustain2.png',
    'assets/images/sustain3.png',
    'assets/images/sustain4.png',
    'assets/images/sustain5.png',
    'assets/images/sustain6.png',
    'assets/images/sustain7.png',
    'assets/images/sustain8.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(22, 32, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Recent Activities',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 3, color: const Color(0xFFFFCA28)),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _certificateImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          _certificateImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF5F2EE),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Color(0xFFBBB0A0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _certificateImages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.darkGreen
                              : const Color(0xFFD4C9B8),
                        ),
                      ),
                    ),
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

// ─── VIDEO BLOCK WIDGET ─────────────────────────────────────────────────────

class _VideoBlock extends StatefulWidget {
  final VideoItem video;
  final bool showDivider;

  const _VideoBlock({required this.video, required this.showDivider});

  @override
  State<_VideoBlock> createState() => _VideoBlockState();
}

class _VideoBlockState extends State<_VideoBlock> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.lightGreen,
        handleColor: AppColors.darkGreen,
        backgroundColor: Colors.grey.shade300,
        bufferedColor: AppColors.accentGreen,
      ),
    );

    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // ── Text body
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Italic serif title
              Text(
                widget.video.title,
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

              const SizedBox(height: 20),

              // Video Section
              if (_isVideoInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E0D4)),
                    ),
                    child: Chewie(controller: _chewieController),
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightGreen,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Warm divider line between sections
        if (widget.showDivider)
          Container(
            margin: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            height: 1,
            color: const Color(0xFFE8E0D4),
          ),

        if (!widget.showDivider) const SizedBox(height: 40),
      ],
    );
  }
}
