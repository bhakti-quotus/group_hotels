import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/ui/bottom_navbar/bottom_navbar.dart';
import 'package:group/ui/home_screen/home_screen.dart';
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

  void _onNavTap(int index) {
    if (index != _currentIndex && index < _navItems.length) {
      Get.offNamed(_navItems[index].route);
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
          onPressed: () => Get.toNamed(AppRoutes.hotels),
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
