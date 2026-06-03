import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class ValueSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const ValueSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Our Values';
    final items = (data['items'] as List<dynamic>?)?.cast<String>() ?? [];
    final description = data['description'] as String?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Row(
            children: [
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFC49A2A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'WHAT WE STAND FOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC49A2A),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            title,
            style:  TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Timeline items or description fallback
          if (items.isNotEmpty)
            ...items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              final icon = _getIcon(entry.key);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: circle + line
                    SizedBox(
                      width: 36,
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1FB),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(icon, size: 15, color: AppColor.primary),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 1.5,
                                color: const Color(0xFFD0DFF2),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right: full text
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: isLast ? 0 : 20,
                          top: 4,
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColor.textLight,
                            height: 1.7,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else if (description != null && description.isNotEmpty)
            _buildSinglePara(description)
          else
            _buildSinglePara(
              'Our values are built on trust, comfort, and thoughtful hospitality.',
            ),
        ],
      ),
    );
  }

  Widget _buildSinglePara(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.textLight,
                height: 1.7,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(int index) {
    const icons = [
      Icons.favorite_border,
      Icons.verified_outlined,
      Icons.eco_outlined,
      Icons.star_border,
      Icons.handshake_outlined,
      Icons.lightbulb_outlined,
    ];
    return icons[index % icons.length];
  }
}