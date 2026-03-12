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
import 'search_widget.dart'; // ← import your SearchWidget

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
  String _loadedPropertyCode = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadDataFromHotelController();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowGreen = _scrollController.offset > 20;
    if (shouldShowGreen != _showGreenStatusBar) {
      setState(() => _showGreenStatusBar = shouldShowGreen);
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
      final selectedHotel = hotelController.getSelectedHotel();

      if (selectedHotel == null || selectedHotel.isEmpty) {
        setState(() => _errorMessage = 'config_error');
        return;
      }

      final currentCode = (selectedHotel['code'] ?? selectedHotel['id'] ?? '')
          .toString();

      if (_loadedPropertyCode == currentCode && data.isNotEmpty) {
        return;
      }

      final hotelConfig =
          selectedHotel['config'] as Map<String, dynamic>? ?? {};
      BrandingColors.loadFromConfig(hotelConfig);

      setState(() {
        data = Map<String, dynamic>.from(hotelConfig);
        _errorMessage = null;

        final galleryItems = hotelConfig['gallery']?['items'] as List<dynamic>?;
        gallery = galleryItems?.cast<Map<String, dynamic>>() ?? [];

        propertyCode =
            (selectedHotel['code'] ??
                    hotelConfig['code'] ??
                    hotelConfig['propertyDetails']?['code'] ??
                    selectedHotel['id'] ??
                    '')
                .toString();

        hotelName = selectedHotel['name']?.toString() ?? '';
        _loadedPropertyCode = propertyCode;
      });

      if (propertyCode.isNotEmpty) {
        _fetchRoomsFromAPI();
      } else {
        setState(() => _errorMessage = 'no_property_code');
      }
    } catch (e, stackTrace) {
      print("ERROR in _loadDataFromHotelController: $e\n$stackTrace");
      setState(() => _errorMessage = 'config_error');
    }
  }

  Future<void> _fetchRoomsFromAPI() async {
    if (propertyCode.isEmpty) {
      setState(() => _errorMessage = 'no_property_code');
      return;
    }

    final searchController = Get.find<search_ctrl.AppSearchController>();
    Map<String, dynamic> payload;

    if (searchController.hasSearchPayload()) {
      payload = searchController.getSearchPayload();
      payload["propertyCode"] = propertyCode;
    } else {
      final searchPayloadFromConfig =
          data['searchPayload'] as Map<String, dynamic>?;
      if (searchPayloadFromConfig != null) {
        payload = Map<String, dynamic>.from(searchPayloadFromConfig);
        payload["propertyCode"] = propertyCode;
      } else {
        setState(() => _errorMessage = 'no_search_payload');
        return;
      }
    }

    _lastPayload = payload;

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
        if (result['success']) {
          final apiData = result['data'] as Map<String, dynamic>;

          if (apiData['rooms'] != null) {
            data['rooms'] = apiData['rooms'];
          } else {
            final selectedHotel = Get.find<HotelController>()
                .getSelectedHotel();
            data['rooms'] = selectedHotel?['config']?['rooms'] ?? [];
          }

          if (apiData['propertyDetails'] != null) {
            data['propertyDetails'] = apiData['propertyDetails'];
          } else {
            final selectedHotel = Get.find<HotelController>()
                .getSelectedHotel();
            data['propertyDetails'] = {
              'id': selectedHotel?['config']?['hotelId'] ?? '',
            };
          }

          final rooms =
              (data['rooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [];
          _errorMessage = rooms.isEmpty ? 'no_rooms' : null;
        } else {
          final error =
              result['error']?.toString() ??
              result['message']?.toString() ??
              '';
          _errorMessage =
              (error.contains('Property not available') ||
                  error.contains('Property or configuration not found'))
              ? 'no_rooms'
              : 'server_error';
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

  /// Called by SearchWidget's "UPDATE SEARCH" button.
  /// The widget has already saved the new payload into AppSearchController,
  /// so we just re-fetch rooms with whatever is in the controller.
  void _onSearchModified() {
    _fetchRoomsFromAPI();
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
        message =
            'We\'re having trouble loading the rooms. Please try again in a moment.';
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
            if (_errorMessage == 'server_error' ||
                _errorMessage == 'no_rooms') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _loadedPropertyCode = '';
                  });
                  _loadDataFromHotelController();
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: TextStyle(color: AppColor.primary),
                ),
                style: ElevatedButton.styleFrom(
                  iconColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
    if (data.isEmpty && !_isLoading && _errorMessage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rooms =
        (data['rooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    HotelController hotelController;
    try {
      hotelController = Get.find<HotelController>();
    } catch (e) {
      hotelController = Get.put(HotelController());
    }

    final selectedHotel = hotelController.getSelectedHotel();
    Map<String, dynamic> branding = {};
    List<Map<String, dynamic>> amenities = [];

    if (selectedHotel != null && selectedHotel['config'] != null) {
      branding =
          selectedHotel['config']['branding'] as Map<String, dynamic>? ?? {};
      amenities =
          (selectedHotel['config']['amenities'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } else if (data.isNotEmpty) {
      branding = data['branding'] as Map<String, dynamic>? ?? {};
      amenities =
          (data['amenities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
          [];
    }

    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    int totalGuests = 1;
    try {
      final searchController = Get.find<search_ctrl.AppSearchController>();
      final payload = searchController.hasSearchPayload()
          ? searchController.getSearchPayload()
          : data['searchPayload'] as Map<String, dynamic>?;
      if (payload != null) {
        final guests = payload['guests'] as Map<String, dynamic>?;
        if (guests != null) {
          totalGuests =
              (guests['adults'] as int? ?? 0) +
              (guests['children'] as int? ?? 0);
          if (totalGuests == 0) totalGuests = 1;
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
      body: Column(
        children: [
          // ── STATUS BAR SAFE AREA ──────────────────────────────────────
          SizedBox(height: MediaQuery.of(context).padding.top),

          // ── SEARCH WIDGET (pinned at top, outside scroll) ─────────────
          SearchWidget(
            update: true, // tells widget we're in "update" mode
            showEditText:
                true, // shows "UPDATE SEARCH" instead of "SEARCH ROOMS"
            onModifySearch: _onSearchModified, // re-fetch when user updates
          ),

          // ── BODY ──────────────────────────────────────────────────────
          Expanded(
            child: _isLoading && rooms.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _errorMessage != null
                ? _buildEmptyState()
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
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
                          propertyId:
                              data['propertyDetails']?['id']?.toString() ?? '',
                        ),

                        // Amenities
                        if (amenities.isNotEmpty) ...[
                          AmenitiesWidget(amenities: amenities),
                          const SizedBox(height: 12),
                        ],

                        // Gallery
                        if (gallery.isNotEmpty) ...[
                          GalleryWidget(gallery: gallery),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
