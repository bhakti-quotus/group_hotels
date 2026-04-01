import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/group/controllers/hotel_controller.dart';
import 'package:sunswept/group/utils/app_routes.dart';
import 'package:sunswept/group/views/webroom/ui/home/webroom_home.dart';
import 'ui/webroom_bottom_navbar.dart';

class GroupWebRoomChildHomePage extends StatelessWidget {
  const GroupWebRoomChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WebroomHome(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.offNamed(AppRoutes.webroom),
        child: const Icon(Icons.arrow_back, size: 20),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        tooltip: 'Back',
      ),
      bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 0),
    );
  }
}