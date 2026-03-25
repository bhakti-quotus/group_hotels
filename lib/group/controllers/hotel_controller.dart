import 'package:get/get.dart';

class HotelController extends GetxController {
  Rx<Map<String, dynamic>?> currentConfig = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> rootConfig = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedHotel = Rx<Map<String, dynamic>?>(null);

  // Store the entire group config (or latest root-level config)
  void setConfig(Map<String, dynamic> config, {bool isRoot = false}) {
    currentConfig.value = config;
    if (isRoot || rootConfig.value == null) {
      rootConfig.value = config;
    }
  }

  Map<String, dynamic>? getConfig() {
    return currentConfig.value;
  }

  Map<String, dynamic>? getRootConfig() {
    return rootConfig.value;
  }

  bool hasChildHotels() {
    return (currentConfig.value?['childHotels'] as List<dynamic>?)
            ?.isNotEmpty ==
        true;
  }

  bool hasSelectedHotel() {
    return selectedHotel.value != null;
  }

  void clearSelectedHotel() {
    selectedHotel.value = null;
  }

  // Store selected child hotel's complete data (including id, name, type, config, etc.)
  void setSelectedHotel(Map<String, dynamic> hotel) {
    selectedHotel.value = hotel;
  }

  // Get selected child hotel's complete data
  Map<String, dynamic>? getSelectedHotel() {
    return selectedHotel.value;
  }

  // Get the config of the selected hotel
  Map<String, dynamic>? getSelectedHotelConfig() {
    return selectedHotel.value?['config'] as Map<String, dynamic>?;
  }

  // Get list of child hotels
  List<dynamic>? getChildHotels() {
    return currentConfig.value?['childHotels'] as List<dynamic>?;
  }

  // Select a child hotel by ID and store its complete data
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
}
