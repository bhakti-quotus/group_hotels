import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/auth_controller.dart';
import 'package:royalcontinent/group/utils/app_dialog.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';
import 'package:royalcontinent/group/utils/app_snackbar.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyOtp = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _stepOtp = false;
  bool _obscureNewPassword = true;
  String? _bannerError;

  final AuthController _authCtrl = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Password validation rules:
  // 1. Minimum 8 characters
  // 2. At least one uppercase letter
  // 3. At least one number
  // 4. At least one special character from: ! @ # $ &
  // 5. No other special characters allowed (only letters, numbers, and ! @ # $ &)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$&]'))) {
      return 'Password must contain at least one special character (! @ # \$ &)';
    }

    if (value.contains(RegExp(r'[^a-zA-Z0-9!@#$&]'))) {
      return 'Only ! @ # \$ & are allowed as special characters';
    }

    return null;
  }

  Future<void> _sendOtp() async {
    setState(() => _bannerError = null);
    if (!_formKeyEmail.currentState!.validate()) return;

    final email = _emailController.text.trim();

    final ok = await _authCtrl.sendOtpForPasswordReset(email: email);
    if (!ok) {
      setState(() => _bannerError = _authCtrl.error.value);
      return;
    }

    setState(() {
      _stepOtp = true;
      _bannerError = null;
    });

    AppSnackbar.success('OTP sent to your email.');
  }

  Future<void> _verifyOtpAndReset() async {
    setState(() => _bannerError = null);

    if (!_formKeyOtp.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    final ok = await _authCtrl.verifyOtpAndResetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    if (!ok) {
      setState(() => _bannerError = _authCtrl.error.value);
      return;
    }

    AppDialog.showSuccess(
      'Password updated successfully. Please sign in with your new password.',
      title: 'Done',
      confirmLabel: 'Sign In',
      onConfirm: () {
        Get.offNamed(AppRoutes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration:  BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _stepOtp
                          ? 'Enter OTP and set a new password'
                          : 'Enter your email to receive an OTP',
                      style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (_bannerError != null) ...[
                AppDialog.errorBanner(_bannerError!),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              // Step 1: Email
              if (!_stepOtp) ...[
                Form(
                  key: _formKeyEmail,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(
                          hint: 'Enter your email',
                          prefixIconData: Icons.mail_outline_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(v.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Obx(() => ElevatedButton(
                              onPressed: _authCtrl.isLoading.value
                                  ? null
                                  : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _authCtrl.isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],

              // Step 2: OTP + New Password
              if (_stepOtp) ...[
                Form(
                  key: _formKeyOtp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('OTP'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          hint: 'Enter the 6-digit OTP',
                          prefixIconData: Icons.confirmation_number_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter OTP';
                          }
                          if (v.trim().length < 4) {
                            return 'OTP is too short';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _fieldLabel('New Password'),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            onChanged: (_) {
                              if (_bannerError != null) {
                                setState(() => _bannerError = null);
                              }
                            },
                            decoration: _fieldDecorationWithSuffix(
                              hint: 'Enter new password',
                              prefixIconData: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscureNewPassword = !_obscureNewPassword),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 10),
                          // Password requirements hint
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password requirements:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '• Minimum 8 characters',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '• At least one uppercase letter (A-Z)',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '• At least one number (0-9)',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '• At least one special character: ! @ # \$ &',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '• No other special characters allowed',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Obx(() => ElevatedButton(
                              onPressed: _authCtrl.isLoading.value
                                  ? null
                                  : _verifyOtpAndReset,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _authCtrl.isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Verify & Update',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _stepOtp = false;
                            _otpController.clear();
                            _newPasswordController.clear();
                            _bannerError = null;
                          });
                        },
                        child:  Text(
                          'Back',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIconData,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIconData, color: AppColors.textMuted, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE24B4A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFA32D2D),
        fontSize: 12,
      ),
    );
  }

  // Separate decoration method that supports a suffixIcon (used for password fields)
  InputDecoration _fieldDecorationWithSuffix({
    required String hint,
    required IconData prefixIconData,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIconData, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE24B4A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFA32D2D),
        fontSize: 12,
      ),
    );
  }
}
