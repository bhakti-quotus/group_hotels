import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    //isLoggedIn.value = true;
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    isLoggedIn.value = false;
  }
}
