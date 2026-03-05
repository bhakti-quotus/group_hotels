import 'package:flutter/material.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactScreen extends StatefulWidget {
  final String title;
  const ContactScreen({Key? key, this.title = 'Get In Touch'})
    : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Map<String, dynamic> data = {};

  static const Map<String, Map<String, dynamic>> _knownPlatforms = {
    'facebook': {
      'label': 'Facebook',
      'icon': Icons.facebook,
      'color': Color(0xFF1877F2),
    },
    'instagram': {
      'label': 'Instagram',
      'icon': Icons.camera_alt,
      'color': Color(0xFFE4405F),
    },
    'linkedin': {
      'label': 'LinkedIn',
      'icon': Icons.business_center,
      'color': Color(0xFF0077B5),
    },
    'youtube': {
      'label': 'YouTube',
      'icon': Icons.play_circle_fill,
      'color': Color(0xFFFF0000),
    },
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    try {
      final hotelController = Get.find<HotelController>();
      final config = hotelController.getConfig();
      if (config != null) {
        setState(() {
          data = config['config'] ?? config;
        });
      }
    } catch (e) {
      debugPrint('Contact load error: $e');
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      Get.snackbar('Error', 'Unable to open link: $url');
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    await _openUrl('tel:$phone');
  }

  Future<void> _sendEmail(String email) async {
    await _openUrl('mailto:$email?subject=Hotel Inquiry');
  }

  Future<void> _openMaps(String mapUrl, double lat, double lng) async {
    final url = mapUrl.isNotEmpty
        ? mapUrl
        : 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    await _openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final contact = data['contact'] ?? {};
    final footer = data['footer'] ?? {};
    final social = footer['social'] ?? {};
    final links = footer['links'] ?? [];
    final hasLinks = links.isNotEmpty;
    final hasCopyright = (footer['copyright'] ?? '').isNotEmpty;

    final latitude =
        double.tryParse(contact['latitude']?.toString() ?? '') ?? 0;
    final longitude =
        double.tryParse(contact['longitude']?.toString() ?? '') ?? 0;
    final mapUrl = contact['mapUrl'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HERO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary,
                    AppColor.primary.withOpacity(0.85),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We're here to help and answer any question you might have.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            /// CONTACT CARDS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _contactCard(
                    Icons.phone,
                    'Phone',
                    contact['phone'] ?? '',
                    Colors.green,
                    () => _makePhoneCall(contact['phone'] ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _contactCard(
                    Icons.email,
                    'Email',
                    contact['email'] ?? '',
                    Colors.blue,
                    () => _sendEmail(contact['email'] ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _contactCard(
                    Icons.location_on,
                    'Address',
                    contact['address'] ?? '',
                    Colors.red,
                    () => _openMaps(mapUrl, latitude, longitude),
                  ),
                ],
              ),
            ),

            /// MAP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openMaps(mapUrl, latitude, longitude),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    'Open in Google Maps',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// SOCIAL
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Follow Us',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: _buildSocialButtons(social),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// CENTERED FOOTER
            if (hasLinks || hasCopyright)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    if (hasLinks)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: links.map<Widget>((link) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => _openUrl(link['url'] ?? ''),
                                  child: Text(
                                    link['label'] ?? '',
                                    style: TextStyle(
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    if (hasLinks && hasCopyright) const SizedBox(height: 10),
                    if (hasCopyright)
                      Text(
                        footer['copyright'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ===================== WIDGETS =====================

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _contactCard(
    IconData icon,
    String title,
    String value,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String label, IconData icon, Color color, String url) {
    return ElevatedButton.icon(
      onPressed: () => _openUrl(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  List<Widget> _buildSocialButtons(Map<String, dynamic> social) {
    List<Widget> buttons = [];
    for (var key in social.keys) {
      String normalizedKey = key.toLowerCase().replaceAll(' ', '');
      if (_knownPlatforms.containsKey(normalizedKey)) {
        var platform = _knownPlatforms[normalizedKey]!;
        buttons.add(
          _socialButton(
            platform['label'] as String,
            platform['icon'] as IconData,
            platform['color'] as Color,
            social[key] ?? '',
          ),
        );
      } else {
        buttons.add(
          _socialButton(key, Icons.link, AppColor.primary, social[key] ?? ''),
        );
      }
    }
    return buttons;
  }
}
