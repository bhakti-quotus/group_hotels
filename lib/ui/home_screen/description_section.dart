import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class DescriptionSection extends StatefulWidget {
  final String title;
  final String description;

  const DescriptionSection({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection>
    with SingleTickerProviderStateMixin {
  bool isDescriptionExpanded = false;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
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
            // Decorative top accent line
            Row(
              children: [
                Container(width: 36, height: 2, color: AppColor.secondary),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 36, height: 2, color: AppColor.secondary),
              ],
            ),

            const SizedBox(height: 14),

            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColor.primary,
                letterSpacing: 0.3,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 14),

            // Subtle divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.secondary.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Description text
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isDescriptionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textLight,
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textLight,
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Read More / See Less button — elegant pill style
            GestureDetector(
              onTap: () {
                setState(() {
                  isDescriptionExpanded = !isDescriptionExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.secondary.withOpacity(0.6),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDescriptionExpanded ? 'See Less' : 'Read More',
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: isDescriptionExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColor.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
