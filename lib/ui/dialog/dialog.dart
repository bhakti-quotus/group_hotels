import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';

// Error Dialog
void showErrorDialog(
  BuildContext context,
  String message, {
  VoidCallback? onPressed,
  bool barrierDismissible = false,
  Color? iconColor,
  String? title,
  Color? buttonColor,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: iconColor ?? Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      onPressed ??
                      () {
                        Navigator.of(context).pop();
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Success Dialog
void showSuccessDialog(
  BuildContext context,
  String message, {
  VoidCallback? onPressed,
  bool barrierDismissible = false,
  Color? iconColor,
  String? title,
  Color? buttonColor,
  IconData? icon,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.check_circle_outline,
                  size: 50,
                  color: iconColor ?? Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title ?? 'Success',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      onPressed ??
                      () {
                        Navigator.of(context).pop();
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? Colors.green.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
