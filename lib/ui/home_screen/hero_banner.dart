import 'dart:async';
import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class HeroBanner extends StatefulWidget {
  final Map<String, dynamic> bannerData;
  final List<String> images;
  final int currentImageIndex;
  final String logoUrl;
  final List<dynamic>? highlights;

  const HeroBanner({
    Key? key,
    required this.bannerData,
    required this.images,
    required this.currentImageIndex,
    required this.logoUrl,
    this.highlights,
  }) : super(key: key);

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  late AnimationController _subtitleController;
  late Animation<double> _subtitleOpacity;

  late AnimationController _ctaController;
  late Animation<double> _ctaOpacity;
  late Animation<Offset> _ctaSlide;

  static const _videoUrl =
      'https://www.thebodyholiday.com/wp-content/themes/bodyholiday/custom-assets/video/BH-mobile-optimized-new.mp4';

  @override
  void initState() {
    super.initState();

    // ── Video ─────────────────────────────────────────────────────────────
    _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoInitialized = true);
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      });

    // ── Staggered entrance animations ────────────────────────────────────

    // 1. Subtitle eyebrow
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _subtitleController.forward();
    });

    // 2. Title
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) _textController.forward();
    });

    // 3. Pills + CTA
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ctaOpacity = CurvedAnimation(
      parent: _ctaController,
      curve: Curves.easeOut,
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctaController, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted) _ctaController.forward();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    _ctaController.dispose();
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
      height: 420 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video ───────────────────────────────────────────────────────
          _videoInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                )
              : Container(color: Colors.black),

          // ── Deep cinematic gradient ─────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.30, 0.60, 1.0],
                colors: [
                  Colors.black.withOpacity(0.50),
                  Colors.transparent,
                  Colors.black.withOpacity(0.40),
                  Colors.black.withOpacity(0.92),
                ],
              ),
            ),
          ),

          // ── Horizontal vignette ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.30),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.20),
                ],
                stops: const [0.0, 0.28, 0.72, 1.0],
              ),
            ),
          ),

          // ── Curved bottom clip ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _BottomCurveClipper(),
              child: Container(height: 56, color: AppColor.cardBackground),
            ),
          ),

          // ── Top bar ─────────────────────────────────────────────────────
          Positioned(
            top: topPad + 18,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _GlassContainer(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  borderRadius: 16,
                  child: widget.logoUrl.isNotEmpty
                      ? Image.network(
                          widget.logoUrl,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.hotel_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : const Icon(Icons.hotel_rounded,
                          color: Colors.white, size: 24),
                ),

                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse('https://agent.revchilltech.com/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.secondary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.secondary.withOpacity(0.50),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.login_rounded,
                            color: Colors.white, size: 13),
                        SizedBox(width: 6),
                        Text(
                          'Partner Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom content ───────────────────────────────────────────────
          Positioned(
            bottom: 64,
            left: 26,
            right: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Eyebrow — flanked by thin lines for luxury feel
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 1,
                        color: AppColor.secondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        (widget.bannerData['subtitle'] ?? '')
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                          color: AppColor.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 28,
                        height: 1,
                        color: AppColor.secondary.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Title — large & confident
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      widget.bannerData['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Pills + CTA
                SlideTransition(
                  position: _ctaSlide,
                  child: FadeTransition(
                    opacity: _ctaOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Highlights — horizontally scrollable row
                        if (widget.highlights != null &&
                            widget.highlights!.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children:
                                  widget.highlights!.take(5).map((h) {
                                final label = h['label'] as String? ?? '';
                                final iconName = h['icon'] as String? ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _GlassContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 7),
                                    borderRadius: 22,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _resolveIcon(iconName),
                                          size: 12,
                                          color: AppColor.secondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 22),

                        // CTA row
                        Row(
                          children: [
                            // Primary
                            GestureDetector(
                              onTap: () => Get.toNamed(
                                widget.bannerData['cta']?['route'] ?? '/',
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColor.secondary,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColor.secondary.withOpacity(0.50),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.bannerData['cta']?['label'] ??
                                          'Book Now',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            
                          ],
                        ),
                      ],
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

// ── Frosted-glass container ───────────────────────────────────────────────────

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const _GlassContainer({
    required this.child,
    required this.padding,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ── Curved bottom clipper ─────────────────────────────────────────────────────

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