import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:group/group/controllers/auth_controller.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  Get.put(HotelController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'group',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
