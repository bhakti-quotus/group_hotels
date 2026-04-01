import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/ui/bottom_navbar/bottom_navbar.dart';
import 'package:sunswept/ui/home_screen/home_screen.dart';
import 'package:get/get.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';
import '../../utils/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<BottomNavItem> _navItems = [];
  Map<String, dynamic> config = {};

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      Get.find<HotelController>().setConfig(args);
    }
    config = Get.find<HotelController>().getConfig() ?? {};
    BrandingColors.loadFromConfig(config);
    _loadNavItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      Get.find<HotelController>().setConfig(args);
    }
    config = Get.find<HotelController>().getConfig() ?? {};
    BrandingColors.loadFromConfig(config);
    _loadNavItems();
  }

  Future<void> _loadNavItems() async {
    final items = await BottomNavItemManager.getNavItems(config: config);
    setState(() {
      _navItems = items;
      _currentIndex = _navItems.indexWhere((item) => item.route == '/home');
      if (_currentIndex == -1) _currentIndex = 0;
    });
  }

  String _getPropertyCode() {
    final hotelCtrl = Get.find<HotelController>();
    return hotelCtrl.getConfig()?['code'] as String? ??
        hotelCtrl.getSelectedHotel()?['code'] as String? ??
        '';
  }

  void _onNavTap(int index) {
    if (index != _currentIndex && index < _navItems.length) {
      final route = _navItems[index].route;
      if (route == '/bookingdetails') {
        final propertyCode = _getPropertyCode();
        Get.offNamed(route, arguments: {'propertyCode': propertyCode});
      } else {
        Get.offNamed(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_navItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final branding = config['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;
    final fontFamily = branding['fontFamily'] as String? ?? 'Inter';

    return Theme(
      data: ThemeData(fontFamily: fontFamily),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: HomeScreen(config: config),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final hotelCtrl = Get.find<HotelController>();
            final isChildHotel = hotelCtrl.hasSelectedHotel();
            final hasChildHotels = hotelCtrl.hasChildHotels();

            if (isChildHotel) {
              // Back to full child list
              hotelCtrl.clearSelectedHotel();
              final root = hotelCtrl.getRootConfig();
              if (root != null) {
                hotelCtrl.setConfig(root, isRoot: true);
                Get.offNamed(AppRoutes.groupHotels, arguments: root);
                return;
              }
            }

            final targetRoute = hasChildHotels
                ? AppRoutes.groupHotels
                : AppRoutes.hotels;
            Get.offNamed(targetRoute);
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.list, color: Colors.white),
        ),

        bottomNavigationBar: BottomNavbar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          items: _navItems,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}
