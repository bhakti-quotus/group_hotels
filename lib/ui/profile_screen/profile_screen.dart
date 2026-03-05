import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/ui/dialog/dialog.dart';
import '../../ui/bottom_navbar/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data
  String userName = "John Doe";
  String userEmail = "john.doe@example.com";
  String userPhone = "+1 234 567 8900";
  String userImage = ""; // Add user image URL if available
  String selectedLanguage = "English (US)";

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);
    final phoneController = TextEditingController(text: userPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColor.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColor.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildEditTextField(
                controller: nameController,
                label: 'Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildEditTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildEditTextField(
                controller: phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColor.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userName = nameController.text;
                userEmail = emailController.text;
                userPhone = phoneController.text;
              });
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Profile updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColor.primary,
                colorText: Colors.white,
                borderRadius: 8,
                margin: const EdgeInsets.all(16),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColor.text, fontWeight: FontWeight.w500),
      cursorColor: AppColor.primary,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColor.textLight),
        floatingLabelStyle: TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: AppColor.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColor.primary.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last Updated: December 12, 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.textLight.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                '1. Information We Collect',
                'We collect information you provide directly to us, including your name, email address, phone number, and payment information when you make a booking.',
              ),
              _buildPolicySection(
                '2. How We Use Your Information',
                'We use the information we collect to process your bookings, send you confirmations, provide customer support, and improve our services.',
              ),
              _buildPolicySection(
                '3. Information Sharing',
                'We do not sell your personal information. We may share your information with service providers who help us operate our business and with hotels to complete your bookings.',
              ),
              _buildPolicySection(
                '4. Data Security',
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, or destruction.',
              ),
              _buildPolicySection(
                '5. Your Rights',
                'You have the right to access, update, or delete your personal information. You can do this through your account settings or by contacting us.',
              ),
              _buildPolicySection(
                '6. Cookies',
                'We use cookies and similar technologies to enhance your experience, analyze usage, and personalize content.',
              ),
              _buildPolicySection(
                '7. Contact Us',
                'If you have questions about this Privacy Policy, please contact us at privacy@hotelparadise.com',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColor.primary)),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last Updated: December 12, 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.textLight.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                '1. Acceptance of Terms',
                'By accessing and using Hotel Paradise services, you accept and agree to be bound by these Terms and Conditions.',
              ),
              _buildPolicySection(
                '2. Booking and Reservations',
                'All bookings are subject to availability. We reserve the right to refuse or cancel any booking at our discretion. Payment must be made in full at the time of booking.',
              ),
              _buildPolicySection(
                '3. Cancellation Policy',
                'Cancellations made 48 hours before check-in will receive a full refund. Cancellations within 48 hours are non-refundable.',
              ),
              _buildPolicySection(
                '4. Guest Responsibilities',
                'Guests are responsible for any damage to the property during their stay. Smoking, parties, and pets are not allowed unless specified.',
              ),
              _buildPolicySection(
                '5. Check-in/Check-out',
                'Standard check-in time is 3:00 PM and check-out time is 11:00 AM. Early check-in or late check-out may be available upon request and subject to additional charges.',
              ),
              _buildPolicySection(
                '6. Pricing',
                'All prices are subject to change without notice. The price you pay is the price displayed at the time of booking confirmation.',
              ),
              _buildPolicySection(
                '7. Limitation of Liability',
                'Hotel Paradise is not liable for any indirect, incidental, or consequential damages arising from your use of our services.',
              ),
              _buildPolicySection(
                '8. Modifications',
                'We reserve the right to modify these terms at any time. Continued use of our services constitutes acceptance of modified terms.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColor.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.textLight.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: AppColor.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColor.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showSuccessDialog(
                context,
                'Your account has been deleted',
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColor.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColor.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showSuccessDialog(
                context,
                'You have been logged out successfully',
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            children: [
              // Profile Picture with Edit Button
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showEditProfileDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    userPhone,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.textLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool showDivider = true,
    String? subtitle,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColor.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppColor.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColor.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColor.textLight.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColor.textLight.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 66),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColor.cardBorder.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Main Menu Section
            _buildMenuCard(
              title: 'MAIN',
              items: [
                _buildMenuItem(
                  icon: Icons.bookmark_outline,
                  title: 'My Bookings',
                  subtitle: 'View your reservations',
                  onTap: () => () {},
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notifications',
                  onTap: () => () {},
                  showDivider: false,
                ),
              ],
            ),

            // Settings Section
            _buildMenuCard(
              title: 'SETTINGS',
              items: [
                _buildMenuItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: selectedLanguage,
                  onTap: () => Get.toNamed(AppRoutes.language),
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // Navigate to help page
                  },
                ),
                _buildMenuItem(
                  icon: Icons.question_answer_outlined,
                  title: 'FAQ',
                  onTap: () {
                    // Navigate to FAQ page
                  },
                  showDivider: false,
                ),
              ],
            ),

            // Legal Section
            _buildMenuCard(
              title: 'LEGAL',
              items: [
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: _showPrivacyPolicy,
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: _showTermsAndConditions,
                  showDivider: false,
                ),
              ],
            ),

            // Account Section
            _buildMenuCard(
              title: 'ACCOUNT',
              items: [
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.orange,
                  onTap: _handleLogout,
                ),
                _buildMenuItem(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  iconColor: Colors.red,
                  onTap: _showDeleteAccountDialog,
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
