import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/hive_service.dart';

class ApiController extends GetxController {
  final HiveService hiveService = Get.find<HiveService>();

  final String _baseUrl = '';
  final String _pmsUrl = '';

  bool _configLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _loadConfig(); // fire and forget
  }

  Future<void> _loadConfig() async {
    if (_configLoaded) return; // prevent reloading

    final data = await rootBundle.loadString('assets/config.json');
    final jsonMap = json.decode(data);

    // Load both URLs
    // _baseUrl = jsonMap['config']['extranet']['url'];
    // _pmsUrl = jsonMap['config']['pms']['url'];

    // print('Extranet base url: $_baseUrl');
    //print('PMS url: $_pmsUrl');

    _configLoaded = true;
  }

  /// Ensures config is loaded before any API call
  Future<void> _ensureConfigLoaded() async {
    if (!_configLoaded) {
      await _loadConfig();
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> fetchRooms(Map<String, dynamic> payload) async {
    await _ensureConfigLoaded();
    // print('api url for fetch room $_baseUrl/booking-engine/fetch-rooms');
   // print('fetchroom method called');
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/booking-engine/fetch-rooms',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));

//print('payload for fetch room: $payload');
      final decoded = json.decode(response.body);
      //print('fetch room response: $decoded');

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {
          'success': true,
          'data': {
            'propertyDetails': decoded['data']['propertyDetails'],
            'rooms': decoded['data']['rooms'],
            'searchCriteria': decoded['data']['searchCriteria'],
          },
        };
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to fetch rooms',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> getPrice(Map<String, dynamic> payload) async {
    await _ensureConfigLoaded();

    try {
      // Print the payload being sent
     // print('========== GET PRICE PAYLOAD ==========');
      //print(
      //  'URL: https://bookings.revchilltech.com/api/v1/booking-engine/pricing/get-price',
      //);
     // print('Payload: ${json.encode(payload)}');
     // print('Formatted Payload:');
      _prettyPrintJson(payload);
     // print('=======================================');
      final response = await http
          .post(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/booking-engine/pricing/get-price',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = json.decode(response.body);
      // Print the response
     // print('========== GET PRICE RESPONSE ==========');
     // print('Status Code: ${response.statusCode}');
     // print('Response Body: ${response.body}');
     // print('Formatted Response:');
      _prettyPrintJson(decoded);
     // print('========================================');

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to get price',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // Helper method to pretty print JSON
  void _prettyPrintJson(Map<String, dynamic> json) {
    try {
      String prettyString = const JsonEncoder.withIndent('  ').convert(json);
     // print(prettyString);
    } catch (e) {
     // print('Error formatting JSON: $e');
     // print(json);
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> fetchPaymentDetails(String propertyId) async {
    await _ensureConfigLoaded();

    try {
     // print("propertyId from controller : $propertyId");
      final response = await http
          .get(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/property-management/property/$propertyId/payment-details',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      final decoded = json.decode(response.body);
     // print(decoded);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to fetch payment details',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> completeBooking(
    Map<String, dynamic> payload,
  ) async {
    await _ensureConfigLoaded();

    try {
     // print('=== COMPLETE BOOKING DEBUG ===');
     // print('Payload being sent: ${json.encode(payload)}');

      final response = await http
          .post(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/pms/front-office/reservations',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      //print('Status code: ${response.statusCode}');
      //print('Response body: ${response.body}');

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        try {
         // print('Saving to Hive...');
          await hiveService.saveBooking(decoded);
         // print('Hive save successful');
          return {'success': true, 'data': decoded['data']};
        } catch (hiveError) {
         // print('Hive save failed: $hiveError');
          // Still return success since API call worked
          return {'success': true, 'data': decoded['data']};
        }
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to complete booking',
      };
    } catch (e) {
     // print('Exception in completeBooking: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }
  // ----------------------------------------------------------

  Future<Map<String, dynamic>> checkInReservation(
    String reservationCode,
    Map<String, Map<String, dynamic>> guestDocument,
  ) async {
    await _ensureConfigLoaded();

    try {
      // Convert the nested map to JSON
      final payload = {'guestDocument': guestDocument};
      final requestBody = json.encode(payload);

      // Print the request body being sent
     // print('=== REQUEST ===');
     // print(
     //   'URL: $_pmsUrl/pms/front-office/reservations/check-in/$reservationCode',
     // );
     // print('Method: POST');
     // print('Headers: {\'Content-Type\': \'application/json\'}');
     // print('Request Body: $requestBody');

      final uri = Uri.parse(
        '$_pmsUrl/pms/front-office/reservations/check-in/$reservationCode',
      );

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 15));

      // Print the response received
     // print('\n=== RESPONSE ===');
     // print('Status Code: ${response.statusCode}');
     // print('Response Headers: ${response.headers}');
     // print('Response Body: ${response.body}');
     // print('================\n');

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Check-in completed successfully',
          'data': decoded['data'],
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to complete check-in',
      };
    } catch (e) {
     // print('\n=== ERROR ===');
     // print('Error: $e');
     // print('=============\n');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> chatWithSSE(
    Map<String, dynamic> payload,
    Function(String event, Map<String, dynamic> data) onEvent,
    Function(String error) onError,
    Function() onDone,
  ) async {
    await _ensureConfigLoaded();

    try {
      final client = http.Client();

      final request = http.Request(
        'POST',
        Uri.parse(
          'https://disyllabic-christene-siphonophorous.ngrok-free.dev/chat',
        ),
      );

      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      request.body = json.encode(payload);

      final response = await client.send(request);

      if (response.statusCode != 200) {
        onError('Failed to connect: ${response.statusCode}');
        client.close();
        return;
      }

      String currentEvent = 'message';

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.isEmpty) {
                currentEvent = 'message';
                return;
              }

              if (line.startsWith('event: ')) {
                currentEvent = line.substring(7).trim();
              } else if (line.startsWith('data: ')) {
                final dataStr = line.substring(6).trim();
                try {
                  final data = json.decode(dataStr) as Map<String, dynamic>;
                  onEvent(currentEvent, data);
                } catch (e) {
                 // print('Error parsing SSE data: $e');
                 // print('Raw data: $dataStr');
                }
              }
            },
            onError: (error) {
              onError('Stream error: $error');
              client.close();
            },
            onDone: () {
              onDone();
              client.close();
            },
            cancelOnError: false,
          );
    } catch (e) {
      onError('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> setBokingState(
    Map<String, dynamic> payload,
  ) async {
    await _ensureConfigLoaded();

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://disyllabic-christene-siphonophorous.ngrok-free.dev/booking/state',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to set the booking state',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> getAvailableAddons({
    required String propertyCode,
    required String startDate,
    required String endDate,
    required String ratePlanCode,
  }) async {
    await _ensureConfigLoaded();

    try {
      final queryParams = {
        'propertyCode': propertyCode,
        'startDate': startDate,
        'endDate': endDate,
        'ratePlanCode': ratePlanCode,
      };

      final uri = Uri.parse(
        'https://bookings.revchilltech.com/api/v1/addon/addon-datewise/available',
      ).replace(queryParameters: queryParams);

     // print('Addon API URL: $uri');

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

     // print('Addon API Response: ${response.statusCode} - ${response.body}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to fetch addons',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // Add this method to your existing ApiController class

  Future<Map<String, dynamic>> fetchBookingDetails({
    required String bookingCode,
    required String propertyCode,
  }) async {
    await _ensureConfigLoaded();

    try {
      final uri = Uri.parse(
        'https://bookings.revchilltech.com/api/v1/pms/front-office/reservations/$bookingCode',
      ).replace(queryParameters: {'propertyCode': propertyCode});

     // print('Fetching booking details from: $uri');

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      //print(
      //  'Booking details response: ${response.statusCode} - ${response.body}',
     // );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to fetch booking details',
      };
    } catch (e) {
      //print('Error fetching booking details: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> updateBooking({
    required String bookingCode,
    required Map<String, dynamic> payload,
  }) async {
    await _ensureConfigLoaded();

    try {
     // print('=== UPDATE BOOKING DEBUG ===');
     // print('Booking Code: $bookingCode');
     // print('Payload being sent: ${json.encode(payload)}');

      final response = await http
          .patch(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/pms/front-office/reservations/update/$bookingCode',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

     // print('Status code: ${response.statusCode}');
     // print('Response body: ${response.body}');

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to update booking',
      };
    } catch (e) {
      //print('Exception in updateBooking: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ----------------------------------------------------------

  Future<Map<String, dynamic>> cancelBooking({
    required String reservationId,
    required Map<String, dynamic> payload,
  }) async {
    await _ensureConfigLoaded();

    try {
     // print('=== CANCEL BOOKING DEBUG ===');
     // print('Reservation ID: $reservationId');
    //  print('Payload being sent: ${json.encode(payload)}');

      final response = await http
          .put(
            Uri.parse(
              'https://bookings.revchilltech.com/api/v1/pms/front-office/reservations/cancel/$reservationId',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

     // print('Status code: ${response.statusCode}');
     // print('Response body: ${response.body}');

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return {'success': true, 'data': decoded['data']};
      }

      return {
        'success': false,
        'error': decoded['message'] ?? 'Failed to cancel booking',
      };
    } catch (e) {
     // print('Exception in cancelBooking: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }
}
