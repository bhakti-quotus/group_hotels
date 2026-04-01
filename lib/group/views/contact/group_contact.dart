import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/ui/bottom_navbar/bottom_navbar.dart';
import 'package:sunswept/ui/contact_screen/contact_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GroupContact extends StatefulWidget {
  const GroupContact({super.key});

  @override
  State<GroupContact> createState() => _GroupContactState();
}

class _GroupContactState extends State<GroupContact> {
  int _currentIndex = 0;
  List<BottomNavItem> _navItems = [];
  String _groupName = 'Head Office';

  @override
  void initState() {
    super.initState();
    _loadGroupConfig();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGroupConfig();
  }

  Future<void> _loadGroupConfig() async {
    // Always load group config from assets
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final decoded = json.decode(response);
      setState(() {
        _groupName = decoded['name'] ?? 'Head Office';
      });
      Get.find<HotelController>().setConfig(decoded);
      final groupConfig = decoded['config'] as Map<String, dynamic>? ?? {};
      BrandingColors.loadFromConfig(groupConfig);
      await _loadNavItems();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _loadNavItems() async {
    final jsonString = await rootBundle.loadString('assets/config.json');
    final decoded = json.decode(jsonString);
    final navigation = decoded['config']['navigation'];
    final items =
        (navigation['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    final navItems = items.where((item) => item['visible'] == true).map((item) {
      String route = item['route'] as String? ?? '';
      switch (route) {
        case '/home':
          route = '/grouphome';
          break;
        case '/about':
          route = '/groupabout';
          break;
        case '/contact':
          route = '/groupcontact';
          break;
      }
      return BottomNavItem(
        icon: BottomNavItemManager.getIconFromString(
          item['icon'] as String? ?? '',
        ),
        label: item['label'] as String? ?? '',
        route: route,
      );
    }).toList();
    setState(() {
      _navItems = navItems;
      _currentIndex = _navItems.indexWhere(
        (item) => item.route == '/groupcontact',
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

    return Theme(
      data: ThemeData(fontFamily: fontFamily),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: ContactScreen(title: _groupName),
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
