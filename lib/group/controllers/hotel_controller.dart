import 'package:get/get.dart';

class HotelController extends GetxController {
  Rx<Map<String, dynamic>?> currentConfig = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> rootConfig = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedHotel = Rx<Map<String, dynamic>?>(null);
  RxBool isRegistered = false.obs;

  // NEW — full flat list of child hotels, set by SearchWidget._loadConfig
  // so RoomsListWidget can read it reactively via Obx
  final RxList<dynamic> childHotels = <dynamic>[].obs;

  void setConfig(Map<String, dynamic> config, {bool isRoot = false}) {
    currentConfig.value = config;
    if (isRoot || rootConfig.value == null) {
      rootConfig.value = config;
    }
  }

  Map<String, dynamic>? getConfig() => currentConfig.value;

  Map<String, dynamic>? getRootConfig() => rootConfig.value;

  bool hasChildHotels() =>
      (currentConfig.value?['childHotels'] as List<dynamic>?)?.isNotEmpty ==
      true;

  bool hasSelectedHotel() => selectedHotel.value != null;

  void clearSelectedHotel() => selectedHotel.value = null;

  void setSelectedHotel(Map<String, dynamic> hotel) {
    selectedHotel.value = hotel;
  }

  Map<String, dynamic>? getSelectedHotel() => selectedHotel.value;

  Map<String, dynamic>? getSelectedHotelConfig() =>
      selectedHotel.value?['config'] as Map<String, dynamic>?;

  List<dynamic>? getChildHotels() =>
      currentConfig.value?['childHotels'] as List<dynamic>?;

  void selectHotelById(String hotelId) {
    final childHotels = getChildHotels();
    if (childHotels != null) {
      for (var hotel in childHotels) {
        if (hotel['id'] == hotelId) {
          setSelectedHotel(hotel as Map<String, dynamic>);
          break;
        }
      }
    }
  }

  // NEW — called by SearchWidget._loadConfig after reading config.json
  void setChildHotels(List<dynamic> hotels) {
    childHotels.assignAll(hotels);
  }
}