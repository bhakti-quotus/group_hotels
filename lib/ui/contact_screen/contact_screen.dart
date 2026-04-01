import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunswept/group/controllers/hotel_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:sunswept/group/common/theme/theme.dart';

class ContactScreen extends StatefulWidget {
  final String title;
  const ContactScreen({Key? key, this.title = 'Get In Touch'})
    : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> data = {};
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Map<String, Map<String, dynamic>> _knownPlatforms = {
    'facebook': {
      'label': 'Facebook',
      'icon': Icons.facebook,
      'color': Color(0xFF1877F2),
    },
    'instagram': {
      'label': 'Instagram',
      'icon': Icons.camera_alt_outlined,
      'color': Color(0xFFE4405F),
    },
    'linkedin': {
      'label': 'LinkedIn',
      'icon': Icons.business_center_outlined,
      'color': Color(0xFF0077B5),
    },
    'youtube': {
      'label': 'YouTube',
      'icon': Icons.play_circle_outline,
      'color': Color(0xFFFF0000),
    },
  };

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );
    loadData();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void loadData() {
    try {
      final config = Get.find<HotelController>().getConfig();
      if (config != null) {
        setState(() {
          data = config['config'] ?? config;
        });
        _entranceCtrl.forward();
      }
    } catch (e) {
      debugPrint('Contact load error: $e');
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (_) {
      Get.snackbar('Error', 'Unable to open link');
    }
  }

  Future<void> _makePhoneCall(String phone) => _openUrl('tel:$phone');
  Future<void> _sendEmail(String email) =>
      _openUrl('mailto:$email?subject=Hotel Inquiry');
  Future<void> _openMaps(String mapUrl, double lat, double lng) {
    final url = mapUrl.isNotEmpty
        ? mapUrl
        : 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    return _openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.primary),
            strokeWidth: 2,
          ),
        ),
      );
    }

    final contact = data['contact'] as Map<String, dynamic>? ?? {};
    final footer = data['footer'] as Map<String, dynamic>? ?? {};
    final social = footer['social'] as Map<String, dynamic>? ?? {};
    final links = footer['links'] as List<dynamic>? ?? [];
    final copyright = footer['copyright'] as String? ?? '';

    final latitude =
        double.tryParse(contact['latitude']?.toString() ?? '') ?? 0;
    final longitude =
        double.tryParse(contact['longitude']?.toString() ?? '') ?? 0;
    final mapUrl = contact['mapUrl'] as String? ?? '';

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header ──────────────────────────────────────────────
            _HeroHeader(title: widget.title, topPad: topPad),

            // ── Body content ─────────────────────────────────────────────
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Contact cards
                      _SectionLabel(label: 'REACH US'),
                      const SizedBox(height: 12),

                      if ((contact['phone'] as String? ?? '').isNotEmpty)
                        _ContactTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: contact['phone'] ?? '',
                          accentColor: const Color(0xFF22C55E),
                          onTap: () => _makePhoneCall(contact['phone'] ?? ''),
                        ),

                      if ((contact['email'] as String? ?? '').isNotEmpty)
                        _ContactTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: contact['email'] ?? '',
                          accentColor: AppColor.primary,
                          onTap: () => _sendEmail(contact['email'] ?? ''),
                        ),

                      if ((contact['address'] as String? ?? '').isNotEmpty)
                        _ContactTile(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: contact['address'] ?? '',
                          accentColor: AppColor.secondary,
                          onTap: () => _openMaps(mapUrl, latitude, longitude),
                          isLast: true,
                        ),

                      const SizedBox(height: 20),

                      // Directions button
                      _DirectionsButton(
                        onTap: () => _openMaps(mapUrl, latitude, longitude),
                        primaryColor: AppColor.primary,
                      ),

                      // Social section
                      if (social.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionLabel(label: 'FOLLOW US'),
                        _SocialGrid(
                          social: social,
                          platforms: _knownPlatforms,
                          onTap: _openUrl,
                        ),
                      ],

                      // Footer links
                      if (links.isNotEmpty || copyright.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _FooterSection(
                          links: links,
                          copyright: copyright,
                          onLinkTap: (url) => _openUrl(url),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String title;
  final double topPad;

  const _HeroHeader({required this.title, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.82)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Eyebrow
                Row(
                  children: [
                    Container(width: 20, height: 2, color: AppColor.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'CONTACT US',
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "We're here to help. Reach out anytime.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 2, color: AppColor.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColor.secondary,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

// ─── Contact Tile ─────────────────────────────────────────────────────────────

class _ContactTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isLast;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onTap,
    this.isLast = false,
  });

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.textLight,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.text,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Directions Button ────────────────────────────────────────────────────────

class _DirectionsButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color primaryColor;

  const _DirectionsButton({required this.onTap, required this.primaryColor});

  @override
  State<_DirectionsButton> createState() => _DirectionsButtonState();
}

class _DirectionsButtonState extends State<_DirectionsButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.primaryColor,
                widget.primaryColor.withOpacity(0.82),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Open in Google Maps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social Grid ──────────────────────────────────────────────────────────────

class _SocialGrid extends StatelessWidget {
  final Map<String, dynamic> social;
  final Map<String, Map<String, dynamic>> platforms;
  final void Function(String url) onTap;

  const _SocialGrid({
    required this.social,
    required this.platforms,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = social.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        final key = entries[index].key.toLowerCase().replaceAll(' ', '');
        final url = entries[index].value as String? ?? '';
        final platform =
            platforms[key] ??
            {
              'label': entries[index].key,
              'icon': Icons.link_rounded,
              'color': AppColor.primary,
            };

        final color = platform['color'] as Color;
        final icon = platform['icon'] as IconData;
        final label = platform['label'] as String;

        return _SocialTile(
          label: label,
          icon: icon,
          color: color,
          url: url,
          onTap: onTap,
        );
      },
    );
  }
}

class _SocialTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String url;
  final void Function(String) onTap;

  const _SocialTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
    required this.onTap,
  });

  @override
  State<_SocialTile> createState() => _SocialTileState();
}

class _SocialTileState extends State<_SocialTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap(widget.url);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 17, color: widget.color),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer Section ───────────────────────────────────────────────────────────

class _FooterSection extends StatelessWidget {
  final List<dynamic> links;
  final String copyright;
  final void Function(String) onLinkTap;

  const _FooterSection({
    required this.links,
    required this.copyright,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (links.isNotEmpty) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: links.map<Widget>((link) {
                return TextButton(
                  onPressed: () =>
                      onLinkTap(link['url'] ?? link['route'] ?? ''),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    link['label'] ?? '',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (copyright.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColor.secondary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
          ],
          if (copyright.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              copyright,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textLight,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
