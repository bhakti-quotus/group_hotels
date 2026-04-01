import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:sunswept/group/common/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;

  late Animation<double> _bgFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _dividerExpand;
  late Animation<double> _nameFade;
  late Animation<double> _nameSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _taglineSlide;
  late Animation<double> _bottomFade;

  String? splashImage;

  static const Color primaryBlue = Color(0xFF27408D);
  static const Color lightBlue = Color(0xFF3D5BA8);
  static const Color accentSun = Color(0xFFE8A020);
  static const Color bgWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _bgFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.05, 0.50, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
    );

    _dividerExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.45, 0.65, curve: Curves.easeOut),
      ),
    );

    _nameFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
    );

    _nameSlide = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.70, 0.90, curve: Curves.easeOut),
    );

    _taglineSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.70, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _bottomFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
    );

    _masterController.forward();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    await BrandingColors.loadBrandingColors();
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final data = json.decode(response);
      BrandingColors.loadFromConfig(data['config']);
      setState(() {
        splashImage = data['config']['branding']['logo'];
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgWhite,
      body: AnimatedBuilder(
        animation: _masterController,
        builder: (context, _) {
          return Stack(
            children: [
              // Gradient background
              Positioned.fill(
                child: Opacity(
                  opacity: _bgFade.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.50, 1.0],
                        colors: [
                          Color(0xFFDDE5F5),
                          Color(0xFFF2F5FB),
                          bgWhite,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sun rays
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _bgFade.value * 0.7,
                  child: CustomPaint(
                    size: Size(size.width, size.height * 0.52),
                    painter: _SunRayPainter(color: primaryBlue),
                  ),
                ),
              ),

              // Top arch band
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _bgFade.value,
                  child: CustomPaint(
                    size: Size(size.width, size.height * 0.44),
                    painter: _TopArchPainter(color: primaryBlue),
                  ),
                ),
              ),

              // Bottom waves
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _bottomFade.value,
                  child: CustomPaint(
                    size: Size(size.width, 110),
                    painter: _BottomWavePainter(color: primaryBlue),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Logo — upper half
                    SizedBox(
                      height: size.height * 0.50,
                      child: Center(child: _buildLogo()),
                    ),

                    // Lower content
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDivider(),
                          const SizedBox(height: 26),
                          _buildBrandName(),
                          const SizedBox(height: 18),
                          _buildTagline(),
                        ],
                      ),
                    ),

                   
                    const SizedBox(height: 38),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Transform.scale(
      scale: _logoScale.value,
      child: Opacity(
        opacity: _logoFade.value,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outermost halo ring (translucent)
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.55),
                  width: 1.5,
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryBlue.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            // Main logo circle
            Container(
              width: 184,
              height: 184,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.14),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.95),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(26),
              child: Image.network(
                splashImage ??
                    'https://www.sunsweptresorts.com/wp-content/uploads/2024/02/SunSwept-Resorts-Logo-01-2.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildFallbackLogo(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return ClipRect(
      child: Align(
        widthFactor: _dividerExpand.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 0.75,
              color: primaryBlue.withOpacity(0.22),
            ),
            const SizedBox(width: 10),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: accentSun,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryBlue.withOpacity(0.25),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: accentSun,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 52,
              height: 0.75,
              color: primaryBlue.withOpacity(0.22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandName() {
    return Opacity(
      opacity: _nameFade.value,
      child: Transform.translate(
        offset: Offset(0, _nameSlide.value),
        child: Column(
          children: [
            Text(
              'SUNSWEPT',
              style: TextStyle(
                fontSize: 31,
                letterSpacing: 10,
                color: primaryBlue,
                fontWeight: FontWeight.w700,
                fontFamily: BrandingColors.fontFamily,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'R E S O R T S',
              style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 4.5,
                color: lightBlue.withOpacity(0.55),
                fontWeight: FontWeight.w400,
                fontFamily: BrandingColors.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Opacity(
      opacity: _taglineFade.value,
      child: Transform.translate(
        offset: Offset(0, _taglineSlide.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: Text(
            'Where every horizon\nfeels like home.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.85,
              color: primaryBlue.withOpacity(0.40),
              fontWeight: FontWeight.w300,
              letterSpacing: 0.2,
              fontStyle: FontStyle.italic,
              fontFamily: BrandingColors.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Opacity(
      opacity: _bottomFade.value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == 0 ? 22 : 5,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: i == 0
                  ? primaryBlue.withOpacity(0.45)
                  : primaryBlue.withOpacity(0.13),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Text(
        'SR',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w200,
          letterSpacing: 8,
          color: primaryBlue,
          fontFamily: BrandingColors.fontFamily,
        ),
      ),
    );
  }
}

/// Radiating sun rays from upper-center
class _SunRayPainter extends CustomPainter {
  final Color color;
  const _SunRayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.08);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.04);

    const totalRays = 16;
    const sweep = math.pi / totalRays;

    for (int i = 0; i < totalRays; i++) {
      if (i.isEven) continue;
      final angle =
          sweep * i - math.pi * 0.5 - math.pi * 0.44;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: size.height * 1.3),
          angle,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SunRayPainter old) => false;
}

/// Soft blue arch at the top, curving down with a smooth bottom edge
class _TopArchPainter extends CustomPainter {
  final Color color;
  const _TopArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.10),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.78)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 1.06,
        0,
        size.height * 0.78,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Two layered ocean waves at the bottom
class _BottomWavePainter extends CustomPainter {
  final Color color;
  const _BottomWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Back wave
    final p1 = Paint()
      ..color = color.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.48)
      ..cubicTo(
        size.width * 0.26, size.height * 0.08,
        size.width * 0.56, size.height * 0.88,
        size.width, size.height * 0.32,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, p1);

    // Front wave
    final p2 = Paint()
      ..color = color.withOpacity(0.045)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.68)
      ..cubicTo(
        size.width * 0.33, size.height * 0.30,
        size.width * 0.66, size.height * 0.96,
        size.width, size.height * 0.52,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}