import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class DescriptionSection extends StatefulWidget {
  final String subtitle;

  const DescriptionSection({Key? key, required this.subtitle})
    : super(key: key);

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final descriptionText =
        'Experience comfort, convenience, and thoughtful hospitality in a space designed to make every stay relaxing and memorable. Our property offers well-appointed accommodations, modern amenities, and a welcoming atmosphere suited for both short and long stays. Whether you’re traveling for leisure or business, enjoy a peaceful environment, attentive service, and easy access to nearby attractions and essential facilities. Your comfort is our priority, ensuring a pleasant and hassle-free stay from check-in to check-out.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle in bold
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 12),

        // Description with ellipsis
        Column(
          children: [
            // Main text
            Text(
              descriptionText,
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
              maxLines: isDescriptionExpanded ? null : 3,
              overflow: isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            // Read More / See Less text on the left
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
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
            ),
          ],
        ),
      ],
    );
  }
}
