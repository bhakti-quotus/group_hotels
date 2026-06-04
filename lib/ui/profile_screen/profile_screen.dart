import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/auth_controller.dart';
import 'package:royalcontinent/ui/booking_page/bookings_page.dart';
import 'package:royalcontinent/ui/bottom_navbar/bottom_navbar.dart';
import 'package:royalcontinent/group/common/bottom_navitem/bottom_navitem_list.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';
import 'package:royalcontinent/group/utils/app_snackbar.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 0;
  List<BottomNavItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _loadNavItems();
  }

  Future<void> _loadNavItems() async {
    final items = await BottomNavItemManager.getNavItems();
    setState(() {
      _navItems = items;
      _currentIndex = _navItems.indexWhere((item) => item.route == AppRoutes.profile);
      if (_currentIndex == -1) {
        _currentIndex = 0;
      }
    });
  }

  void _onNavTap(int index) {
    if (index != _currentIndex && index < _navItems.length) {
      Get.offNamed(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      if (!authCtrl.authInitialized.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (!authCtrl.isLoggedIn.value) {
        Future.microtask(() {
          AppSnackbar.info('Please log in to view profile');
          Get.offNamed(AppRoutes.login);
        });

        return const Scaffold(
          body: SizedBox.shrink(),
        );
      }

      return Scaffold(
        backgroundColor: AppColor.background,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, authCtrl),

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(authCtrl),

                    const SizedBox(height: 28),

                    _buildSectionLabel('Account'),

                    const SizedBox(height: 12),

                    _buildMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'My Wishlist',
                      subtitle: 'Saved hotels & offers',
                      onTap: () {},
                    ),

                    _buildMenuItem(
                      icon:
                          Icons.confirmation_number_outlined,
                      title: 'My Bookings',
                      subtitle:
                          'View & manage reservations',
                      onTap: () => Get.to(
                        () => const MyBookingsPage(),
                      ),
                    ),

                    _buildMenuItem(
                      icon:
                          Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Alerts & updates',
                      onTap: () {},
                    ),

                    const SizedBox(height: 28),

                    _buildSectionLabel('Session'),

                    const SizedBox(height: 12),

                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle:
                          'Sign out of your account',
                      iconColor: Colors.red.shade400,
                      onTap: () => _showLogoutDialog(
                        context,
                        authCtrl,
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _navItems.isNotEmpty
            ? BottomNavbar(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
                items: _navItems,
                primaryColor: AppColor.primary,
              )
            : null,
      );
    });
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    AuthController authCtrl,
  ) {
    return SliverAppBar(
      backgroundColor: AppColor.background,
      elevation: 0,
      pinned: true,
      expandedHeight: 150,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.primary.withOpacity(0.07),
                    AppColor.background,
                  ],
                ),
              ),
            ),

            Positioned(
              top: -40,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primary
                      .withOpacity(0.05),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColor.text,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 3,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius:
                              BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      AuthController authCtrl) {
    return Obx(() {
      final displayName =
          authCtrl.fullName.isNotEmpty
              ? authCtrl.fullName
              : 'Welcome back!';

      final subtitle =
          authCtrl.email.value.isNotEmpty
              ? authCtrl.email.value
              : authCtrl.displayRole;

      final initials =
          displayName.trim().isNotEmpty
              ? displayName
                  .trim()
                  .split(' ')
                  .map((w) => w[0])
                  .take(2)
                  .join()
              : '?';

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: AppColor.cardBorder,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  AppColor.primary,
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool showChevron = true,
  }) {
    final color =
        iconColor ?? AppColor.primary;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: showChevron
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthController authCtrl,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authCtrl.logout(
                navigateToHome: true,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}