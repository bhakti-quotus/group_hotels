import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/api_controller.dart';
import 'package:royalcontinent/group/controllers/auth_controller.dart';
import 'package:royalcontinent/group/controllers/chat_controller.dart';
import 'package:royalcontinent/group/controllers/hotel_controller.dart';
import 'package:royalcontinent/group/controllers/search_controller.dart' as search_ctrl;
import 'package:royalcontinent/group/models/booking_model.dart';
import 'package:royalcontinent/group/models/chat_message.dart';
import 'package:royalcontinent/group/services/hive_service.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    await Hive.initFlutter();

    // Register ALL adapters here - once at startup
    Hive.registerAdapter(BookingModelAdapter());
    Hive.registerAdapter(GuestAdapter());
    Hive.registerAdapter(ChatMessageAdapter());

   // print('Hive adapters registered globally');

    // Hive first — most foundational
    final hiveService = HiveService();
    await hiveService.init();
    Get.put(hiveService, permanent: true);

    Get.put(AuthController());
    Get.put(HotelController());
    Get.put(search_ctrl.AppSearchController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(ApiController(), permanent: true);
    runApp(const MyApp());
  } catch (e) {
    //print('Failed to initialize app: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Init failed: $e'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'royalcontinent',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
