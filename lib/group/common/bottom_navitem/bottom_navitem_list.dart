import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/hotel_controller.dart';
import '../../utils/app_routes.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class BottomNavItemManager {
  static Future<List<BottomNavItem>> getNavItems({
    Map<String, dynamic>? config,
  }) async {
    try {
      config ??= Get.find<HotelController>().getConfig();
      Map<String, dynamic> navigation;
      if (config != null) {
        navigation =
            config['config']?['navigation'] as Map<String, dynamic>? ??
            config['navigation'] as Map<String, dynamic>? ??
            {};
      } else {
        final jsonString = await rootBundle.loadString('assets/config.json');
        final decoded = json.decode(jsonString);
        navigation =
            decoded['config']['navigation'] as Map<String, dynamic>? ?? {};
      }
      final items =
          (navigation['items'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      final rootConfig = Get.find<HotelController>().getRootConfig();
      final controller = Get.find<HotelController>();
      final authCtrl = Get.find<AuthController>();
      final isGroup =
          controller.getSelectedHotel() == null &&
          (config != null &&
              config['childHotels'] != null &&
              (config['childHotels'] as List?)?.isNotEmpty == true);

      final filteredItems = items.where((item) {
        if (item['visible'] != true) return false;
        final route = (item['route'] as String?)?.toLowerCase() ?? '';
        final label = (item['label'] as String?)?.toLowerCase() ?? '';
        if (route == '/mybookings' || route == '/groupmybookings') return false;
        if (label == 'my bookings' || label == 'mybookings') return false;
        return true;
      }).toList();

      final mappedItems = filteredItems.map((
        item,
      ) {
        String route = item['route'] as String? ?? '';
        if (isGroup) {
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
            case '/mybookings':
              route = '/groupmybookings';
              break;
            case '/bookingdetails':
              route = '/groupbookingdetails';
              break;
            case '/hotels':
              route = '/grouphotels';
              break;
            case '/webroom':
              route = AppRoutes.webroom;
              break;
          }
        } else {
          switch (route) {
            case '/grouphome':
              route = '/home';
              break;
            case '/groupabout':
              route = '/about';
              break;
            case '/groupcontact':
              route = '/contact';
              break;
            case '/groupbookingdetails':
              route = '/bookingdetails';
              break;
            case '/grouphotels':
              route = '/hotels';
              break;
            case AppRoutes.webroom:
              route = AppRoutes.webroom;
              break;
          }
        }

        return BottomNavItem(
          icon: getIconFromString(item['icon'] as String? ?? ''),
          label: item['label'] as String? ?? '',
          route: route,
        );
      }).toList();

      final hasProfile = mappedItems.any((item) => item.route == AppRoutes.profile);
      if (!hasProfile) {
        mappedItems.add(
          BottomNavItem(
            icon: Icons.person,
            label: 'Profile',
            route: AppRoutes.profile,
          ),
        );
      }

      return mappedItems;
    } catch (e) {
      //print('Error loading navigation items: $e');
      return [];
    }
  }

  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'bed':
        return Icons.bed;
      case 'info':
        return Icons.info;
      case 'call':
        return Icons.call;
      case 'local_offer':
        return Icons.local_offer;

      // ✅ Matches "booking" from config JSON (My Bookings nav item)
      case 'booking':
      case 'my_bookings':
        return Icons.book_online;

      // ✅ Matches "building" from config JSON (Hotels nav item)
      case 'building':
      case 'hotels':
        return Icons.business;

      // ✅ For new webroom item in group navigation
      case 'web':
      case 'webroom':
        return Icons.web;

      default:
        return Icons.help;
    }
  }
}

// For backward compatibility, provide a getter that loads the items
Future<List<BottomNavItem>> get navItems async =>
    await BottomNavItemManager.getNavItems();
