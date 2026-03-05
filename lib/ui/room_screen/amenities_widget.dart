import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group/group/common/theme/theme.dart';

class AmenitiesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> amenities;
  final Color? primaryColor;

  const AmenitiesWidget({required this.amenities, this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.cardBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            'Hotel Amenities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildAmenityRows(amenities),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon(String iconUrl, String label) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        //color: AppColor.chipBackground,
        border: Border.all(color: AppColor.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: iconUrl.toLowerCase().contains('.svg')
          ? SvgPicture.network(
              iconUrl,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                Icons.image_not_supported,
                size: 24,
                color: AppColor.primary,
              ),
            )
          : Image.network(
              iconUrl,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  size: 24,
                  color: AppColor.primary,
                );
              },
            ),
    );
  }

  List<Widget> _buildAmenityRows(List<Map<String, dynamic>> amenities) {
    return amenities.map((amenity) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            _buildAmenityIcon(amenity['icon'], amenity['label']),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                amenity['label'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.text,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
