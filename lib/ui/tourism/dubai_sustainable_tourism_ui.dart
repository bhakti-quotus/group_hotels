import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class AppColors {
  static const darkGreen    = Color(0xFF1B5E20);
  static const mediumGreen  = Color(0xFF2E7D32);
  static const lightGreen   = Color(0xFF4CAF50);
  static const paleGreen    = Color(0xFFE8F5E9);
  static const accentGreen  = Color(0xFF66BB6A);
  static const gold         = Color(0xFFFFCA28);
  static const white        = Color(0xFFFFFFFF);
  static const offWhite     = Color(0xFFF9FBF9);
  static const textDark     = Color(0xFF1A2E1A);
  static const textMid      = Color(0xFF3D5A3D);
  static const textLight    = Color(0xFF6A8F6A);
}

// ─── Dubai Sustainable Tourism Page ───────────────────────────────────────────
class DubaiSustainableTourismPage extends StatelessWidget {
  const DubaiSustainableTourismPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible App Bar with Background Image ─────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 16,
                    top: 60,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Background Image
                  Image.network(
                    'https://royalcontinentalhotels.com/wp-content/uploads/2024/04/dubai-skyline-downtown-skyscrapers-sunset-modern-architecture-concept-with-highrise-buildings-world-famous-metropolis-united-arab-emirates.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.darkGreen, AppColors.mediumGreen],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                        ),
                      );
                    },
                  ),
                  // Dark overlay for text readability
                  Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  // Decorative blobs
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 180, height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightGreen.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20, left: -20,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGreen.withOpacity(0.12),
                      ),
                    ),
                  ),
                  // Header text
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🌿  AT HORIZON BAY RESORT BANGALORE',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 9,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Dubai Sustainable\nTourism',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Horizon Bay Resort interweaves sustainability\nthroughout the complete customer experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.75),
                            fontSize: 11.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: const [
                _MissionSection(),
                _ClimateVideoSection(),
                _PolicySection(),
                _PillarsSection(),
                _CertificateCarouselSection(),
                _WhoWeAreSection(),
                _ComplianceSection(),
                _SustainabilityImageSection(),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mission Section ──────────────────────────────────────────────────────────
class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.house, color: AppColors.darkGreen, size: 28),
          ),
          const SizedBox(height: 22),
          const Text(
            'We are committed to preserving and regenerating the environment and leaving a positive, enduring impact on our local community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.paleGreen, thickness: 2),
          const SizedBox(height: 20),
          Text(
            'Dubai Sustainable Tourism was born to improve the sustainability of the tourism sector and to contribute to the broader clean energy and sustainable development targets that Dubai has set out to achieve.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 13, height: 1.65),
          ),
          const SizedBox(height: 14),
          Text(
            'If you are looking for a Luxury Business 4-star hotel near Bangalore International Airport, near to Bangalore City Centre, near to Bangalore Metro, Horizon Bay Resort is the best option for you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Climate Action Video Section ────────────────────────────────────────────
enum _VideoSource { asset, network }

class _ClimateVideoSection extends StatefulWidget {
  const _ClimateVideoSection();

  @override
  State<_ClimateVideoSection> createState() => _ClimateVideoSectionState();
}

class _ClimateVideoSectionState extends State<_ClimateVideoSection> {
  static const _videoSource = _VideoSource.network;
  static const _videoUrl    = 'https://royalcontinentalhotels.com/Untitled-design.mp4';

  VideoPlayerController? _vpc;
  ChewieController?      _cc;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _vpc = _videoSource == _VideoSource.asset
          ? VideoPlayerController.asset(_videoUrl)
          : VideoPlayerController.networkUrl(Uri.parse(_videoUrl));

      await _vpc!.initialize();

      _cc = ChewieController(
        videoPlayerController: _vpc!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor:    AppColors.lightGreen,
          handleColor:    AppColors.accentGreen,
          bufferedColor:  AppColors.paleGreen,
          backgroundColor: AppColors.darkGreen.withOpacity(0.3),
        ),
        placeholder: Container(
          color: AppColors.darkGreen,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.lightGreen),
          ),
        ),
      );

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) setState(() { _error = true; });
    }
  }

  @override
  void dispose() {
    _cc?.dispose();
    _vpc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _ready && !_error
              ? Chewie(controller: _cc!)
              : const _Placeholder(showError: false),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool showError;
  const _Placeholder({required this.showError});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D3B0D), Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGreen.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -20, bottom: -20,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.4), width: 2,
                    ),
                  ),
                  child: Icon(
                    showError ? Icons.videocam_off : Icons.play_arrow,
                    color: AppColors.white, size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  showError
                      ? 'Unable to load video'
                      : 'Loading video…',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.6),
                    fontSize: 11,
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

// ─── Policy Section ───────────────────────────────────────────────────────────
class _PolicySection extends StatelessWidget {
  const _PolicySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 2, color: AppColors.lightGreen.withOpacity(0.5)),
              const SizedBox(width: 10),
              const Icon(Icons.eco, color: AppColors.mediumGreen, size: 20),
              const SizedBox(width: 10),
              Container(width: 40, height: 2, color: AppColors.lightGreen.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sustainability Management Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Horizon Bay Resort strive to be a sustainable organization, sustaining the natural environment on which our business operations depend, and considering long-term environmental and social impacts of all the projects and operations for which we are responsible.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 13, height: 1.7),
          ),
          const SizedBox(height: 14),
          Text(
            'To achieve this vision, Horizon Bay Resort will implement a sustainability strategy to demonstrate a positive economic, environmental and social impact from all our activities as per the part of DST initiation by DTCM.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 13, height: 1.7),
          ),
        ],
      ),
    );
  }
}

