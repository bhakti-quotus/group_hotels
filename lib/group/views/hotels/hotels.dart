import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:group/ui/bottom_navbar/bottom_navbar.dart';
import 'package:group/ui/hotelscreen/hotelscreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/app_routes.dart';
import '../../common/theme/theme.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';

class Hotels extends StatefulWidget {
  const Hotels({super.key});

  @override
  State<Hotels> createState() => _HotelsState();
}

class _HotelsState extends State<Hotels> {
  Map<String, dynamic> groupData = {};
  int _currentIndex = 0;
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
      _currentIndex = _navItems.indexWhere((item) => item.route == '/hotels');
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
    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final branding =
        config?['config']?['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: HotelScreen(),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: _navItems,
        primaryColor: primaryColor,
      ),
    );
  }
}
