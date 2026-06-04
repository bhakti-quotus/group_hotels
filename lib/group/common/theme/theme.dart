import 'package:flutter/material.dart';

// Default color constants
const Color _defaultPrimary = Color.fromARGB(255, 15, 89, 47);
const Color _defaultSecondary = Color.fromARGB(255, 153, 129, 60);
const Color _defaultBackground = Colors.white;
const Color _defaultText = Color(0xFF000000);

class AppColor {
  static Color get primary => BrandingColors.primary;
  static Color get secondary => BrandingColors.secondary;
  static Color get background => BrandingColors.background;
  static Color get text => BrandingColors.text;
  static const Color textLight = Color(0xFF666666);

  static const Color bottomBarBackground = Colors.white;
  static Color get bottomBarSelected => primary;
  static const Color bottomBarUnselected = Color(0xFF888888);
  static Color get bottomBarIconSelected => primary;
  static const Color bottomBarIconUnselected = Color(0xFF888888);

  static const Color cardBackground = Colors.white;
  static const Color ratingColor = Color(0xFFFFD700);
  static const Color chipBackground = Color(0xFFE8F0FE);
  static const Color cardBorder = Color(0xFFE0E0E0);
}

class BrandingColors {
  static Color? _primary;
  static Color? _secondary;
  static Color? _background;
  static Color? _text;
  static String? _fontFamily;

  static Color get primary => _primary ?? _defaultPrimary;
  static Color get secondary => _secondary ?? _defaultSecondary;
  static Color get background => _background ?? _defaultBackground;
  static Color get text => _text ?? _defaultText;
  static String get fontFamily => _fontFamily ?? 'Inter';

  static void loadFromConfig(Map<String, dynamic> config) {
    try {
      final branding = config['branding'] as Map<String, dynamic>?;
      if (branding != null) {
        _primary = branding['primaryColor'] != null
            ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
            : null;
        _secondary = branding['secondaryColor'] != null
            ? Color(int.parse(branding['secondaryColor'].replaceFirst('#', '0xff')))
            : null;
        _background = branding['backgroundColor'] != null
            ? Color(int.parse(branding['backgroundColor'].replaceFirst('#', '0xff')))
            : null;
        _text = const Color(0xFF000000); // Keep default or add to mockdata if needed
        _fontFamily = branding['fontFamily'];
      }
    } catch (e) {
      // Handle error - keep default colors
    }
  }

  static Future<void> loadBrandingColors() async {
    // Deprecated, use loadFromConfig instead
  }

  static void resetToDefaults() {
    _primary = null;
    _secondary = null;
    _background = null;
    _text = null;
    _fontFamily = null;
  }
}

class AppColors {
  static Color get primary => AppColor.primary;
  static Color get secondary => AppColor.secondary;
  static Color get background => const Color(0xFFF7F8FA);
  static const textDark   = Color(0xFF1A1A2E);
  static const textMuted  = Color(0xFF777777);
  static const card       = Colors.white;
  static final border     = Colors.grey.shade300;
}

