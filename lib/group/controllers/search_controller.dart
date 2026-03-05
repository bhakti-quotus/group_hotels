import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppSearchController extends GetxController {
  var searchPayload = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPropertyCode();
  }

  void _loadPropertyCode() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      final config = json.decode(jsonString);
      final propertyCode = config['code'] ?? '';

      // Set default values with property code
      final now = DateTime.now();
      searchPayload.value = {
        "PropertyCode": propertyCode,
        "startDate": now
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        "endDate": now
            .add(const Duration(days: 2))
            .toIso8601String()
            .split('T')[0],
        "adults": 1,
        "children": 0,
        "rooms": 1,
        "location": "",
        "numberOfRooms": 1,
        // UPDATED: Include promocode in default payload
        "promocode": "",
        "guests": {
          "adults": 1,
          "children": 0,
          "rooms": 1,
          "roomsArray": [
            {"adults": 1, "children": 0}
          ],
        },
      };
    } catch (e) {
      // Fallback if config loading fails
      final now = DateTime.now();
      searchPayload.value = {
        "PropertyCode": "",
        "startDate": now
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        "endDate": now
            .add(const Duration(days: 2))
            .toIso8601String()
            .split('T')[0],
        "adults": 1,
        "children": 0,
        "rooms": 1,
        "location": "",
        "numberOfRooms": 1,
        // UPDATED: Include promocode in fallback payload
        "promocode": "",
        "guests": {
          "adults": 1,
          "children": 0,
          "rooms": 1,
          "roomsArray": [
            {"adults": 1, "children": 0}
          ],
        },
      };
    }
  }

  // UPDATED: Ensure promocode is properly handled
  void updateSearchPayload(Map<String, dynamic> payload) {
    print("AppSearchController: Updating search payload with: $payload");

    // Create a deep copy to ensure reactivity
    final Map<String, dynamic> newPayload = Map<String, dynamic>.from(payload);

    // Ensure PropertyCode is always set
    if (newPayload["PropertyCode"] == null ||
        newPayload["PropertyCode"] == "") {
      try {
        final jsonString =
            rootBundle.loadString('assets/config.json') as String;
        final config = json.decode(jsonString);
        newPayload["PropertyCode"] = config['code'] ?? '';
      } catch (e) {
        newPayload["PropertyCode"] = "";
      }
    }

    // Ensure all required fields are present with default values
    newPayload["location"] = newPayload["location"] ?? "";
    newPayload["numberOfRooms"] = newPayload["numberOfRooms"] ?? 1;
    // UPDATED: Ensure promocode exists
    newPayload["promocode"] = newPayload["promocode"] ?? "";
    newPayload["adults"] = newPayload["adults"] ?? 
        (newPayload["guests"]?["adults"] ?? 1);
    newPayload["children"] = newPayload["children"] ?? 
        (newPayload["guests"]?["children"] ?? 0);
    newPayload["rooms"] = newPayload["rooms"] ?? 
        (newPayload["guests"]?["rooms"] ?? 1);

    // Ensure guests object is present with roomsArray
    if (newPayload["guests"] == null) {
      newPayload["guests"] = {
        "adults": newPayload["adults"] ?? 1,
        "children": newPayload["children"] ?? 0,
        "rooms": newPayload["rooms"] ?? 1,
        "roomsArray": [
          {"adults": newPayload["adults"] ?? 1, "children": newPayload["children"] ?? 0},
        ],
      };
    } else {
      // Ensure roomsArray exists in guests
      if (newPayload["guests"]["roomsArray"] == null) {
        newPayload["guests"]["roomsArray"] = List.generate(
          newPayload["guests"]["rooms"] ?? 1,
          (_) => {
            "adults": newPayload["guests"]["adults"] ?? 1,
            "children": newPayload["guests"]["children"] ?? 0,
          },
        );
      }
    }

    searchPayload.value = newPayload;
    searchPayload.refresh(); // Force UI update
    print(
      "AppSearchController: Updated search payload: ${searchPayload.value}",
    );
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
  
  // ADDED: Get promocode specifically
  String getPromocode() {
    return searchPayload.value['promocode'] as String? ?? '';
  }

  // ADDED: Update promocode only
  void updatePromocode(String promocode) {
    if (searchPayload.isNotEmpty) {
      searchPayload.value['promocode'] = promocode;
      searchPayload.refresh();
    }
  }
}