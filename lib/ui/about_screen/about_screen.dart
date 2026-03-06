import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:get/get.dart';
import 'image_grid_widget.dart';
import 'description_widget.dart';
import 'policies_widget.dart';
import 'image_gallery_popup.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> data = {};
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
          ),
        );

    _scrollController.addListener(_onScroll);
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 10;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  void loadData() {
    try {
      final config = Get.find<HotelController>().getConfig();
      if (config != null) {
        setState(() {
          data = config['config'] ?? config;
        });
        _entranceCtrl.forward();
      }
    } catch (e) {
      debugPrint('Error loading about data: $e');

    }
  }

  void _showImageGallery(List<dynamic> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ImageGalleryPopup(images: images, initialIndex: initialIndex),
      ),
    );
  }


  List<Map<String, dynamic>> _buildPolicies(Map<String, dynamic> policiesData) {
    final entries = [
      {'icon': 'login', 'title': 'Check-In', 'key': 'checkIn'},
      {'icon': 'logout', 'title': 'Check-Out', 'key': 'checkOut'},
      {'icon': 'cancel', 'title': 'Cancellation Policy', 'key': 'cancellation'},
      {'icon': 'pets', 'title': 'Pet Policy', 'key': 'petPolicy'},
      {'icon': 'smoke_free', 'title': 'Smoking Policy', 'key': 'smokingPolicy'},
    ];
    return entries
        .where((e) => (policiesData[e['key']] as String? ?? '').isNotEmpty)
        .map(
          (e) => {
            'icon': e['icon']!,
            'title': e['title']!,
            'description': policiesData[e['key']] as String? ?? '',
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.background,
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColor.primary),
          ),
        ),
      );
    }

    final about = data['about'] as Map<String, dynamic>? ?? {};
    final policiesData = data['policies'] as Map<String, dynamic>? ?? {};
    final images = (about['images'] as List<dynamic>?) ?? [];
    final policies = _buildPolicies(policiesData);

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColor.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(

          backgroundColor: _isScrolled ? AppColor.primary : Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: _isScrolled ? AppColor.primary : Colors.transparent,
            statusBarIconBrightness: _isScrolled

                ? Brightness.light
                : Brightness.dark,
          ),
        ),
      ),

      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image grid with overlay header ──────────────────────
            Stack(
              children: [
                // Image grid (full bleed, no top padding)
                if (images.isNotEmpty)
                  ImageGridWidget(images: images, onImageTap: _showImageGallery)
                else
                  // Fallback gradient header when no images
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.primary,
                          AppColor.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Top bar overlay: back button
                Positioned(
                  top: topPad + 12,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // Bottom gradient fade into background
                if (images.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColor.background, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Animated body content ─────────────────────────────────────
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About / description
                      _AboutCard(about: about),

                      const SizedBox(height: 24),

                      // Policies
                      if (policies.isNotEmpty)
                        PoliciesWidget(policies: policies),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── About Card ───────────────────────────────────────────────────────────────

class _AboutCard extends StatefulWidget {
  final Map<String, dynamic> about;
  const _AboutCard({required this.about});

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.about['title'] as String? ?? 'About Us';
    final description = widget.about['description'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold accent + eyebrow
          Row(
            children: [
              Container(width: 16, height: 2, color: AppColor.secondary),
              const SizedBox(width: 6),
              Text(
                'ABOUT US',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondary,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColor.primary,
              letterSpacing: 0.2,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // Gradient divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.secondary.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description with expand
          if (description.isNotEmpty) ...[
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textLight,
                  height: 1.7,
                  letterSpacing: 0.1,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textLight,
                  height: 1.7,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Read more pill
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.secondary.withOpacity(0.6),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'See Less' : 'Read More',
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 280),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColor.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
