import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:royalcontinent/ui/splash_screen/splash_screen.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../utils/app_routes.dart';
import '../../controllers/hotel_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../common/theme/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final decoded = json.decode(response);
      final groupConfig = decoded['config'] as Map<String, dynamic>? ?? {};
      Get.find<HotelController>().setConfig(decoded, isRoot: true);
      BrandingColors.loadFromConfig(groupConfig);
    } catch (e) {
      // Keep error visible during development; avoid crashing app on bad config
      // ignore: avoid_print
      print('Error loading config: $e');
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        final authCtrl = Get.find<AuthController>();
        // authCtrl.authInitialized is set in AuthController._loadAuthState()
        if (authCtrl.authInitialized.value) {
          Get.offNamed(AppRoutes.groupHome);
        } else {
          // Wait for auth to initialize
          ever(authCtrl.authInitialized, (initialized) {
            if (initialized && mounted) {
              Get.offNamed(AppRoutes.groupHome);
            }
          });
        }
      });
      }}

    @override
    Widget build(BuildContext context) {
      return const SplashScreen();
    }
  }
