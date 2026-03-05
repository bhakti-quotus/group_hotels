import 'package:flutter/material.dart';
import 'package:group/group/common/bottom_navitem/bottom_navitem_list.dart';
import 'package:group/group/common/theme/theme.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color primaryColor;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.primaryColor,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main bottom navigation bar
        Container(
          margin: const EdgeInsets.all(5),
          height: 50 + bottomPadding,
          decoration: BoxDecoration(
            color: AppColor.bottomBarBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                widget.items.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
        // Elevated active item
        Positioned(
          top: -15,
          left: _calculateActivePosition(widget.currentIndex),
          child: _buildElevatedItem(),
        ),
      ],
    );
  }

  double _calculateActivePosition(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / widget.items.length;
    return itemWidth * index + (itemWidth / 2) - 30;
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isActive ? 0.0 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: AppColor.bottomBarIconUnselected,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColor.bottomBarIconUnselected,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedItem() {
    final item = widget.items[widget.currentIndex];

    return GestureDetector(
      onTap: () => widget.onTap(widget.currentIndex),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        tween: Tween(begin: 0.8, end: 1.0),
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
