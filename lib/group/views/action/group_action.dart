import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:royalcontinent/ui/bottom_navbar/bottom_navbar.dart';
import 'package:royalcontinent/ui/quick_action_screen/quick_action.dart';
import '../../common/theme/theme.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';

class ActionsG extends StatefulWidget {
  const ActionsG({super.key});

  @override
  State<ActionsG> createState() => _ActionsGState();
}

class _ActionsGState extends State<ActionsG> {
  Map<String, dynamic> groupData = {};
  int _currentIndex = 4;
  List<BottomNavItem> _navItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    BrandingColors.resetToDefaults();
    loadGroupData();
  }

  Future<void> loadGroupData() async {
    setState(() => _isLoading = true);
    final config = Get.find<HotelController>().getConfig();
    if (config != null && config['childHotels'] != null) {
      setState(() {
        groupData = config;
      });
      await _loadNavItems();
    } else {
      // Load group data from assets
      try {
        final String response = await rootBundle.loadString(
          'assets/config.json',
        );
        final decoded = json.decode(response);
        final data = decoded;
        final groupConfig = data['config'] as Map<String, dynamic>? ?? {};
        BrandingColors.loadFromConfig(groupConfig);
        setState(() {
          groupData = data;
        });
        await _loadNavItems();
      } catch (e) {
        print('Error loading data: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNavItems() async {
    final items = await BottomNavItemManager.getNavItems(config: groupData);
    setState(() {
      _navItems = items;
      _currentIndex = _navItems.indexWhere((item) => item.route == '/actions');
      if (_currentIndex == -1) _currentIndex = 4;
    });
  }

  void _onNavTap(int index) {
    if (index != _currentIndex && index < _navItems.length) {
      Get.offAllNamed(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final branding =
        config?['config']?['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: QuickActionPage(),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: _navItems,
        primaryColor: primaryColor,
      ),
    );
  }
}
