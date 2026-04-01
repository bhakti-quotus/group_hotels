import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class PoliciesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> policies;

  const PoliciesWidget({required this.policies});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(width: 16, height: 2, color: AppColor.secondary),
              const SizedBox(width: 6),
              Text(
                'POLICIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondary,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Hotel Policies',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColor.text,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 16),

          // Cards
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: policies.asMap().entries.map((entry) {
                final policy = entry.value;
                final index = entry.key;
                final isFirst = index == 0;
                final isLast = index == policies.length - 1;

                return _PolicyTile(
                  icon: _getIconFromString(policy['icon'] ?? ''),
                  title: policy['title'] ?? '',
                  description: policy['description'] ?? '',
                  isFirst: isFirst,
                  isLast: isLast,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      case 'cancel':
        return Icons.event_busy_outlined;
      case 'pets':
        return Icons.pets_outlined;
      case 'smoke_free':
        return Icons.smoke_free_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

// ─── Policy Tile ──────────────────────────────────────────────────────────────

class _PolicyTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isFirst;
  final bool isLast;

  const _PolicyTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isFirst,
    required this.isLast,
  });

  @override
  State<_PolicyTile> createState() => _PolicyTileState();
}

class _PolicyTileState extends State<_PolicyTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotateAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  BorderRadius get _borderRadius {
    if (widget.isFirst && widget.isLast) {
      return BorderRadius.circular(16);
    } else if (widget.isFirst) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      );
    } else if (widget.isLast) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    }
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider between tiles (not before first)
        if (!widget.isFirst)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColor.secondary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        InkWell(
          onTap: _toggle,
          borderRadius: _borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: AppColor.primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Title
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColor.text,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                    // Chevron
                    RotationTransition(
                      turns: _rotateAnim,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColor.secondary,
                      ),
                    ),
                  ],
                ),

                // Expandable description
                SizeTransition(
                  sizeFactor: _fadeAnim,
                  axisAlignment: -1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 56),
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.textLight,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
