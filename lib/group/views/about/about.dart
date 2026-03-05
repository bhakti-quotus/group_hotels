import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/ui/about_screen/about_screen.dart';
import 'package:get/get.dart';
import 'package:group/ui/bottom_navbar/bottom_navbar.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  int _currentIndex = 0;
  List<BottomNavItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _loadNavItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNavItems();
  }

  Future<void> _loadNavItems() async {
    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final items = await BottomNavItemManager.getNavItems(config: config);
    setState(() {
      _navItems = items;
      _currentIndex = _navItems.indexWhere((item) => item.route == '/about');
      if (_currentIndex == -1) _currentIndex = 0;
    });
  }

  void _onNavTap(int index) {
    if (index != _currentIndex && index < _navItems.length) {
      Get.offAllNamed(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_navItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final branding =
        config?['branding'] as Map<String, dynamic>? ??
        config?['config']?['branding'] as Map<String, dynamic>? ??
        {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;
    final fontFamily = branding['fontFamily'] as String? ?? 'Inter';

    return Theme(
      data: ThemeData(fontFamily: fontFamily),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: AboutScreen(),
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
