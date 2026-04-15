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
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Top brand line
              Padding(
                padding: const EdgeInsets.only(top: 36, left: 32, right: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 1,
                      color: const Color(0xFFC9A96E).withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'EST. 2017',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 4,
                        color: const Color(0xFFC9A96E).withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        fontFamily: BrandingColors.fontFamily,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 30,
                      height: 1,
                      color: const Color(0xFFC9A96E).withOpacity(0.6),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Center logo only — no border, just a soft glow
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC9A96E).withOpacity(0.12),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: splashImage != null
                    ? Image.network(
                        splashImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultLogo(),
                      )
                    : _buildDefaultLogo(),
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
                      // Gold divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 1,
                            color: const Color(0xFFC9A96E).withOpacity(0.5),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFC9A96E),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 1,
                            color: const Color(0xFFC9A96E).withOpacity(0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Hotel name
                      Text(
                        'ROYAL CONTINENTAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 6,
                          color: const Color(0xFFC9A96E),
                          fontWeight: FontWeight.w600,
                          fontFamily: BrandingColors.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HOTELS & SUITES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 5,
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                          fontFamily: BrandingColors.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tagline
                      Text(
                        'Where every stay becomes\na cherished memory.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w300,
                          fontFamily: BrandingColors.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1A1A1A),
      ),
      child: Center(
        child: Text(
          'RC',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 3,
            color: const Color(0xFFC9A96E),
            fontFamily: BrandingColors.fontFamily,
          ),
        ),
      ),
    );
  }
}
