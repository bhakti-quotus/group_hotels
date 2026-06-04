import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackType { error, success, warning, info }

class _SnackColors {
  final Color bg, actionColor;
  final IconData icon;
  const _SnackColors({
    required this.bg,
    required this.actionColor,
    required this.icon,
  });
}

_SnackColors _colorsFor(SnackType type) {
  switch (type) {
    case SnackType.error:
      return const _SnackColors(
        bg: Color(0xFFA32D2D),
        actionColor: Color(0xFFF7C1C1),
        icon: Icons.error_outline_rounded,
      );
    case SnackType.success:
      return const _SnackColors(
        bg: Color(0xFF27500A),
        actionColor: Color(0xFFC0DD97),
        icon: Icons.check_circle_outline_rounded,
      );
    case SnackType.warning:
      return const _SnackColors(
        bg: Color(0xFF633806),
        actionColor: Color(0xFFFAC775),
        icon: Icons.warning_amber_rounded,
      );
    case SnackType.info:
      return const _SnackColors(
        bg: Color(0xFF0C447C),
        actionColor: Color(0xFFB5D4F4),
        icon: Icons.info_outline_rounded,
      );
  }
}

class AppSnackbar {
  static void show({
    required String message,
    SnackType type = SnackType.error,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = _colorsFor(type);

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(colors.icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Get.closeCurrentSnackbar();
                onAction?.call();
              },
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: colors.actionColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: colors.bg,
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
    );
  }

  static void error(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) =>
      show(
        message: message,
        type: SnackType.error,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static void success(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        message: message,
        type: SnackType.success,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static void warning(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        message: message,
        type: SnackType.warning,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static void info(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        message: message,
        type: SnackType.info,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );
}
