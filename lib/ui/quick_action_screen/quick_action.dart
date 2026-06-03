// lib/ui/quick_action_page/quick_action_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/hotel_controller.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';
import '../../group/common/theme/theme.dart';

class QuickActionPage extends StatefulWidget {
  const QuickActionPage({super.key});

  @override
  State<QuickActionPage> createState() => _QuickActionPageState();
}

class _QuickActionPageState extends State<QuickActionPage> {
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
              delegate: _CollapsibleHeaderDelegate(
                expandedHeight: 190,
                collapsedHeight: 80,
                builder: (t) => _buildHeader(context, t),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // This spacer ensures content starts below the collapsed header
              const SizedBox(height: 10), // Matches collapsedHeight
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _getQuickActions().length,
                  itemBuilder: (context, index) {
                    final action = _getQuickActions()[index];
                    return _QuickActionCard(
                      icon: action['icon'] as IconData,
                      label: action['label'] as String,
                      subtitle: action['subtitle'] as String,
                      accentColor: action['accentColor'] as Color,
                      imageUrl: action['imageUrl'] as String,
                      onTap: () =>
                          _handleNavigation(action['route'] as String?),
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
    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final branding =
        config?['branding'] as Map<String, dynamic>? ??
        config?['config']?['branding'] as Map<String, dynamic>? ??
        {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    final double verticalPadding = lerpDouble(24, 28, t)!;
    final double bottomPadding = lerpDouble(2, 0, t)!;
    final double titleFontSize = lerpDouble(30, 20, t)!;
    final double dividerOpacity = lerpDouble(1.0, 0.0, t)!;
    final double subtitleOpacity = lerpDouble(0.65, 0.0, t)!;
    final double brandRowOpacity = lerpDouble(1.0, 0.0, t)!;
    final double brandRowHeight = lerpDouble(46, 0, t)!;

    return Container(
      padding: EdgeInsets.fromLTRB(20, verticalPadding, 20, bottomPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A2E5C),
            primaryColor,
            const Color(0xFF1A6ABF),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
                width: 180,
                height: 180,
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
                width: 120,
                height: 120,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand row
                        SizedBox(
                          height: brandRowHeight,
                          child: Opacity(
                            opacity: brandRowOpacity.clamp(0.0, 1.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0x26FFD700),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0x4DFFD700),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium,
                                    color: Color(0xFFAD9064),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'STELLA DI MARE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFAD9064),
                                    letterSpacing: 2.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        if (subtitleOpacity > 0) ...[
                          const SizedBox(height: 5),
                          Opacity(
                            opacity: subtitleOpacity.clamp(0.0, 1.0),
                            child: Text(
                              'Explore what we offer',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.65),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38,
                      height: 38,
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
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              // Gold shimmer divider
              if (dividerOpacity > 0) ...[
                const SizedBox(height: 10),
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

  // ─── DATA ──────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _getQuickActions() {
    return [
      {
        'icon': Icons.pool_outlined,
        'label': 'Facilities &\nActivities',
        'subtitle': 'Amenities & services',
        'accentColor': const Color(0xFF0D5399),
        'imageUrl':
            'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',
        'route': '/qa-facilities',
      },
      {
        'icon': Icons.favorite_border,
        'label': 'Weddings',
        'subtitle': 'Plan your dream day',
        'accentColor': const Color(0xFFD67816),
        'imageUrl':
            'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400&q=80',
        'route': '/qa-weddings',
      },
      {
        'icon': Icons.restaurant_outlined,
        'label': 'Dining',
        'subtitle': 'Culinary experiences',
        'accentColor': const Color(0xFF800080),
        'imageUrl':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
        'route': '/qa-dinning',
      },
      {
        'icon': Icons.local_offer_outlined,
        'label': 'Offers',
        'subtitle': 'Special promotions',
        'accentColor': const Color(0xFFC2185B),
        'imageUrl':
            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&q=80',
        'route': '/qa-offers',
      },
      {
        'icon': Icons.photo_library_outlined,
        'label': 'Gallery',
        'subtitle': 'Moments captured',
        'accentColor': const Color(0xFF1565C0),
        'imageUrl':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
        'route': '/qa-gallery',
      },
      {
        'icon': Icons.eco_outlined,
        'label': 'Sustainability',
        'subtitle': 'Eco-friendly stays',
        'accentColor': const Color(0xFF1B5E20),
        'imageUrl':
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&q=80',
        'route': '/tourism',
      },
      {
        'icon': Icons.article_outlined,
        'label': 'Blog',
        'subtitle': 'Latest stories',
        'accentColor': const Color(0xFF7B1FA2),
        'imageUrl':
            'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80',
        'route': '/qa-blog',
      },
      {
        'icon': Icons.help_outline,
        'label': 'FAQ',
        'subtitle': 'Common questions',
        'accentColor': const Color(0xFF455A64),
        'imageUrl':
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&q=80',
        'route': '/qa-faq',
      },
    ];
  }

  // ─── NAVIGATION ────────────────────────────────────────────────────────────

  void _handleNavigation(String? route) {
    if (route != null && route.isNotEmpty) {
      switch (route) {
        case '/qa-facilities':
          Get.toNamed(AppRoutes.qafacilities);
          break;
        case '/qa-weddings':
          Get.toNamed(AppRoutes.qaweddings);
          break;
        case '/qa-gallery':
          Get.toNamed(AppRoutes.qagallery);
          break;
        case '/qa-blog':
          Get.toNamed(AppRoutes.qablog);
          break;
        case '/promotions':
          Get.toNamed(AppRoutes.promotions);
          break;
        case '/qa-dinning':
          Get.toNamed(AppRoutes.qadinning);
          break;
        case '/qa-offers':
          Get.toNamed(AppRoutes.qaoffers);
          break;
        case '/qa-faq':
          Get.toNamed(AppRoutes.qafaq);
          break;
        case '/tourism':
          Get.toNamed(AppRoutes.tourism);
          break;
        default:
          Get.toNamed(route);
      }
    }
  }
}

// ─── CARD WIDGET ─────────────────────────────────────────────────────────────

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final String imageUrl;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _arrowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: widget.accentColor.withOpacity(0.3)),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: widget.accentColor.withOpacity(0.15),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: widget.accentColor,
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.72),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedBuilder(
                  animation: _arrowAnim,
                  builder: (_, __) => Opacity(
                    opacity: _arrowAnim.value,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.72),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PINNED HEADER DELEGATE ───────────────────────────────────────────────

class _CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _CollapsibleHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_CollapsibleHeaderDelegate oldDelegate) => true;

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
