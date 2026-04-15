import 'dart:async';
import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HeroBanner extends StatefulWidget {
  final Map<String, dynamic> bannerData;
  final List<String> images;
  final int currentImageIndex;
  final String logoUrl;

  /// Optional: pass highlights items from config
  /// Each item: { 'icon': String, 'label': String }
  final List<dynamic>? highlights;

  const HeroBanner({
    super.key,
    required this.bannerData,
    required this.images,
    required this.currentImageIndex,
    required this.logoUrl,
    this.highlights,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with TickerProviderStateMixin {
  // Ken Burns zoom
  late AnimationController _zoomController;
  late Animation<double> _zoomAnim;

  // Text fade-up entrance
  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Auto-slide
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  // All images: banner image + gallery images combined
  late List<String> _allImages;

  @override
  void initState() {
    super.initState();

    // Combine banner image + passed images
    final bannerImg = widget.bannerData['image'] as String?;
    _allImages = [
      if (bannerImg != null && bannerImg.isNotEmpty) bannerImg,
      ...widget.images,
    ];
    if (_allImages.isEmpty) _allImages = [''];

    _pageController = PageController();

    // Ken Burns
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _zoomAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    // Text entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    // Auto-slide every 5s
    if (_allImages.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % _allImages.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _textController.dispose();
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  IconData _resolveIcon(String iconName) {
    const map = {
      'wifi': Icons.wifi_rounded,
      'spa': Icons.spa_outlined,
      'parking': Icons.local_parking_rounded,
      'pool': Icons.pool_rounded,
      'restaurant': Icons.restaurant_outlined,
      'gym': Icons.fitness_center_rounded,
      'bar': Icons.local_bar_outlined,
      'boating': Icons.sailing_outlined,
      'casino': Icons.casino_outlined,
      'elevator': Icons.elevator_outlined,
    };
    return map[iconName.toLowerCase()] ?? Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 340 + topPad,
      child: Stack(
        children: [
          // ── Sliding background images ──────────────────────────────────
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _allImages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _zoomAnim,
                builder: (_, __) => Transform.scale(
                  scale: index == _currentPage ? _zoomAnim.value : 1.0,
                  child: _allImages[index].isNotEmpty
                      ? Image.network(
                          _allImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColor.primary),
                        )
                      : Container(color: AppColor.primary),
                ),
              );
            },
          ),

          // ── Multi-layer gradient overlay ───────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.65, 1.0],
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.transparent,
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.80),
                ],
              ),
            ),
          ),

          // ── Curved bottom clip overlay ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _BottomCurveClipper(),
              child: Container(height: 48, color: AppColor.cardBackground),
            ),
          ),

          // ── Top bar: logo (left) + Partner Login (right) ──────────────
          Positioned(
            top: topPad + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo with frosted pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: widget.logoUrl.isNotEmpty
                      ? Image.network(
                          widget.logoUrl,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.hotel,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : const Icon(Icons.hotel, color: Colors.white, size: 24),
                ),

                // ── Partner Login button (top-right) ──────────────────
                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse('https://agent.revchilltech.com/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.secondary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Partner Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Page dots (bottom-right) ───────────────────────────────────
          if (_allImages.length > 1)
            Positioned(
              bottom: 60,
              right: 20,
              child: Row(
                children: List.generate(_allImages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColor.secondary
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

          // ── Bottom text content ────────────────────────────────────────
          Positioned(
            bottom: 52,
            left: 20,
            right: 20,
            child: SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle / eyebrow label
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 2,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (widget.bannerData['subtitle'] ?? '')
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      widget.bannerData['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Highlights pills (from config)
                    if (widget.highlights != null &&
                        widget.highlights!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.highlights!.take(4).map((h) {
                          final label = h['label'] as String? ?? '';
                          final iconName = h['icon'] as String? ?? '';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _resolveIcon(iconName),
                                  size: 12,
                                  color: AppColor.secondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // CTA button
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        widget.bannerData['cta']?['route'] ?? '/',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.secondary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.bannerData['cta']?['label'] ?? 'Book Now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom clipper for the curved bottom transition ──────────────────────────

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(size.width / 2, 0, 0, size.height * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}