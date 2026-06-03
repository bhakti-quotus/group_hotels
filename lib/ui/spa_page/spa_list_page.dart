// spa_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class SpaListPage extends StatelessWidget {
  final List<dynamic> spas;
  final String? title;

  const SpaListPage({super.key, required this.spas, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        titleSpacing: 5,
        title: Row(
          children: [
            Container(
              width: 3.5,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Spa",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? 'Our Spa',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: spas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_outlined, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No spas available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      
                        Text(
                          'Indulge in pure bliss at our tranquil spa',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final spa = spas[index] as Map<String, dynamic>;
                        final name = spa['name'] as String? ?? 'Unnamed Spa';
                        final imageUrl = spa['image'] as String? ?? '';
                        final description = spa['description'] as String? ?? '';
                        final location = spa['location'] as String? ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _SpaCard(
                            name: name,
                            imageUrl: imageUrl,
                            description: description,
                            location: location,
                          ),
                        );
                      },
                      childCount: spas.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
    );
  }
}

// ── Spa Card ──────────────────────────────────────────────────────────────────

class _SpaCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String description;
  final String location;

  const _SpaCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.location,
  });

  @override
  State<_SpaCard> createState() => _SpaCardState();
}

class _SpaCardState extends State<_SpaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.description.trim().isNotEmpty;
    final hasLocation = widget.location.trim().isNotEmpty;
    final shouldShowToggle = widget.description.trim().length > 120;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image with overlaid name ──────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 210,
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Name + location on image
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left accent bar
                      Container(
                        width: 3,
                        height: 28,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            if (hasLocation) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Description ───────────────────────────────────────────────
          if (hasDescription)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    maxLines: _expanded ? null : 3,
                    overflow:
                        _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.5,
                      height: 1.6,
                    ),
                  ),
                  if (shouldShowToggle)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _expanded ? 'Read less' : 'Read more',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ── Footer motif ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColor.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 210,
      color: AppColor.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.spa_outlined,
          size: 48,
          color: AppColor.primary.withOpacity(0.35),
        ),
      ),
    );
  }
}