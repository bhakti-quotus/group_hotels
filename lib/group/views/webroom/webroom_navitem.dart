import 'package:flutter/material.dart';
import 'package:group/group/common/bottom_navitem/bottom_navitem_list.dart';
import 'package:group/group/utils/app_routes.dart';

class WebroomNavItems {
  static const List<BottomNavItem> groupItems = [
    BottomNavItem(icon: Icons.home, label: 'Home', route: AppRoutes.groupHome),
    BottomNavItem(icon: Icons.business, label: 'Hotels', route: AppRoutes.groupHotels),
    BottomNavItem(icon: Icons.web, label: 'Webroom', route: AppRoutes.webroom),
  ];

  static const List<BottomNavItem> childWebroomItems = [
    BottomNavItem(icon: Icons.home, label: 'Home', route: AppRoutes.webroomChildMain),
    BottomNavItem(icon: Icons.schedule, label: 'Schedule', route: AppRoutes.webroomChildMain),
    BottomNavItem(icon: Icons.message, label: 'Messages', route: AppRoutes.webroomChildMain),
    BottomNavItem(icon: Icons.book_online, label: 'Reservation', route: AppRoutes.webroomChildMain),
    BottomNavItem(icon: Icons.person, label: 'Profile', route: AppRoutes.webroomChildMain),
  ];
}
