import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class AmenityIcon extends StatelessWidget {
  final String icon;
  final String label;

  const AmenityIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          // Image on the left
          SizedBox(
            width: 18,
            height: 18,
            child: icon.toLowerCase().contains('.svg')
                ? SvgPicture.network(
                    icon,
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => Icon(
                      Icons.image_not_supported,
                      size: 18,
                      color: AppColor.secondary,
                    ),
                  )
                : Image.network(
                    icon,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      size: 18,
                      color: AppColor.secondary,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Text content on the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
