import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class QuickActionsSection extends StatelessWidget {
  final List<dynamic> items;
  final Function(int index, String route)? onItemTap;

  const QuickActionsSection({super.key, this.items = const [], this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        Row(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final label = item['label'] as String? ?? '';
            final iconName = item['icon'] as String? ?? '';
            final route = item['route'] as String? ?? '';
            final colorValue = item['color'] as String? ?? '#0D5399';

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _QuickActionButton(
                  icon: _getIcon(iconName),
                  label: label,
                  color: _getColor(colorValue),
                  onTap: () => onItemTap?.call(index, route),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'meeting_room':
        return Icons.meeting_room_outlined;
      case 'tourism':
        return Icons.eco_outlined;
      case 'facilities':
        return Icons.local_activity_outlined;
      case 'business':
        return Icons.business_outlined;
      case 'local_offer':
        return Icons.local_offer_outlined;
      case 'card_giftcard':
        return Icons.card_giftcard_outlined;
      case 'spa':
        return Icons.spa_outlined;
      case 'star':
        return Icons.star_outline;
      case 'wifi':
        return Icons.wifi_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'pool':
        return Icons.pool_outlined;
      case 'gym':
        return Icons.fitness_center_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF0D5399);
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
