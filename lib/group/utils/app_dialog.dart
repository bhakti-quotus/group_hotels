import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DialogType { error, success, warning, info }

class _DialogColors {
  final Color bg, fg, btn;
  final IconData icon;
  const _DialogColors({
    required this.bg,
    required this.fg,
    required this.btn,
    required this.icon,
  });
}

_DialogColors _colorsFor(DialogType type) {
  switch (type) {
    case DialogType.error:
      return const _DialogColors(
        bg: Color(0xFFFCEBEB),
        fg: Color(0xFFE24B4A),
        btn: Color(0xFFE24B4A),
        icon: Icons.error_outline_rounded,
      );
    case DialogType.success:
      return const _DialogColors(
        bg: Color(0xFFEAF3DE),
        fg: Color(0xFF3B6D11),
        btn: Color(0xFF3B6D11),
        icon: Icons.check_circle_outline_rounded,
      );
    case DialogType.warning:
      return const _DialogColors(
        bg: Color(0xFFFAEEDA),
        fg: Color(0xFF854F0B),
        btn: Color(0xFF534AB7),
        icon: Icons.warning_amber_rounded,
      );
    case DialogType.info:
      return const _DialogColors(
        bg: Color(0xFFE6F1FB),
        fg: Color(0xFF185FA5),
        btn: Color(0xFF185FA5),
        icon: Icons.info_outline_rounded,
      );
  }
}

class AppDialog {
  static Future<void> show({
    required String title,
    required String message,
    DialogType type = DialogType.error,
    String confirmLabel = 'OK',
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    final colors = _colorsFor(type);

    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(colors.icon, color: colors.fg, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (cancelLabel != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          onCancel?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          cancelLabel,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.btn,
                        minimumSize: const Size.fromHeight(44),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static void showError(
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    show(
      title: title ?? 'Something went wrong',
      message: message,
      type: DialogType.error,
      confirmLabel: onRetry != null ? 'Try again' : 'OK',
      cancelLabel: onRetry != null ? 'Cancel' : null,
      onConfirm: onRetry,
      barrierDismissible: false,
    );
  }

  static void showSuccess(
    String message, {
    String? title,
    String confirmLabel = 'OK',
    VoidCallback? onConfirm,
  }) {
    show(
      title: title ?? 'Success',
      message: message,
      type: DialogType.success,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
    );
  }

  static void showWarning(
    String message, {
    String? title,
    String confirmLabel = 'OK',
    VoidCallback? onConfirm,
    String? cancelLabel,
    VoidCallback? onCancel,
  }) {
    show(
      title: title ?? 'Warning',
      message: message,
      type: DialogType.warning,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  static void showInfo(
    String message, {
    String? title,
    String confirmLabel = 'Got it',
    VoidCallback? onConfirm,
  }) {
    show(
      title: title ?? 'Info',
      message: message,
      type: DialogType.info,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
    );
  }

  /// Inline error banner widget — place above your Form widget
  static Widget errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEB),
        border: Border.all(color: const Color(0xFFF09595)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFA32D2D),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF791F1F),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
