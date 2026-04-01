import 'package:get/get.dart';
import 'package:sunswept/group/utils/app_routes.dart';
import 'group_webroom_page.dart';
import 'group_webroom_child_splash_page.dart';
import 'group_webroom_child_login_page.dart';
import 'group_webroom_child_main_page.dart';
import 'group_webroom_child_home_page.dart';
import 'group_webroom_child_schedule_page.dart';
import 'group_webroom_child_messages_page.dart';
import 'group_webroom_child_reservation_page.dart';
import 'group_webroom_child_profile_page.dart';

class WebroomRoutes {
  static List<GetPage> get pages => [
        GetPage(name: AppRoutes.webroom, page: () => const GroupWebRoomPage()),
        GetPage(name: AppRoutes.webroomChildSplash, page: () => const GroupWebRoomChildSplashPage()),
        GetPage(name: AppRoutes.webroomChildLogin, page: () => const GroupWebRoomChildLoginPage()),
        GetPage(name: AppRoutes.webroomChildMain, page: () => const GroupWebRoomChildMainPage()),
        GetPage(name: AppRoutes.webroomChildHome, page: () => const GroupWebRoomChildHomePage()),
        GetPage(name: AppRoutes.webroomChildSchedule, page: () => const GroupWebRoomChildSchedulePage()),
        GetPage(name: AppRoutes.webroomChildMessages, page: () => const GroupWebRoomChildMessagesPage()),
        GetPage(name: AppRoutes.webroomChildReservation, page: () => const GroupWebRoomChildReservationPage()),
        GetPage(name: AppRoutes.webroomChildProfile, page: () => const GroupWebRoomChildProfilePage()),
      ];
}
