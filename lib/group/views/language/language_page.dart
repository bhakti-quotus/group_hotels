import 'package:flutter/material.dart';
import 'package:sunswept/group/utils/app_routes.dart';
import 'package:get/get.dart';
import '../../common/theme/theme.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? selectedLanguage;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Chinese', 'native': '中文', 'flag': '🇨🇳'},
    {'name': 'Japanese', 'native': '日本語', 'flag': '🇯🇵'},
    {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    {'name': 'Portuguese', 'native': 'Português', 'flag': '🇵🇹'},
    {'name': 'Russian', 'native': 'Русский', 'flag': '🇷🇺'},
  ];

  void _handleContinue() {
    if (selectedLanguage != null) {
      Get.toNamed(AppRoutes.login);
    }
  }

  void _handleSkip() {
    Get.toNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColor.primary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // Title section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Choose Your Language',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColor.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your preferred language',
                    style: TextStyle(fontSize: 16, color: AppColor.textLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Language list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguage == language['name'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedLanguage = language['name'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.primary
                                : AppColor.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            Text(
                              language['flag']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    language['name']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColor.primary
                                          : AppColor.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    language['native']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColor.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColor.primary,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedLanguage != null ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    disabledBackgroundColor: AppColor.cardBorder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
