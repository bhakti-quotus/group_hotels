import 'dart:ui';
import 'package:flutter/material.dart';

// Error Dialog (renamed to Snackbar style)
void showErrorDialog(
  BuildContext context,
  String message, {
  VoidCallback? onPressed,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: _DismissibleSnackbar(
        message: message,
        isError: true,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // 🚀 Redirect immediately
  onPressed?.call();

  // Auto dismiss snackbar
  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

// Success Dialog (renamed to Snackbar style)
void showSuccessDialog(
  BuildContext context,
  String message, {
  VoidCallback? onPressed,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 15,
      left: 10,
      right: 10,
      child: _DismissibleSnackbar(
        message: message,
        isError: false,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // 🚀 Redirect immediately
  onPressed?.call();

  // Auto dismiss snackbar
  Future.delayed(const Duration(seconds: 5), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _DismissibleSnackbar extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _DismissibleSnackbar({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_DismissibleSnackbar> createState() => _DismissibleSnackbarState();
}

class _DismissibleSnackbarState extends State<_DismissibleSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isError
        ? Colors.red.shade400
        : Colors.green.shade400;

    final textColor = widget.isError
        ? Colors.red.shade400
        : Colors.green.shade400;

    final iconData = widget.isError
        ? Icons.error_outline
        : Icons.check_circle_outline;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onDismiss(),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(iconData, color: iconColor, size: 25),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