// ─── 4 Pillars Section ────────────────────────────────────────────────────────
class _PillarsSection extends StatelessWidget {
  const _PillarsSection();

  static const _pillars = [
    _Pillar(Icons.bolt,             'Energy Saving',    Color(0xFF1B5E20),
        'Implement a systematic energy efficiency plan and continually improve energy efficiency performance. Control energy use with BMS and BEMS systems to optimize energy use.'),
    _Pillar(Icons.delete_outline,   'Waste Reduction',  Color(0xFF2E7D32),
        'Implement a systematic waste management plan to minimize disposal to landfill and food waste, encourage recycling, and encourage reuse of materials.'),
    _Pillar(Icons.water_drop_outlined,'Water Saving',   Color(0xFF388E3C),
        'Implement a systematic water conservation plan. Strive to reduce water consumption by reusing guest towels and linens.'),
    _Pillar(Icons.shopping_bag_outlined,'Purchasing',   Color(0xFF43A047),
        'Implement a purchasing management plan giving preference to sustainable, local, fair trade and environmentally friendly goods. Only purchase food free from endangered or protected fish.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paleGreen,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: _pillars.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _PillarCard(pillar: p),
        )).toList(),
      ),
    );
  }
}

class _Pillar {
  final IconData icon;
  final String title;
  final Color color;
  final String desc;
  const _Pillar(this.icon, this.title, this.color, this.desc);
}

class _PillarCard extends StatelessWidget {
  final _Pillar pillar;
  const _PillarCard({required this.pillar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.07),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: pillar.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(pillar.icon, color: AppColors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pillar.title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(pillar.desc,
                    style: const TextStyle(color: Colors.black, fontSize: 12.5, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Certificate Carousel Section (Using PageView instead of carousel_slider) ──
class _CertificateCarouselSection extends StatefulWidget {
  const _CertificateCarouselSection();

  @override
  State<_CertificateCarouselSection> createState() => _CertificateCarouselSectionState();
}

class _CertificateCarouselSectionState extends State<_CertificateCarouselSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Certificate image URLs
  static const List<String> _certificateImages = [
    'https://royalcontinentalhotels.com/wp-content/uploads/2024/04/members-1-768x538.jpg',
    'https://royalcontinentalhotels.com/wp-content/uploads/2024/04/Royal-Continental-Certificate-768x538.jpg'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          const Text(
            'Our Recognitions',
            style: TextStyle(
              color: AppColors.darkGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
                            color: AppColors.gold.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _certificateImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.lightGreen,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.paleGreen,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: AppColors.textLight,
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
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.darkGreen
                              : AppColors.textLight.withOpacity(0.5),
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

// ─── "Who We Are" Section with Background Image ─────────────────────────────────
class _WhoWeAreSection extends StatelessWidget {
  const _WhoWeAreSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://royalcontinentalhotels.com/wp-content/uploads/2024/04/adobestock_101323211.jpeg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.3),
              AppColors.darkGreen.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.12),
                border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.nature, color: AppColors.white, size: 32),
            ),
            const SizedBox(height: 22),
            const Text(
              'Sustainable is not something that we do;\nit is who we are',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Divider(color: AppColors.white.withOpacity(0.2)),
            const SizedBox(height: 18),
            Text(
              'For us, being environmentally friendly and socially responsible can be successfully wedded to uncompromisingly gorgeous hideaways. Empty of waste, toxins and plastic, and full of spirituality, celebration and joy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 13.5, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Compliance Section ───────────────────────────────────────────────────────
class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection();

  static const _items = [
    'Report environment performance through the DST Carbon Calculator on a regular frequency, preferably monthly.',
    'Comply with all Dubai Sustainable Tourism and Dubai Supreme Council of Energy regulations, guidelines and directives.',
    'Certify staff by Dubai Tourism and establish a committee to manage sustainability initiatives.',
    'Train employees and educate guests on sustainability initiatives.',
    'Produce events, conferences and business meetings that minimize waste and conserve energy and water.',
    'Implement a sustainable friendly procurement procedure with support of approved vendors.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Compliance, Staffing\n& Training',
                style: TextStyle(
                  color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.lightGreen, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item,
                      style: const TextStyle(color: Colors.black, fontSize: 13, height: 1.6)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Sustainability Image Section (Single Image) ─────────────────────────────
class _SustainabilityImageSection extends StatelessWidget {
  const _SustainabilityImageSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Image.network(
        'https://royalcontinentalhotels.com/wp-content/uploads/2024/06/sustainibility-1920x899.jpg',
        fit: BoxFit.cover,
        height: 300,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.lightGreen),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: AppColors.paleGreen,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 50, color: AppColors.textLight),
                  SizedBox(height: 10),
                  Text('Sustainability Image', style: TextStyle(color: AppColors.textMid)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          const Icon(Icons.eco, color: AppColors.accentGreen, size: 32),
          const SizedBox(height: 14),
          const Text('Horizon Bay Resort Bangalore',
              style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Committed to a Sustainable Future',
              style: TextStyle(color: AppColors.white.withOpacity(0.65), fontSize: 12, letterSpacing: 0.5)),
          const SizedBox(height: 20),
          Divider(color: AppColors.white.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(
            '© 2024 Horizon Bay Resort Bangalore.\nAll rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white.withOpacity(0.4), fontSize: 11, height: 1.6),
          ),
        ],
      ),
    );
  }
}