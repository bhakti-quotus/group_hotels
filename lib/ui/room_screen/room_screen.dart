import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/hotel_controller.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showGreenStatusBar = false;

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData(); // Reload data if config changed
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

  void loadData() {
    print("Loading data from config...");
    try {
      final hotelController = Get.find<HotelController>();
      final config = hotelController.getConfig();
      if (config != null) {
        setState(() {
          data = config;
        });
      } else {
        print('No config available');
      }
    } catch (e) {
      print('Error loading room data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("RoomScreen build called");

    if (data.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rooms =
        (data['rooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final amenities =
        (data['amenities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    final gallery =
        (data['gallery']?['items'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final branding = data['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    return Scaffold(
      backgroundColor: AppColor.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: AppColor.primary, elevation: 0),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 10),
            // Rooms List
            RoomsListWidget(
              rooms: rooms,
              roomKeys: {},
              onRefresh: loadData,
              primaryColor: primaryColor,
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
