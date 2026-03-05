import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? splashImage;

  // Sample image URLs - replace with your actual images
  final List<String> images = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=200&h=200&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandingColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Rotating Images Circle
            SizedBox(
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating images
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: List.generate(images.length, (index) {
                          final angle =
                              (2 * math.pi / images.length) * index +
                              (_controller.value * 2 * math.pi);
                          final radius = 120.0;
                          final x = radius * math.cos(angle);
                          final y = radius * math.sin(angle);

                          return Transform.translate(
                            offset: Offset(x, y),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  // Splash image in the center
                  if (splashImage != null)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          splashImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No stress, just travel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      fontFamily: BrandingColors.fontFamily,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find the perfect place to relax for a couple of taps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[800],
                      height: 1.2,
                      fontFamily: BrandingColors.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 60), // Bottom spacing
          ],
        ),
      ),
    );
  }
}
