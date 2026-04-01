import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';

class DescriptionWidget extends StatefulWidget {
  final Map<String, dynamic> about;

  const DescriptionWidget({required this.about});

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.about['description']?.toString() ?? '';
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.about['title'] ?? 'About Us',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 16),
          if (description.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColor.textLight,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: isDescriptionExpanded ? null : 4,
                  overflow: isDescriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionExpanded = !isDescriptionExpanded;
                    });
                  },
                  child: Text(
                    isDescriptionExpanded ? 'See Less' : 'Read More',
                    style: TextStyle(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
