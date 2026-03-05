import 'package:get/get.dart';

class HotelController extends GetxController {
  Rx<Map<String, dynamic>?> currentConfig = Rx<Map<String, dynamic>?>(null);

  void setConfig(Map<String, dynamic> config) {
    currentConfig.value = config;
  }

  Map<String, dynamic>? getConfig() {
    return currentConfig.value;
  }
}
