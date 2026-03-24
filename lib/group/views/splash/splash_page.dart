import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/ui/splash_screen/splash_screen.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/app_routes.dart';
import '../../controllers/hotel_controller.dart';
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
      Get.find<HotelController>().setConfig(decoded);
     // print('decoded config: $decoded');
      BrandingColors.loadFromConfig(groupConfig);
    } catch (e) {
      print('Error loading config: $e');
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        Get.offNamed(AppRoutes.groupHome);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SplashScreen());
  }
}
