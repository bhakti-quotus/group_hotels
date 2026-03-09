import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/chat_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/ui/chat/panel.dart';

class ChatOverlay extends StatelessWidget {
  final String title;
  const ChatOverlay({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();

    final hiddenRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.verifyEmail,
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Panel height = 100% of screen
    final defaultPanelHeight = screenHeight * 1.0;

    return Obx(() {
      if (hiddenRoutes.contains(ctrl.currentRoute.value)) {
        return const SizedBox.shrink();
      }

      // ---- Initialize FAB position once ----
      if (!ctrl.positionInitialized.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          const fabSize = 56.0;
          const rightPadding = 20.0;
          const bottomPadding = 120.0;

          ctrl.updateButtonPosition(
            screenWidth - fabSize - rightPadding,
            screenHeight - fabSize - bottomPadding,
          );

          ctrl.positionInitialized.value = true;
        });

        return const SizedBox.shrink();
      }

      return Stack(
        children: [
          // ---- Chat Panel ----
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: ctrl.isOpen.value
                ? 0
                : -screenHeight,
            left: 0,
            right: 0,
            height: defaultPanelHeight,
            child: Material(
              color: Colors.transparent,
              child: KeyboardResponsivePanel(
                defaultHeight: defaultPanelHeight,
                child: const ChatPanel(),
              ),
            ),
          ),

          // ---- Draggable FAB ----
          if (!ctrl.isOpen.value)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: ctrl.buttonX.value,
              top: ctrl.buttonY.value,
              child: _DraggableFAB(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                panelHeight: defaultPanelHeight,
                controller: ctrl,
              ),
            ),
        ],
      );
    });
  }
}

// Widget that adjusts its height when keyboard appears
class KeyboardResponsivePanel extends StatefulWidget {
  final Widget child;
  final double defaultHeight;

  const KeyboardResponsivePanel({
    super.key,
    required this.child,
    required this.defaultHeight,
  });

  @override
  State<KeyboardResponsivePanel> createState() =>
      _KeyboardResponsivePanelState();
}

class _KeyboardResponsivePanelState extends State<KeyboardResponsivePanel> {
  double _keyboardHeight = 0;
  late FocusScopeNode _focusScopeNode;

  @override
  void initState() {
    super.initState();
    _focusScopeNode = FocusScope.of(context);
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for keyboard changes
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_keyboardHeight != bottomInsets && mounted) {
        setState(() {
          _keyboardHeight = bottomInsets;
        });
      }
    });

    // Calculate the actual height
    double actualHeight = widget.defaultHeight;
    if (_keyboardHeight > 0) {
      // Reduce height when keyboard appears
      actualHeight = MediaQuery.of(context).size.height * 0.8 - _keyboardHeight;
      // Ensure minimum height so the input field is visible
      actualHeight = actualHeight.clamp(300, widget.defaultHeight);
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: actualHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraggableFAB extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final double panelHeight;
  final ChatController controller;

  const _DraggableFAB({
    required this.screenWidth,
    required this.screenHeight,
    required this.panelHeight,
    required this.controller,
  });

  @override
  State<_DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<_DraggableFAB> {
  bool isDragging = false;
  double? dragStartX;
  double? dragStartY;

  static const double fabSize = 56.0;
  static const double padding = 20.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ---- Overlap detection ----
      final panelTop = widget.screenHeight - widget.panelHeight;
      final fabY = widget.controller.buttonY.value;

      final isOverPanel =
          widget.controller.isOpen.value && (fabY + fabSize > panelTop);

      if (isOverPanel) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onPanStart: (details) {
          setState(() {
            isDragging = true;
            dragStartX = widget.controller.buttonX.value;
            dragStartY = widget.controller.buttonY.value;
          });
        },
        onPanUpdate: (details) {
          if (dragStartX == null || dragStartY == null) return;

          double newX = dragStartX! + details.localPosition.dx - fabSize / 2;
          double newY = dragStartY! + details.localPosition.dy - fabSize / 2;

          newX = newX.clamp(padding, widget.screenWidth - fabSize - padding);
          newY = newY.clamp(padding, widget.screenHeight - fabSize - padding);

          widget.controller.updateButtonPosition(newX, newY);
        },
        onPanEnd: (_) {
          setState(() {
            isDragging = false;
            dragStartX = null;
            dragStartY = null;
          });

          final currentX = widget.controller.buttonX.value;

          if (currentX < widget.screenWidth / 2) {
            widget.controller.updateButtonPosition(
              padding,
              widget.controller.buttonY.value,
            );
          } else {
            widget.controller.updateButtonPosition(
              widget.screenWidth - fabSize - padding,
              widget.controller.buttonY.value,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(isDragging ? 1.1 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(isDragging ? 0.4 : 0.3),
                  blurRadius: isDragging ? 16 : 8,
                  offset:  Offset(0, isDragging ? 6 : 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: AppColor.primary,
              elevation: 0,
              onPressed: isDragging ? null : widget.controller.toggleChat,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  widget.controller.isOpen.value 
                      ? Icons.close_rounded 
                      : Icons.smart_toy_rounded,
                  key: ValueKey(widget.controller.isOpen.value),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}