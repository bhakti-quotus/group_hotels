import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';

class GroupWebRoomChildLoginPage extends StatefulWidget {
  const GroupWebRoomChildLoginPage({super.key});

  @override
  State<GroupWebRoomChildLoginPage> createState() =>
      _GroupWebRoomChildLoginPageState();
}

class _GroupWebRoomChildLoginPageState
    extends State<GroupWebRoomChildLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Validation error messages
  String? _emailError;
  String? _passwordError;

  // Email validation regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation: at least 6 chars, one uppercase, one special character
  bool _isValidPassword(String password) {
    if (password.length < 6) return false;
    
    // Check for at least one uppercase letter
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    
    // Check for at least one special character
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasUppercase && hasSpecialChar;
  }

  // Get password error message
  String? _getPasswordErrorMessage(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Validate email field
  void _validateEmail() {
    setState(() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'Email address is required';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  // Validate password field
  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;
      _passwordError = _getPasswordErrorMessage(password);
    });
  }

  // Validate all fields
  bool _validateForm() {
    _validateEmail();
    _validatePassword();
    return _emailError == null && _passwordError == null;
  }

  void _handleLogin() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate fields
    if (!_validateForm()) {
      // Show snackbar for additional feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Please fix the errors above')),
            ],
          ),
          backgroundColor: AppColor.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500), () {
      try {
        final hotelController = Get.find<HotelController>();
        hotelController.isRegistered.value = true;
        
        // You can store email/password if needed
        // hotelController.userEmail.value = email;
        
        Get.offNamed(AppRoutes.webroomChildHome);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  void _handleSkip() {
    try {
      final hotelController = Get.find<HotelController>();
      hotelController.isRegistered.value = false;
      Get.offNamed(AppRoutes.webroomChildHome);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();
    final selectedHotel = hotelController.getSelectedHotel();
    final hotelLogo =
        (selectedHotel?['config'] as Map<String, dynamic>?)?['branding']
            ?['logo'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Top hero image section ──────────────────────────────────────
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  'assets/images/login-bg.png',
                  fit: BoxFit.cover,
                ),

                // Black overlay for better text/logo visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5), // Darker at top
                        Colors.black.withOpacity(0), // Medium in middle
                        Colors.black.withOpacity(0.2), // Lighter at bottom
                      ],
                    ),
                  ),
                ),

                // Skip button in top right corner
                Positioned(
                  top: 36,
                  right: 16,
                  child: GestureDetector(
                    onTap: _handleSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF003087),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo centered in the image with improved background
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: hotelLogo != null && hotelLogo.isNotEmpty
                        ? Image.network(
                            hotelLogo,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/hotel_logo.png',
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/images/hotel_logo.png',
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),

                // Bottom rounded white curve
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom form section ─────────────────────────────────────────
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sign in heading
                  const Text(
                    'Sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF003087),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email field with validation
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: AppColor.primary,
                    onChanged: (value) {
                      if (_emailError != null) {
                        _validateEmail();
                      }
                    },
                    onEditingComplete: _validateEmail,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      errorText: _emailError,
                      errorStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColor.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password field with validation
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    cursorColor: AppColor.primary,
                    onChanged: (value) {
                      if (_passwordError != null) {
                        _validatePassword();
                      }
                    },
                    onEditingComplete: _validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      errorText: _passwordError,
                      errorStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColor.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot password (static)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement forgot password functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Forgot password feature coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LOGIN button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8414A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFFE8414A).withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional info text
                  Center(
                    child: Text(
                      'By signing in, you agree to our Terms & Conditions',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}