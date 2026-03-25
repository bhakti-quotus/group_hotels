import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/bottom_navitem/bottom_navitem_list.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/ui/bottom_navbar/bottom_navbar.dart';

class GroupWebRoomPage extends StatelessWidget {
  const GroupWebRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();
    final rootConfig = hotelController.getRootConfig() ?? hotelController.getConfig() ?? {};
    final groupBranding = (rootConfig['config'] as Map<String, dynamic>?)?['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = groupBranding['primaryColor'] != null
        ? Color(int.parse(groupBranding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;
    final groupLogo = groupBranding['logo'] as String?;
    final childHotels = (rootConfig['childHotels'] as List<dynamic>?) ?? [];

    return FutureBuilder<List<BottomNavItem>>(
      future: BottomNavItemManager.getNavItems(config: rootConfig),
      builder: (context, snapshot) {
        final navItems = snapshot.data ?? [];
        final currentIndex = navItems.indexWhere((item) => item.route == AppRoutes.webroom);

        void onNavTap(int index) {
          if (index < navItems.length) {
            final selected = navItems[index];
            Get.offNamed(selected.route);
          }
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Row(
              children: [
                if (groupLogo != null && groupLogo.isNotEmpty)
                  Image.network(
                    groupLogo,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.hotel, color: Colors.white),
                  )
                else
                  const Icon(Icons.hotel, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Webroom'),
              ],
            ),
          ),
          body: childHotels.isEmpty
              ? Center(
                  child: Text(
                    'No child hotels found.',
                    style: TextStyle(color: AppColor.text, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: childHotels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final hotel = childHotels[index] as Map<String, dynamic>;
                    final hotelName = hotel['name'] as String? ?? 'Hotel';
                    final hotelLogo = (hotel['config'] as Map<String, dynamic>?)?['branding']?['logo'] as String?;

                    return ListTile(
                      leading: hotelLogo != null && hotelLogo.isNotEmpty
                          ? Image.network(
                              hotelLogo,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.hotel),
                            )
                          : const Icon(Icons.hotel, size: 44),
                      title: Text(hotelName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        final hotelConfig = hotel['config'] as Map<String, dynamic>? ?? {};
                        hotelController.setSelectedHotel(hotel);
                        hotelController.setConfig(hotelConfig);
                        BrandingColors.loadFromConfig(hotelConfig);
                        Get.toNamed(AppRoutes.webroomChildSplash, arguments: hotel);
                      },
                    );
                  },
                ),
          bottomNavigationBar: navItems.isNotEmpty
              ? BottomNavbar(
                  currentIndex: currentIndex >= 0 ? currentIndex : 0,
                  onTap: onNavTap,
                  items: navItems,
                  primaryColor: primaryColor,
                )
              : null,
        );
      },
    );
  }
}
