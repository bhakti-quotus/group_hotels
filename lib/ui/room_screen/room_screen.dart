import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'package:group/group/controllers/search_controller.dart' as search_ctrl;
import 'amenities_widget.dart';
import 'gallery_widget.dart';
import 'rooms_list_widget.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  Map<String, dynamic> data = {};
  List<Map<String, dynamic>> gallery = [];
  final ScrollController _scrollController = ScrollController();
  bool _showGreenStatusBar = false;
  bool _isLoading = false;
  String? _errorMessage;
  String propertyCode = '';
  String hotelName = '';
  Map<String, dynamic> _lastPayload = {};

  @override
  void initState() {
    super.initState();
    _loadDataFromHotelController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataFromHotelController(); // Reload data if config changed
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Change status bar color when scrolled past 200 pixels
    final shouldShowGreen = _scrollController.offset > 20;
    if (shouldShowGreen != _showGreenStatusBar) {
      setState(() {
        _showGreenStatusBar = shouldShowGreen;
      });

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: _showGreenStatusBar
              ? AppColor.primary
              : Colors.transparent,
          statusBarIconBrightness: _showGreenStatusBar
              ? Brightness.light
              : Brightness.dark,
        ),
      );
    }
  }

  void _loadDataFromHotelController() {
    try {
      final hotelController = Get.find<HotelController>();
      
      // First, try to get the selected hotel's complete data
      Map<String, dynamic>? selectedHotel = hotelController.getSelectedHotel();
      
      if (selectedHotel != null && selectedHotel.isNotEmpty) {
        // Use the selected hotel's complete data (includes id, code, name, type, apkName, parentGroupId, config, etc.)
        print('Using selected hotel data: $selectedHotel');
        setState(() {
          data = Map<String, dynamic>.from(selectedHotel);
          
          // Load gallery from hotel's config
          final hotelConfig = selectedHotel['config'];
          if (hotelConfig != null && hotelConfig['gallery'] != null && hotelConfig['gallery']['items'] != null) {
            gallery = (hotelConfig['gallery']['items'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
          }
          
          // Get property code and name from selected hotel
          propertyCode = selectedHotel['code']?.toString() ?? '';
          hotelName = selectedHotel['name']?.toString() ?? '';
        });
        
        // After loading hotel data, fetch rooms from API
        _fetchRoomsFromAPI();
        return;
      }
      
      // Fallback: Get config from hotel controller (group config)
      final config = hotelController.getConfig();
      print('config from hotel controller: $config');
      if (config != null && config.isNotEmpty) {
        setState(() {
          data = Map<String, dynamic>.from(config);
          
          // Load gallery from config
          if (config['gallery'] != null && config['gallery']['items'] != null) {
            gallery = (config['gallery']['items'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
          }
          
          // Get property code and name from config
          propertyCode = config['code']?.toString() ?? '';
          hotelName = config['name']?.toString() ?? '';
        });
        
        // After loading config, fetch rooms from API
        _fetchRoomsFromAPI();
      } else {
        print('No config available from hotel controller');
        setState(() {
          _errorMessage = 'No configuration available';
        });
      }
    } catch (e, stackTrace) {
      print('Error loading room data from hotel controller: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'config_error';
      });
    }
  }

  Future<void> _fetchRoomsFromAPI() async {
    if (propertyCode.isEmpty) {
      print("Property code is empty, cannot fetch rooms");
      setState(() {
        _errorMessage = 'no_property_code';
      });
      return;
    }

    final searchController = Get.find<search_ctrl.AppSearchController>();
    Map<String, dynamic> payload;

    print("RoomScreen - Has search payload: ${searchController.hasSearchPayload()}");
    print("RoomScreen - Search payload: ${searchController.searchPayload.value}");

    if (searchController.hasSearchPayload()) {
      // USE THE PAYLOAD FROM SEARCH CONTROLLER EXACTLY AS IT IS
      payload = searchController.getSearchPayload();
      print("RoomScreen - Using controller payload: $payload");

      // Ensure PropertyCode is set from hotel controller config
      payload["PropertyCode"] = propertyCode;
    } else {
      // Use search payload from hotel controller config if available
      final searchPayloadFromConfig = data['searchPayload'] as Map<String, dynamic>?;
      
      if (searchPayloadFromConfig != null) {
        payload = Map<String, dynamic>.from(searchPayloadFromConfig);
        print("RoomScreen - Using search payload from config: $payload");
        // Ensure PropertyCode is set correctly
        payload["PropertyCode"] = propertyCode;
      } else {
        print("RoomScreen - No search payload in config, cannot fetch rooms");
        setState(() {
          _errorMessage = 'no_search_payload';
        });
        return;
      }
    }

    // Store for retry
    _lastPayload = payload;

    print("RoomScreen - Sending payload to API: ${payload['startDate']} to ${payload['endDate']}");
    
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiController = Get.find<ApiController>();
      final result = await apiController.fetchRooms(payload);
      
      if (!mounted) return;
      
      setState(() {
        Map<String, dynamic>? selectedHotel;
        
        if (result['success']) {
          // Merge API response with existing config data
          final apiData = result['data'] as Map<String, dynamic>;
          
          // Update only the rooms data from API, keep everything else from config
          // Check if rooms exists in API response
          if (apiData['rooms'] != null) {
            data['rooms'] = apiData['rooms'];
          } else {
            // If no rooms from API, try to use rooms from hotel config
            selectedHotel = Get.find<HotelController>().getSelectedHotel();
            if (selectedHotel != null && selectedHotel!['config'] != null) {
              data['rooms'] = selectedHotel!['config']['rooms'] ?? [];
            }
          }
          
          // Update property details if available
          if (apiData['propertyDetails'] != null) {
            data['propertyDetails'] = apiData['propertyDetails'];
          } else {
            selectedHotel = selectedHotel ?? Get.find<HotelController>().getSelectedHotel();
            if (selectedHotel != null && selectedHotel!['config'] != null) {
              // Use hotelId from selected hotel's config
              data['propertyDetails'] = {'id': selectedHotel!['config']['hotelId']};
            }
          }
          
          final rooms = (data['rooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

          if (rooms.isEmpty) {
            _errorMessage = 'no_rooms';
          } else {
            _errorMessage = null;
          }
        } else {
          String error = result['error'];
          if (error.contains('Property not available')) {
            _errorMessage = 'no_rooms';
          } else {
            _errorMessage = 'server_error';
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching rooms: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'server_error';
      });
    }
  }

  Widget _buildEmptyState() {
    if (_errorMessage == null) return const SizedBox.shrink();

    String title, message;
    IconData iconData;

    switch (_errorMessage) {
      case 'no_rooms':
        title = 'No Rooms Available';
        message = 'This property currently has no rooms available for booking.';
        iconData = Icons.hotel_outlined;
        break;
      case 'server_error':
        title = 'Something Went Wrong';
        message = 'We\'re having trouble loading the rooms. Please try again in a moment.';
        iconData = Icons.error_outline;
        break;
      case 'config_error':
        title = 'Configuration Error';
        message = 'Unable to load property configuration.';
        iconData = Icons.settings_outlined;
        break;
      case 'no_property_code':
        title = 'Property Code Missing';
        message = 'Property code is not configured.';
        iconData = Icons.code_off_outlined;
        break;
      case 'no_search_payload':
        title = 'Search Criteria Missing';
        message = 'No search criteria available to fetch rooms.';
        iconData = Icons.search_off_outlined;
        break;
      default:
        title = 'Error';
        message = _errorMessage!;
        iconData = Icons.info_outline;
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage == 'server_error' || _errorMessage == 'no_rooms') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _fetchRoomsFromAPI(),
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: TextStyle(color: AppColor.primary),
                ),
                style: ElevatedButton.styleFrom(
                  iconColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("RoomScreen build called");

    if (data.isEmpty && !_isLoading && _errorMessage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rooms = (data['rooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    
    // Get branding and amenities - check if it's from selected hotel's config or group config
    HotelController hotelController;
    try {
      hotelController = Get.find<HotelController>();
    } catch (e) {
      hotelController = Get.put(HotelController());
    }
    
    Map<String, dynamic>? selectedHotel = hotelController.getSelectedHotel();
    Map<String, dynamic> branding = {};
    List<Map<String, dynamic>> amenities = [];
    
    if (selectedHotel != null && selectedHotel.isNotEmpty && selectedHotel['config'] != null) {
      // Get from selected hotel's config
      branding = selectedHotel['config']['branding'] as Map<String, dynamic>? ?? {};
      amenities = (selectedHotel['config']['amenities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } else if (data.isNotEmpty) {
      // Get from group config
      branding = data['branding'] as Map<String, dynamic>? ?? {};
      amenities = (data['amenities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    }
    
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    // Get total guests from search payload if available
    int totalGuests = 1;
    try {
      final searchController = Get.find<search_ctrl.AppSearchController>();
      if (searchController.searchPayload.isNotEmpty) {
        final payload = Map<String, dynamic>.from(searchController.searchPayload.value);
        final guests = payload['guests'] as Map<String, dynamic>?;
        if (guests != null) {
          totalGuests = (guests['adults'] as int? ?? 0) + (guests['children'] as int? ?? 0);
        }
      } else if (data['searchPayload'] != null) {
        // Fallback to search payload from config
        final guests = data['searchPayload']['guests'] as Map<String, dynamic>?;
        if (guests != null) {
          totalGuests = (guests['adults'] as int? ?? 0) + (guests['children'] as int? ?? 0);
        }
      }
    } catch (e) {
      print("Error getting total guests: $e");
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: AppColor.primary, elevation: 0),
      ),
      body: _isLoading && rooms.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _errorMessage != null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 10),
                      
                      // Rooms List
                      RoomsListWidget(
                        rooms: rooms,
                        totalGuests: totalGuests,
                        propertyCode: propertyCode,
                        hotelName: hotelName,
                        roomKeys: {},
                        errorMessage: _errorMessage,
                        isLoading: _isLoading,
                        onRefresh: _fetchRoomsFromAPI,
                        primaryColor: primaryColor,
                        propertyId: data['propertyDetails']?['id']?.toString() ?? '',
                      ),

                      // Amenities Section
                      if (amenities.isNotEmpty) ...[
                        AmenitiesWidget(amenities: amenities),
                        const SizedBox(height: 12),
                      ],

                      // Gallery Section
                      if (gallery.isNotEmpty) ...[
                        GalleryWidget(gallery: gallery),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
    );
  }
}