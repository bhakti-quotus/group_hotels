import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/ui/bottom_navbar/bottom_navbar.dart';
import 'package:group/ui/room_screen/room_screen.dart';
import 'package:get/get.dart';
import '../../common/bottom_navitem/bottom_navitem_list.dart';
import '../../controllers/hotel_controller.dart';
import 'package:flutter/material.dart' as material;

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  int _currentIndex = 1;
  List<BottomNavItem> _navItems = [];
  bool _initialized = false; // ← guard to prevent re-init

  @override
  void initState() {
    super.initState();
    _ensureHotelSelected();
    _loadNavItems();
  }

  // ✅ REMOVED didChangeDependencies — it was causing repeated _loadNavItems()
  // calls on every rebuild, resetting _navItems and showing the spinner again.

  void _ensureHotelSelected() {
    final hotelController = Get.find<HotelController>();

    if (hotelController.getSelectedHotel() != null) {
      // ✅ Even if already set, reload branding in case it changed
      final hotelConfig = hotelController.getSelectedHotel()?['config'];
      if (hotelConfig != null) BrandingColors.loadFromConfig(hotelConfig);
      return;
    }

    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args['config'] != null) {
        hotelController.setSelectedHotel(args);
        BrandingColors.loadFromConfig(args['config']); // ✅ ADD
       // print("Room: hotel set from Get.arguments: ${args['name']}");
        return;
      }
      final hotelFromArgs = args['hotel'] as Map<String, dynamic>?;
      if (hotelFromArgs != null) {
        hotelController.setSelectedHotel(hotelFromArgs);
        BrandingColors.loadFromConfig(hotelFromArgs['config']); // ✅ ADD
        return;
      }
    }

    final config = hotelController.getConfig();
    if (config != null) {
      final childHotels = config['childHotels'] as List<dynamic>?;
      if (childHotels != null && childHotels.isNotEmpty) {
        final firstHotel = Map<String, dynamic>.from(childHotels.first);
        hotelController.setSelectedHotel(firstHotel);
        BrandingColors.loadFromConfig(firstHotel['config']); // ✅ ADD
        return;
      }
    }
  }

  Future<void> _loadNavItems() async {
    if (_initialized) return; // ← prevent re-running after first load

    final controller = Get.find<HotelController>();

    // Use selected hotel's config for nav items
    final selectedHotel = controller.getSelectedHotel();
    final hotelConfig = selectedHotel?['config'] as Map<String, dynamic>?;
    final branding =
        hotelConfig?['branding']
            as Map<String, dynamic>? ?? // ← child hotel first
        controller.getConfig()?['branding']
            as Map<String, dynamic>? ?? // ← group fallback
        {};
    // Fallback to group config if hotel config missing
    final config = hotelConfig ?? controller.getConfig();

    final items = await BottomNavItemManager.getNavItems(config: config);

    if (mounted) {
      setState(() {
        _navItems = items;
        _currentIndex = _navItems.indexWhere((item) => item.route == '/rooms');
        if (_currentIndex == -1) _currentIndex = 1;
        _initialized = true; // ← mark as done
      });
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex && index < _navItems.length) {
      Get.offAllNamed(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_navItems.isEmpty) {
      return const Scaffold(
        body: material.Center(child: CircularProgressIndicator()),
      );
    }

    final controller = Get.find<HotelController>();

    // ✅ Read branding from selected hotel's config, not group config
    final selectedHotel = controller.getSelectedHotel();
    final hotelConfig = selectedHotel?['config'] as Map<String, dynamic>?;
    final branding =
        hotelConfig?['branding'] as Map<String, dynamic>? ??
        controller.getConfig()?['branding'] as Map<String, dynamic>? ??
        {};

    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;
    final fontFamily = branding['fontFamily'] as String? ?? 'Inter';

    return Theme(
      data: ThemeData(fontFamily: fontFamily),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: RoomScreen(key: ValueKey(controller.getSelectedHotel()?['code'])),
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
