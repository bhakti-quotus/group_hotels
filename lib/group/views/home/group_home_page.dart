import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:royalcontinent/ui/bottom_navbar/bottom_navbar.dart';
import 'package:royalcontinent/ui/home_screen/home_screen.dart';
import '../../common/theme/theme.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';
import '../../utils/app_routes.dart';

class GroupHomePage extends StatefulWidget {
  const GroupHomePage({super.key});

  @override
  State<GroupHomePage> createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  Map<String, dynamic> groupData = {};
  int _currentIndex = 0;
  List<BottomNavItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    BrandingColors.resetToDefaults();
    loadGroupData();
  }

  Future<void> loadGroupData() async {
    // Always load group config from assets
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final decoded = json.decode(response);
      Get.find<HotelController>().setConfig(decoded, isRoot: true);
      final groupConfig = decoded['config'] as Map<String, dynamic>? ?? {};
      BrandingColors.loadFromConfig(groupConfig);
      setState(() {
        groupData = decoded;
      });
      await _loadNavItems();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _loadNavItems() async {
    final items = await BottomNavItemManager.getNavItems(config: groupData);
    setState(() {
      _navItems = items;
      _currentIndex = _navItems.indexWhere(
        (item) => item.route == '/grouphome',
      );
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

    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final branding =
        config?['config']?['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;
    final fontFamily = branding['fontFamily'] as String? ?? 'Inter';

    final childHotels = groupData['childHotels'] as List<dynamic>? ?? [];
    final tabs = <String>['All'] + childHotels.map((c) => (c as Map<String, dynamic>)['name'] as String? ?? '').toList();

    return Theme(
      data: ThemeData(fontFamily: fontFamily),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: HomeScreen(config: groupData, isGroupHome: true),
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
