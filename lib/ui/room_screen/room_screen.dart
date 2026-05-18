import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/hotel_controller.dart';
import 'package:royalcontinent/group/controllers/api_controller.dart';
import 'package:royalcontinent/group/controllers/search_controller.dart'
    as search_ctrl;
import 'amenities_widget.dart';
import 'gallery_widget.dart';
import 'rooms_list_widget.dart';
import 'search_widget.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

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

  // Loyalty data
  Map<String, dynamic>? _propertyDetails;
  Map<String, dynamic>? _propertyVideos;
  Map<String, dynamic>? _loyaltyConfig;

  // Store the ever() worker so we can cancel it in dispose()
  Worker? _hotelWorker;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // React to hotel changes made externally (e.g. from empty-state picker
    // in RoomsListWidget) — but skip if same hotel is already loaded
    _hotelWorker = ever(
      Get.find<HotelController>().selectedHotel,
      (hotel) {
        if (hotel == null) return;
        final newCode =
            (hotel['code'] ?? hotel['id'] ?? '').toString();
        // Only reload if the hotel actually changed
        if (newCode != _loadedPropertyCode) {
          _loadedPropertyCode = '';
          _loadDataFromHotelController();
        }
      },
    );

    _loadDataFromHotelController();
  }

  @override
  void dispose() {
    _hotelWorker?.dispose(); // cancel the ever() listener
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
              ? BrandingColors.primary
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

      final currentCode =
          (selectedHotel['code'] ?? selectedHotel['id'] ?? '')
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

        final galleryItems =
            hotelConfig['gallery']?['items'] as List<dynamic>?;
        gallery =
            galleryItems?.cast<Map<String, dynamic>>() ?? [];

        propertyCode = (selectedHotel['code'] ??
                hotelConfig['code'] ??
                hotelConfig['propertyDetails']?['code'] ??
                selectedHotel['id'] ??
                '')
            .toString();

        hotelName = selectedHotel['name']?.toString() ?? '';
        _loadedPropertyCode = propertyCode;

        _propertyDetails =
            hotelConfig['propertyDetails'] as Map<String, dynamic>?;
        _propertyVideos =
            hotelConfig['propertyVideos'] as Map<String, dynamic>?;

        final localLoyaltyProgram =
            _propertyDetails?['loyaltyProgramConfig']
                as Map<String, dynamic>?;
        final localCreationConfig =
            localLoyaltyProgram?['CreationLoyaltyConfig']
                as Map<String, dynamic>?;
        _loyaltyConfig = localCreationConfig ??
            hotelConfig['loyaltyConfig'] as Map<String, dynamic>?;
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

  /// Fetches rooms from the API.
  /// Always reads propertyCode fresh from AppSearchController so that
  /// hotel switches from the empty-state picker are reflected correctly.
  Future<void> _fetchRoomsFromAPI() async {
    // ── Resolve the current property code ──────────────────────────────
    // Priority: AppSearchController payload > local propertyCode field
    final searchController =
        Get.find<search_ctrl.AppSearchController>();

    String effectivePropertyCode = propertyCode;

    if (searchController.hasSearchPayload()) {
      final payloadCode =
          searchController.getSearchPayload()['propertyCode']
              as String?;
      if (payloadCode != null && payloadCode.isNotEmpty) {
        effectivePropertyCode = payloadCode;
      }
    }

    if (effectivePropertyCode.isEmpty) {
      setState(() => _errorMessage = 'no_property_code');
      return;
    }

    // ── Build payload ──────────────────────────────────────────────────
    Map<String, dynamic> payload;

    if (searchController.hasSearchPayload()) {
      final rawPayload = Map<String, dynamic>.from(
          searchController.getSearchPayload());
      payload = {
        'propertyCode': effectivePropertyCode,
        'startDate': rawPayload['startDate'] as String? ?? '',
        'endDate': rawPayload['endDate'] as String? ?? '',
        'location': rawPayload['location'] as String? ?? '',
        'numberOfRooms': rawPayload['numberOfRooms'] as int? ??
            (rawPayload['guests'] is Map<String, dynamic>
                ? (rawPayload['guests']['rooms'] as int? ??
                    (rawPayload['guests']['roomsArray'] as List?)?.length ?? 1)
                : 1),
        'guests': rawPayload['guests'] as Map<String, dynamic>? ?? {
          'adults': 1,
          'children': 0,
          'rooms': 1,
          'roomsArray': [
            {'adults': 1, 'children': 0, 'childAges': <int>[]},
          ],
        },
        'promocode': rawPayload['promocode'] as String? ?? '',
      };
    } else {
      final searchPayloadFromConfig =
          data['searchPayload'] as Map<String, dynamic>?;
      if (searchPayloadFromConfig != null) {
        final rawPayload = Map<String, dynamic>.from(searchPayloadFromConfig);
        payload = {
          'propertyCode': effectivePropertyCode,
          'startDate': rawPayload['startDate'] as String? ?? '',
          'endDate': rawPayload['endDate'] as String? ?? '',
          'location': rawPayload['location'] as String? ?? '',
          'numberOfRooms': rawPayload['numberOfRooms'] as int? ??
              (rawPayload['guests'] is Map<String, dynamic>
                  ? (rawPayload['guests']['rooms'] as int? ??
                      (rawPayload['guests']['roomsArray'] as List?)?.length ?? 1)
                  : 1),
          'guests': rawPayload['guests'] as Map<String, dynamic>? ?? {
            'adults': 1,
            'children': 0,
            'rooms': 1,
            'roomsArray': [
              {'adults': 1, 'children': 0, 'childAges': <int>[]},
            ],
          },
          'promocode': rawPayload['promocode'] as String? ?? '',
        };
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

          // ── Rooms ──────────────────────────────────────────────────
          if (apiData['rooms'] != null) {
            data['rooms'] = apiData['rooms'];
          } else {
            final selected =
                Get.find<HotelController>().getSelectedHotel();
            data['rooms'] =
                selected?['config']?['rooms'] ?? [];
          }

          // ── Property details + loyalty ─────────────────────────────
          if (apiData['propertyDetails'] != null) {
            data['propertyDetails'] = apiData['propertyDetails'];
            _propertyDetails =
                apiData['propertyDetails'] as Map<String, dynamic>;

            final loyaltyProgramConfig =
                _propertyDetails?['loyaltyProgramConfig']
                    as Map<String, dynamic>?;
            final creationLoyaltyConfig =
                loyaltyProgramConfig?['CreationLoyaltyConfig']
                    as Map<String, dynamic>?;
            if (creationLoyaltyConfig != null) {
              _loyaltyConfig = creationLoyaltyConfig;
            }

            final videos = _propertyDetails?['propertyVideos']
                as Map<String, dynamic>?;
            if (videos != null) {
              _propertyVideos = videos;
            }
          }

          final rooms =
              (data['rooms'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          _errorMessage = rooms.isEmpty ? 'no_rooms' : null;
        } else {
          final error = result['error']?.toString() ??
              result['message']?.toString() ??
              '';
          _errorMessage =
              (error.contains('Property not available') ||
                      error.contains(
                          'Property or configuration not found'))
                  ? 'no_rooms'
                  : 'server_error';
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'server_error';
      });
    }
  }

  /// Called when the user taps "UPDATE SEARCH" in SearchWidget.
  void _onSearchModified() => _fetchRoomsFromAPI();

  /// Called when the user picks a different hotel from the
  /// empty-state hotel picker inside RoomsListWidget.
  /// AppSearchController.searchPayload['propertyCode'] is already
  /// updated by RoomsListWidget before this fires.
  void _onHotelSelectedFromEmptyState() {
    // Sync local propertyCode from the updated payload so the
    // next _fetchRoomsFromAPI call uses the right code
    final searchController =
        Get.find<search_ctrl.AppSearchController>();
    if (searchController.hasSearchPayload()) {
      final newCode =
          searchController.getSearchPayload()['propertyCode']
              as String?;
      if (newCode != null && newCode.isNotEmpty) {
        // Reset _loadedPropertyCode so _loadDataFromHotelController
        // doesn't short-circuit on same-code guard
        _loadedPropertyCode = '';
        propertyCode = newCode;

        // Also update hotelName from HotelController
        final selected =
            Get.find<HotelController>().getSelectedHotel();
        if (selected != null) {
          hotelName = selected['name']?.toString() ?? hotelName;
        }
      }
    }
    _fetchRoomsFromAPI();
  }

  Widget _buildScreenEmptyState() {
    if (_errorMessage == null) return const SizedBox.shrink();

    String title, message;
    IconData iconData;

    switch (_errorMessage) {
      case 'no_rooms':
        // no_rooms is handled inside RoomsListWidget with hotel picker
        return const SizedBox.shrink();
      case 'server_error':
        title = 'Something Went Wrong';
        message =
            'We\'re having trouble loading the rooms. Please try again.';
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
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
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
                style: TextStyle(color: BrandingColors.primary),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty && !_isLoading && _errorMessage == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final rooms =
        (data['rooms'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

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
      branding = selectedHotel['config']['branding']
              as Map<String, dynamic>? ??
          {};
      amenities =
          (selectedHotel['config']['amenities'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } else if (data.isNotEmpty) {
      branding =
          data['branding'] as Map<String, dynamic>? ?? {};
      amenities =
          (data['amenities'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    }

    final primaryColor = branding['primaryColor'] != null
        ? Color(
            int.parse(
                branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    int totalGuests = 1;
    try {
      final searchController =
          Get.find<search_ctrl.AppSearchController>();
      final payload = searchController.hasSearchPayload()
          ? searchController.getSearchPayload()
          : data['searchPayload'] as Map<String, dynamic>?;
      if (payload != null) {
        final guests =
            payload['guests'] as Map<String, dynamic>?;
        if (guests != null) {
          totalGuests = (guests['adults'] as int? ?? 0) +
              (guests['children'] as int? ?? 0);
          if (totalGuests == 0) totalGuests = 1;
        }
      }
    } catch (e) {
      // ignore
    }

    // Decide what to show in the body
    // no_rooms is passed into RoomsListWidget so it can show the hotel picker
    final showScreenError = _errorMessage != null &&
        _errorMessage != 'no_rooms';

    return Scaffold(
      backgroundColor: AppColor.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
            backgroundColor: AppColor.primary, elevation: 0),
      ),
      body: Column(
        children: [
          // Status bar safe area
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Search widget
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.8,
              minHeight: 80,
            ),
            child: SearchWidget(
              update: true,
              showEditText: true,
              onModifySearch: _onSearchModified,
            ),
          ),

          // Body
          Expanded(
            child: showScreenError
                ? _buildScreenEmptyState()
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        RoomsListWidget(
                          rooms: rooms,
                          totalGuests: totalGuests,
                          propertyCode: propertyCode,
                          hotelName: hotelName,
                          roomKeys: {},
                          // Pass 'no_rooms' error only — RoomsListWidget
                          // handles it with the hotel picker UI.
                          // All other errors are shown above by
                          // _buildScreenEmptyState().
                          errorMessage: _errorMessage == 'no_rooms'
                              ? null // let RoomsListWidget show picker via empty rooms list
                              : null,
                          isLoading: _isLoading,
                          onRefresh: _fetchRoomsFromAPI,
                          primaryColor: primaryColor,
                          propertyId: data['propertyDetails']?['id']
                                  ?.toString() ??
                              '',
                          propertyDetails: _propertyDetails,
                          propertyVideos: _propertyVideos,
                          loyaltyConfig: _loyaltyConfig,

                          // NEW — hotel picker in empty state calls this
                          onHotelSelected:
                              _onHotelSelectedFromEmptyState,
                        ),

                        if (amenities.isNotEmpty) ...[
                          AmenitiesWidget(amenities: amenities),
                          const SizedBox(height: 12),
                        ],

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