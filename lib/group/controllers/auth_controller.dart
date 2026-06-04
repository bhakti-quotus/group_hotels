import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:royalcontinent/group/controllers/api_controller.dart';
import 'package:royalcontinent/group/utils/app_routes.dart';
import 'package:royalcontinent/group/utils/app_snackbar.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final RxBool isLoggedIn = false.obs;
  final RxString accessToken = ''.obs;
  final RxString sessionCookie = ''.obs;
  final RxString customerId = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString mobilePhone = ''.obs;
  final RxString userRole = 'Customer'.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool authInitialized = false.obs;

  late final ApiController _apiController;

  @override
  void onInit() {
    super.onInit();
    // Use Get.find to fetch ApiController when needed to prevent dependency cycle
    _apiController = Get.find<ApiController>();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken.value = prefs.getString('accessToken') ?? '';
    sessionCookie.value = prefs.getString('sessionCookie') ?? '';
    customerId.value = prefs.getString('customerId') ?? '';
    firstName.value = prefs.getString('firstName') ?? '';
    lastName.value = prefs.getString('lastName') ?? '';
    email.value = prefs.getString('email') ?? '';
    mobilePhone.value = prefs.getString('mobilePhone') ?? '';
    userRole.value = prefs.getString('userRole') ?? 'Customer';

    isLoggedIn.value = accessToken.value.isNotEmpty || sessionCookie.value.isNotEmpty;

    if (isLoggedIn.value) {
      // Token exists — validate in background, THEN set initialized
      final ok = await refreshCurrentUser();
      if (!ok) await logout(showExpiredMessage: true);
      authInitialized.value = true; // ← only delayed for logged-in users
    } else {
      authInitialized.value = true; // ← instant for logged-out users
    }
  }

  Future<bool> refreshCurrentUser() async {
    try {
      final result = await _apiController.fetchUserDetails();
      if (result['success'] == true && result['data'] is Map) {
        final prefs = await SharedPreferences.getInstance();
        await _saveUserDetails(
            Map<String, dynamic>.from(result['data']), prefs);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Rxn<String> redirectRoute = Rxn<String>();
  Rxn<dynamic> redirectArgs = Rxn<dynamic>();

  void setRedirect({String? route, dynamic args}) {
    redirectRoute.value = route;
    redirectArgs.value = args;
  }

  bool ensureLoggedIn({
    String message = 'Please log in to continue',
    String? redirectTo,
    dynamic args,
  }) {
    if (isLoggedIn.value) return true;
    AppSnackbar.info(message);

    // Store where the user should go after login.
    setRedirect(route: redirectTo, args: args);

    Get.toNamed(AppRoutes.login);
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _apiController.registerCustomer({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });

      if (result['success'] == true) {
        // Handle response similar to login - auto-login after registration
        final message = (result['message'] as String?)?.trim();
        if (message != null && message.isNotEmpty) {
          AppSnackbar.success(message);
        }

        final dataDynamic = result['data'];
        Map<String, dynamic> data = {};
        if (dataDynamic is Map) {
          data = Map<String, dynamic>.from(dataDynamic as Map);
        }

        // Extract token from response (same as login)
        String token = (data['accessToken'] as String?) ??
            (data['token'] as String?) ??
            ((data['user'] is Map)
                ? (data['user'] as Map)['accessToken'] as String?
                : null) ??
            ((data['customer'] is Map)
                ? (data['customer'] as Map)['accessToken'] as String?
                : null) ??
            '';

        final prefs = await SharedPreferences.getInstance();
        isLoggedIn.value = true;

        if (token.isNotEmpty) {
          await prefs.setString('accessToken', token);
          accessToken.value = token;
        }

        // Save user details (same as login)
        await _saveUserDetails(data, prefs);

        // Handle cookie if present (same as login)
        if (result['cookie'] is String &&
            (result['cookie'] as String).isNotEmpty) {
          final cookieValue = result['cookie'] as String;
          await prefs.setString('sessionCookie', cookieValue);
          sessionCookie.value = cookieValue;

          if (token.isEmpty) {
            final cookieToken = _extractTokenFromCookie(cookieValue);
            if (cookieToken.isNotEmpty) {
              token = cookieToken;
              await prefs.setString('accessToken', token);
              accessToken.value = token;
            }
          }
        }

        // Fetch and save complete user details (same as login)
        final userResult = await _apiController.fetchUserDetails();
        if (userResult['success'] == true) {
          final userDataDynamic = userResult['data'];
          if (userDataDynamic is Map) {
            final userData = Map<String, dynamic>.from(userDataDynamic);
            await _saveUserDetails(userData, prefs);
          }
        }

        return true;
      } else {
        // Handle error response (same as login)
        final message = (result['message'] as String?) ??
            (result['error'] as String?) ??
            'Registration failed';
        error.value = message;
        return false;
      }
    } catch (e) {
      const message = 'An unexpected error occurred. Please try again.';
      error.value = message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String get fullName {
    final first = firstName.value.trim();
    final last = lastName.value.trim();
    if (first.isEmpty && last.isEmpty) return '';
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  String get greetingName {
    if (firstName.value.isNotEmpty) return firstName.value;
    if (email.value.isNotEmpty) return email.value.split('@').first;
    return 'Guest';
  }

  String get displayRole =>
      userRole.value.isNotEmpty ? userRole.value : 'Customer';

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _apiController.loginCustomer({
        'email': email,
        'password': password,
      });

      if (result['success'] == true) {
        final message = (result['message'] as String?)?.trim();
        if (message != null && message.isNotEmpty) {
          AppSnackbar.success(message);
        }

        final dataDynamic = result['data'];
        Map<String, dynamic> data = {};
        if (dataDynamic is Map) {
          data = Map<String, dynamic>.from(dataDynamic as Map);
        }

        String token = (data['accessToken'] as String?) ??
            (data['token'] as String?) ??
            ((data['user'] is Map)
                ? (data['user'] as Map)['accessToken'] as String?
                : null) ??
            ((data['customer'] is Map)
                ? (data['customer'] as Map)['accessToken'] as String?
                : null) ??
            '';

        final prefs = await SharedPreferences.getInstance();
        isLoggedIn.value = true;

        await prefs.setString('accessToken', token);
        accessToken.value = token;

        await _saveUserDetails(data, prefs);

        if (result['cookie'] is String &&
            (result['cookie'] as String).isNotEmpty) {
          final cookieValue = result['cookie'] as String;
          await prefs.setString('sessionCookie', cookieValue);
          sessionCookie.value = cookieValue;

          if (token.isEmpty) {
            final cookieToken = _extractTokenFromCookie(cookieValue);
            if (cookieToken.isNotEmpty) {
              token = cookieToken;
              await prefs.setString('accessToken', token);
              accessToken.value = token;
            }
          }
        }

        final userResult = await _apiController.fetchUserDetails();
        if (userResult['success'] == true) {
          final userDataDynamic = userResult['data'];
          if (userDataDynamic is Map) {
            final userData = Map<String, dynamic>.from(userDataDynamic);
            await _saveUserDetails(userData, prefs);
          }
        }

        return true;
      } else {
        final message = (result['message'] as String?) ??
            (result['error'] as String?) ??
            'Login failed';
        error.value = message;
        return false;
      }
    } catch (e) {
      const message = 'An unexpected error occurred. Please try again.';
      error.value = message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserDetails(
      Map<String, dynamic> data, SharedPreferences prefs) async {
    final userData = _extractUserData(data);
    final userCustomerId = userData['customerId'] ?? '';
    firstName.value = userData['firstName'] ?? '';
    lastName.value = userData['lastName'] ?? '';
    email.value = userData['email'] ?? '';
    mobilePhone.value = userData['mobilePhone'] ?? '';
    userRole.value = userData['userRole'] ?? 'Customer';
    customerId.value = userCustomerId;

    await prefs.setString('customerId', userCustomerId);
    await prefs.setString('firstName', firstName.value);
    await prefs.setString('lastName', lastName.value);
    await prefs.setString('email', email.value);
    await prefs.setString('mobilePhone', mobilePhone.value);
    await prefs.setString('userRole', userRole.value);
  }

  String _extractTokenFromCookie(String cookie) {
    final parts = cookie.split(';');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final keyValue = trimmed.split('=');
      if (keyValue.length < 2) continue;
      final name = keyValue.first.trim();
      final value = keyValue.sublist(1).join('=').trim();
      if (name == 'revvChillOtaAccess' && value.isNotEmpty) return value;
    }
    if (parts.isNotEmpty) {
      final firstPair = parts.first.trim().split('=');
      if (firstPair.length >= 2) return firstPair.sublist(1).join('=').trim();
    }
    return '';
  }

  Map<String, String> _extractUserData(Map<String, dynamic> data) {
    var payload = data;
    if (payload.containsKey('user') && payload['user'] is Map) {
      payload = Map<String, dynamic>.from(payload['user'] as Map);
    } else if (payload.containsKey('customer') && payload['customer'] is Map) {
      payload = Map<String, dynamic>.from(payload['customer'] as Map);
    }
    return {
      'customerId': payload['id']?.toString() ?? payload['customerId']?.toString() ?? '',
      'firstName': payload['firstName']?.toString() ?? '',
      'lastName': payload['lastName']?.toString() ?? '',
      'email': payload['email']?.toString() ?? '',
      'mobilePhone': payload['mobilePhone']?.toString() ??
          payload['phone']?.toString() ??
          '',
      'userRole': payload['role']?.toString() ??
          payload['userRole']?.toString() ??
          'Customer',
    };
  }

  Future<void> logout({bool showExpiredMessage = false, bool navigateToHome = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('sessionCookie');
    await prefs.remove('customerId');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('email');
    await prefs.remove('mobilePhone');
    await prefs.remove('userRole');
    accessToken.value = '';
    sessionCookie.value = '';
    customerId.value = '';
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    mobilePhone.value = '';
    userRole.value = 'Customer';
    isLoggedIn.value = false;

    if (showExpiredMessage) {
      AppSnackbar.warning(
        'Your session has expired. Please sign in again.',
        actionLabel: 'OK',
      );
    }

    // Navigate to group home after logout
    if (navigateToHome) {
      Get.offAllNamed(AppRoutes.groupHome);
    }
  }

  /// Send OTP to email for password reset.
  Future<bool> sendOtpForPasswordReset({required String email}) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _apiController.sendOtp(email: email);
      if (result['success'] == true) {
        return true;
      }
      error.value = result['message'] ?? result['error'] ?? 'Failed to send OTP';
      return false;
    } catch (_) {
      error.value = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP and set new password.
  Future<bool> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _apiController.verifyOtp(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        return true;
      }

      error.value = result['message'] ?? result['error'] ?? 'Failed to verify OTP';
      return false;
    } catch (_) {
      error.value = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}


