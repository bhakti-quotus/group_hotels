import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/utils/app_routes.dart';

class GroupWebRoomChildSplashPage extends StatefulWidget {
  const GroupWebRoomChildSplashPage({super.key});

  @override
  State<GroupWebRoomChildSplashPage> createState() =>
      _GroupWebRoomChildSplashPageState();
}

class _GroupWebRoomChildSplashPageState extends State<GroupWebRoomChildSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoSlide;
  late Animation<double> _logoFade;

  // Each line of the tagline gets its own fade+slide animation
  late List<Animation<double>> _lineFades;
  late List<Animation<double>> _lineSlides;

  final List<String> _taglines = [
    'Give us your Body for a Week',
    "and we'll give you back",
    'your Mind',
  ];

  @override
  void initState() {
    super.initState();

    // ── Logo animation: slides down from slightly above, fades in ──────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoSlide = Tween<double>(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // ── Text animation: each line fades + slides in staggered ──────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Stagger each line across the total duration
    _lineFades = List.generate(_taglines.length, (i) {
      final start = 0.15 * i;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _textController,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );
    });

    _lineSlides = List.generate(_taglines.length, (i) {
      final start = 0.15 * i;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _textController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    // ── Start sequence ─────────────────────────────────────────────────
    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _textController.forward();
      });
    });

    // ── Navigation timer ───────────────────────────────────────────────
    Timer(const Duration(milliseconds: 150000), () {
      final args = Get.arguments;
      if (args != null && args is Map<String, dynamic>) {
        Get.offNamed(AppRoutes.webroomChildMain, arguments: args);
      } else {
        Get.offNamed(AppRoutes.groupHome);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final logoUrl =
        (args as Map<String, dynamic>?)?['config']?['branding']?['logo']
            as String?;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────────
          Image.asset(
            'assets/images/splash-bg.jpg',
            fit: BoxFit.cover,
          ),

          // ── Gradient overlay ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black26,
                  Colors.black38,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Animated content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),

                // ── Animated logo ───────────────────────────────────────
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _logoSlide.value),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: logoUrl != null && logoUrl.isNotEmpty
                        ? Image.network(
                            logoUrl,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/hotel_logo.png',
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/images/hotel_logo.png',
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),

                // ── Animated tagline lines ──────────────────────────────
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_taglines.length, (i) {
                      return AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _lineFades[i].value,
                            child: Transform.translate(
                              offset: Offset(0, _lineSlides[i].value),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _taglines[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}