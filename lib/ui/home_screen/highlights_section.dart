import 'package:flutter/material.dart';
import 'amenity_icon.dart';

class HighlightsSection extends StatelessWidget {
  final Map<String, dynamic> highlights;

  const HighlightsSection({
    super.key,
    required this.highlights,
  });


  @override
  Widget build(BuildContext context) {
    final items = highlights['data']?['items'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highlights',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (items.isNotEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: items
                .map((item) => AmenityIcon(
                      icon: item['icon'] ?? '',
                      label: item['label'] ?? '',
                    ))
                .toList(),
          )
        else
          const Text('No highlights available'),
        const SizedBox(height: 24),
      ],
    );
  }
}