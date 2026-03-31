import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'hotel_controller.dart';

class AppSearchController extends GetxController {
  var searchPayload = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPropertyCode();
  }

  void _loadPropertyCode() async {
    try {
      // Check HotelController first for selected child hotel
      final hotelCtrl = Get.find<HotelController>();
      String propertyCode = '';

      if (hotelCtrl.hasSelectedHotel()) {
        final selected = hotelCtrl.getSelectedHotel();
        propertyCode = selected?['code']?.toString() ?? '';
      }

      if (propertyCode.isEmpty) {
        final jsonString = await rootBundle.loadString('assets/config.json');
        final config = json.decode(jsonString);
        propertyCode = config['code'] ?? '';
      }

      // Set default values with property code
      final now = DateTime.now();
      searchPayload.value = {
        "propertyCode": propertyCode,
        "startDate": now
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        "endDate": now
            .add(const Duration(days: 2))
            .toIso8601String()
            .split('T')[0],
        "location": "",
        "numberOfRooms": 1,
        "promocode": "",
        "guests": {
          "adults": 1,
          "children": 0,
          "rooms": 1,
          "roomsArray": [
            {
              "adults": 1,
              "children": 0,
              "childAges": [] // Changed from [0] to empty list
            }
          ]
        },
      };
    } catch (e) {
      // Fallback if config loading fails
      final now = DateTime.now();
      searchPayload.value = {
        "propertyCode": "",
        "startDate": now
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        "endDate": now
            .add(const Duration(days: 2))
            .toIso8601String()
            .split('T')[0],
        "location": "",
        "numberOfRooms": 1,
        "promocode": "",
        "guests": {
          "adults": 1,
          "children": 0,
          "rooms": 1,
          "roomsArray": [
            {
              "adults": 1,
              "children": 0,
              "childAges": [] // Changed from [0] to empty list
            }
          ]
        },
      };
    }
  }

  void updateSearchPayload(Map<String, dynamic> payload) {
   // print("AppSearchController: Updating search payload with: $payload");

    // Create a deep copy to ensure reactivity
    final Map<String, dynamic> newPayload = Map<String, dynamic>.from(payload);

    // Override propertyCode with selected child hotel if available
    final hotelCtrl = Get.find<HotelController>();
    if (hotelCtrl.hasSelectedHotel()) {
      final selected = hotelCtrl.getSelectedHotel();
      final childCode = selected?['code']?.toString();
      if (childCode != null && childCode.isNotEmpty) {
        newPayload["propertyCode"] = childCode;
      }
    }

    // Fallback to config if still empty
    if (newPayload["propertyCode"] == null || newPayload["propertyCode"] == "") {
      try {
        final jsonString = rootBundle.loadString('assets/config.json') as String;
        final config = json.decode(jsonString);
        newPayload["propertyCode"] = config['code'] ?? '';
      } catch (e) {
        newPayload["propertyCode"] = "";
      }
    }

    // Ensure all required fields are present with default values
    newPayload["location"] = newPayload["location"] ?? "";
    newPayload["numberOfRooms"] = newPayload["numberOfRooms"] ?? 1;
    newPayload["promocode"] = newPayload["promocode"] ?? "";

    // Handle guests object properly
    if (newPayload["guests"] != null) {
      // Ensure roomsArray exists and has childAges
      if (newPayload["guests"]["roomsArray"] != null) {
        // Make sure each room in roomsArray has childAges
        final roomsArray = List<Map<String, dynamic>>.from(newPayload["guests"]["roomsArray"]);
        
        for (var room in roomsArray) {
          // Ensure childAges exists and matches children count
          if (!room.containsKey('childAges')) {
            room['childAges'] = [];
          }
          
          // If children count > 0 but childAges is empty or wrong length, initialize with default ages (0)
          if (room['children'] > 0) {
            final currentAges = List<int>.from(room['childAges'] ?? []);
            if (currentAges.length != room['children']) {
              // Create a properly sized list with default age 0
              room['childAges'] = List.generate(room['children'], (_) => 0);
            }
          } else {
            // No children, ensure childAges is empty
            room['childAges'] = [];
          }
        }
        
        newPayload["guests"]["roomsArray"] = roomsArray;
      }
      
      // Calculate totals from roomsArray
      if (newPayload["guests"]["roomsArray"] != null) {
        int totalAdults = 0;
        int totalChildren = 0;
        
        for (var room in newPayload["guests"]["roomsArray"]) {
          totalAdults += room['adults'] as int? ?? 0;
          totalChildren += room['children'] as int? ?? 0;
        }
        
        newPayload["guests"]["adults"] = totalAdults;
        newPayload["guests"]["children"] = totalChildren;
        newPayload["guests"]["rooms"] = newPayload["guests"]["roomsArray"].length;
      }
      
      // Ensure rooms field exists in guests
      newPayload["guests"]["rooms"] = newPayload["guests"]["rooms"] ?? 
                                      newPayload["numberOfRooms"] ?? 1;
    } else {
      // Create guests object if it doesn't exist
      newPayload["guests"] = {
        "adults": newPayload["adults"] ?? 1,
        "children": newPayload["children"] ?? 0,
        "rooms": newPayload["rooms"] ?? 1,
      };
    }

    searchPayload.value = newPayload;
    searchPayload.refresh(); // Force UI update
   // print(
   //   "AppSearchController: Updated search payload: ${searchPayload.value}",
   // );
  }

  // Check if search payload has valid data
  bool hasSearchPayload() {
    return searchPayload.isNotEmpty &&
        searchPayload.value.containsKey('startDate') &&
        searchPayload.value.containsKey('endDate') &&
        searchPayload.value.containsKey('guests');
  }

  // Get the search payload
  Map<String, dynamic> getSearchPayload() {
    return Map<String, dynamic>.from(searchPayload.value);
  }

  // Clear search payload if needed
  void clearSearchPayload() {
    searchPayload.value = {};
  }
  
  // Get promocode specifically
  String getPromocode() {
    return searchPayload.value['promocode'] as String? ?? '';
  }

  // Update promocode only
  void updatePromocode(String promocode) {
    if (searchPayload.isNotEmpty) {
      searchPayload.value['promocode'] = promocode;
      searchPayload.refresh();
    }
  }
  
  // NEW: Validate child ages are within range (0-15)
  bool validateChildAges() {
    if (!hasSearchPayload()) return false;
    
    final guests = searchPayload.value['guests'] as Map<String, dynamic>?;
    if (guests == null) return false;
    
    final roomsArray = guests['roomsArray'] as List?;
    if (roomsArray == null) return true; // No roomsArray means no child ages to validate
    
    for (var room in roomsArray) {
      final childAges = room['childAges'] as List? ?? [];
      for (var age in childAges) {
        if (age is! int || age < 0 || age > 15) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  // NEW: Get all child ages for debugging/validation
  List<int> getAllChildAges() {
    if (!hasSearchPayload()) return [];
    
    final guests = searchPayload.value['guests'] as Map<String, dynamic>?;
    if (guests == null) return [];
    
    final roomsArray = guests['roomsArray'] as List?;
    if (roomsArray == null) return [];
    
    List<int> allAges = [];
    for (var room in roomsArray) {
      final childAges = room['childAges'] as List? ?? [];
      allAges.addAll(childAges.cast<int>());
    }
    
    return allAges;
  }
}