import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'image_grid_widget.dart';
import 'description_widget.dart';
import 'restaurants_widget.dart';
import 'policies_widget.dart';
import 'image_gallery_popup.dart';
//import 'contact_widget.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
    try {
      final hotelController = Get.find<HotelController>();
      final config = hotelController.getConfig();
      if (config != null) {
        setState(() {
          data = config['config'] ?? config;
        });
      } else {
        print('No config available for about');
      }
    } catch (e) {
      print('Error loading about data: $e');
    }
  }

  void _showImageGallery(List<dynamic> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ImageGalleryPopup(images: images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final about = data['about'] as Map<String, dynamic>? ?? {};
    final policiesData = data['policies'] as Map<String, dynamic>? ?? {};
    final images = (about['images'] as List<dynamic>?) ?? [];

    // Convert policies object to list format
    final policies = [
      {
        "icon": "login",
        "title": "Check-In",
        "description": policiesData['checkIn'] ?? '',
      },
      {
        "icon": "logout",
        "title": "Check-Out",
        "description": policiesData['checkOut'] ?? '',
      },
      {
        "icon": "cancel",
        "title": "Cancellation Policy",
        "description": policiesData['cancellation'] ?? '',
      },
      {
        "icon": "pets",
        "title": "Pet Policy",
        "description": policiesData['petPolicy'] ?? '',
      },
      {
        "icon": "smoke_free",
        "title": "Smoking Policy",
        "description": policiesData['smokingPolicy'] ?? '',
      },
    ];

    return Scaffold(
      backgroundColor: AppColor.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: _showGreenStatusBar
              ? AppColor.primary
              : Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: _showGreenStatusBar
                ? AppColor.primary
                : Colors.transparent,
            statusBarIconBrightness: _showGreenStatusBar
                ? Brightness.light
                : Brightness.dark,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Grid Section - starts from top
                if (images.isNotEmpty)
                  ImageGridWidget(
                    images: images,
                    onImageTap: _showImageGallery,
                  ),

                // About Section
                DescriptionWidget(about: about),
                const SizedBox(height: 12),

                // // Restaurants Section
                // if (restaurants.isNotEmpty) ...[
                //   RestaurantsWidget(restaurants: restaurants),
                //   const SizedBox(height: 12),
                // ],

                // Policies Section
                if (policies.isNotEmpty) ...[
                  PoliciesWidget(policies: policies),
                  const SizedBox(height: 12),
                ],

                // Contact Section
                // const ContactWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
