import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class PoliciesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> policies;

  const PoliciesWidget({required this.policies});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.cardBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hotel Policies',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 20),
          ...policies.asMap().entries.map((entry) {
            final policy = entry.value;
            final isLast = entry.key == policies.length - 1;
            return Column(
              children: [
                _buildPolicyItem(
                  _getIconFromString(policy['icon'] ?? ''),
                  policy['title'] ?? '',
                  policy['description'] ?? '',
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'cancel':
        return Icons.cancel;
      case 'pets':
        return Icons.pets;
      case 'smoke_free':
        return Icons.smoke_free;
      default:
        return Icons.info;
    }
  }

  Widget _buildPolicyItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.chipBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.cardBorder),
          ),
          child: Icon(icon, size: 24, color: AppColor.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
