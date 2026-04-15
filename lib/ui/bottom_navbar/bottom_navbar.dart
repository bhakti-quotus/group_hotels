import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/bottom_navitem/bottom_navitem_list.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

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

class _BottomNavbarState extends State<BottomNavbar>
    with TickerProviderStateMixin {
  // One scale controller per item for press feedback
  late List<AnimationController> _scaleControllers;

  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  void _buildControllers() {
    _scaleControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.88,
        upperBound: 1.0,
        value: 1.0,
      ),
    );
  }

  @override
  void didUpdateWidget(BottomNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      for (final c in _scaleControllers) {
        c.dispose();
      }
      _buildControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    _scaleControllers[index].reverse().then((_) {
      if (mounted) _scaleControllers[index].forward();
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isActive = widget.currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _scaleControllers[index],
                builder: (_, child) => Transform.scale(
                  scale: _scaleControllers[index].value,
                  child: child,
                ),
                child: _NavItem(
                  item: item,
                  isActive: isActive,
                  primaryColor: widget.primaryColor,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Single nav item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final Color primaryColor;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: isActive ? 52 : 40,
          height: isActive ? 36 : 32,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              item.icon,
              size: isActive ? 20 : 18,
              color: isActive ? Colors.white : AppColor.bottomBarIconUnselected,
            ),
          ),
        ),

        const SizedBox(height: 3),

        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? primaryColor : AppColor.bottomBarIconUnselected,
            letterSpacing: isActive ? 0.2 : 0,
          ),
          child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),

        // Active dot indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(top: 3),
          width: isActive ? 18 : 0,
          height: isActive ? 3 : 0,
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
