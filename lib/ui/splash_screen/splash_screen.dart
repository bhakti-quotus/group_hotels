import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  String? splashImage;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _loadMockData();
  }

  Future<void> _loadMockData() async {
    await BrandingColors.loadBrandingColors();
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final data = json.decode(response);
      BrandingColors.loadFromConfig(data['config']);
      setState(() {
        splashImage = data['config']['branding']['splashImage'];
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Ambient radial glow behind logo
              Positioned(
                top: MediaQuery.of(context).size.height * 0.2,
                left: MediaQuery.of(context).size.width / 2 - 140,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC9A96E).withOpacity(0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Corner brackets
              _buildCornerBracket(top: 16, left: 16, flipH: false, flipV: false),
              _buildCornerBracket(top: 16, right: 16, flipH: true, flipV: false),
              _buildCornerBracket(bottom: 16, left: 16, flipH: false, flipV: true),
              _buildCornerBracket(bottom: 16, right: 16, flipH: true, flipV: true),

              Column(
                children: [
                  // Top ornament
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 28, height: 0.5, color: const Color(0xFFC9A96E).withOpacity(0.6)),
                        const SizedBox(width: 10),
                        Row(
                          children: List.generate(3, (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFC9A96E).withOpacity(0.6),
                            ),
                          )),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 28, height: 0.5, color: const Color(0xFFC9A96E).withOpacity(0.6)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Double ring logo
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC9A96E).withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC9A96E).withOpacity(0.12),
                            width: 0.5,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x10C9A96E),
                          ),
                          child: Center(
                            child: splashImage != null
                                ? Image.network(
                                    splashImage!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const SizedBox.shrink(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Text section
                  AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        children: [
                          // Diamond divider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 28, height: 0.5, color: const Color(0xFFC9A96E).withOpacity(0.45)),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9A96E).withOpacity(0.8),
                                  borderRadius: BorderRadius.zero,
                                ),
                                transform: Matrix4.rotationZ(0.785398),
                                transformAlignment: Alignment.center,
                              ),
                              Container(width: 28, height: 0.5, color: const Color(0xFFC9A96E).withOpacity(0.45)),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Hotel name
                          Text(
                            'SIGNATURE HOTELS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 7,
                              color: const Color(0xFFC9A96E),
                              fontWeight: FontWeight.w400,
                              fontFamily: BrandingColors.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tagline
                          Text(
                            'Where every stay becomes\na cherished memory.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.45),
                              fontWeight: FontWeight.w300,
                              fontFamily: BrandingColors.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Loading indicator
                  Column(
                    children: [
                      SizedBox(
                        width: 40,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.2, end: 0.8),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 2,
                              backgroundColor: Colors.white.withOpacity(0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFC9A96E).withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'LOADING',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 3,
                          color: Colors.white.withOpacity(0.2),
                          fontWeight: FontWeight.w300,
                          fontFamily: BrandingColors.fontFamily,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool flipH,
    required bool flipV,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(flipH ? -1.0 : 1.0, flipV ? -1.0 : 1.0),
        child: SizedBox(
          width: 12,
          height: 12,
          child: CustomPaint(painter: _CornerBracketPainter()),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9A96E).withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}