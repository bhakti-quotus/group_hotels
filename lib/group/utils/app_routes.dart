import 'package:flutter/material.dart';
import 'package:royalcontinent/group/views/about/about.dart';
import 'package:royalcontinent/group/views/action/group_action.dart';
import 'package:royalcontinent/group/views/auth/register.dart';
import 'package:royalcontinent/group/views/auth/verify_email.dart';
import 'package:royalcontinent/group/views/contact/contact.dart';
import 'package:royalcontinent/group/views/offers/offers.dart';
import 'package:royalcontinent/group/views/room/room.dart';
import 'package:royalcontinent/ui/booking_details_page.dart';
import 'package:royalcontinent/ui/booking_page/confirm_booking_page.dart';
import 'package:royalcontinent/ui/booking_page/modify_booking_page.dart';
import 'package:royalcontinent/ui/booking_page/cancel_booking_page.dart';
import 'package:royalcontinent/ui/profile_screen/profile_screen.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/blog_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/dinning_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/facilities_activities_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/faq_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/gallery_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/offers_promo_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/helper/wedding_screen.dart';
import 'package:royalcontinent/ui/quick_action_screen/quick_action.dart';
import 'package:royalcontinent/ui/room_screen/room_details_screen.dart';
import 'package:royalcontinent/ui/promotions_page/promotions_list_page.dart';
import 'package:royalcontinent/ui/facilities_page/facilities_list_page.dart';
import 'package:royalcontinent/ui/outlet_page/outlet_page.dart';
import 'package:royalcontinent/ui/tourism/dubai_sustainable_tourism_ui.dart';
import '../views/splash/splash_page.dart';
import '../views/auth/login.dart';
import '../views/language/language_page.dart';
import '../views/home/home_page.dart';
import '../views/home/group_home_page.dart';
import '../views/about/group_about.dart';
import '../views/contact/group_contact.dart';
import '../views/hotels/hotels.dart';

class AppRoutes {
  static const groupHome = '/grouphome';
  static const webroom = '/webroom';
  static const webroomChildSplash = '/webroom/child-splash';
  static const webroomChildLogin = '/webroom/child-login';
  static const webroomChildMain = '/webroom/child-main';
  static const webroomChildHome = '/webroom/child-home';
  static const webroomChildSchedule = '/webroom/child-schedule';
  static const webroomChildMessages = '/webroom/child-messages';
  static const webroomChildReservation = '/webroom/child-reservation';
  static const webroomChildProfile = '/webroom/child-profile';
  static const groupAbout = '/groupabout';
  static const groupContact = '/groupcontact';
  static const groupBookingDetails = '/groupbookingdetails';
  static const groupHotels = '/grouphotels';
  static const hotels = '/hotels';
  static const splash = '/';
  static const language = '/language';
  static const home = '/home';
  static const filter = '/filter';
  static const about = '/about';
  static const rooms = '/rooms';
  static const contact = '/contact';
  static const offers = '/offers';
  static const BookingDetails = '/bookingdetails';
  static const confirmBooking = '/confirmBooking';
  static const modifyBooking = '/modifyBooking';
  static const cancelBooking = '/cancelBooking';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verifyEmail';
  static const profile = '/profile';

  static const roomDetails = '/room-details';
  static const promotions = '/promotions';
  static const facilities = '/facilities';
  static const outlet = '/outlet';

  static const tourism = '/tourism';

  //Quick Actions routes
  static const quickActions = '/quick-actions';
  static const actions =
      '/actions'; // For non-group route to access quick actions
  static const qafacilities = '/qa-facilities';
  static const qaweddings = '/qa-weddings';
  static const qagallery = '/qa-gallery';
  static const qafaq = '/qa-faq';
  static const qadinning = '/qa-dinning';
  static const qaoffers = '/qa-offers';
  static const qablog = '/qa-blog';

  static final routes = [
    GetPage(name: groupHome, page: () => const GroupHomePage()),
    GetPage(name: groupAbout, page: () => const GroupAbout()),
    GetPage(name: groupContact, page: () => const GroupContact()),
    GetPage(name: hotels, page: () => const Hotels()),
    GetPage(
      name: actions,
      page: () => const ActionsG(),
    ), // Add this for group actions
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: register, page: () => const RegisterPage()),
    GetPage(
      name: verifyEmail,
      page: () => const VerifyEmailPage(email: '', nextRoute: ''),
    ),
    GetPage(name: language, page: () => const LanguagePage()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: about, page: () => const About()),
    GetPage(name: rooms, page: () => const Room()),
    GetPage(name: contact, page: () => const Contact()),
    GetPage(name: offers, page: () => const Offers()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: roomDetails, page: () => const RoomDetailsScreen()),
    GetPage(name: confirmBooking, page: () => const ConfirmBookingPage()),
    GetPage(name: modifyBooking, page: () => const ModifyBookingPage()),
    GetPage(name: cancelBooking, page: () => const CancelBookingPage()),
    GetPage(name: groupBookingDetails, page: () => const BookingDetailsPage()),
    GetPage(name: groupHotels, page: () => const Hotels()),
    GetPage(
      name: promotions,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final promotions = args?['promotions'] as List<dynamic>? ?? [];
        final title = args?['title'] as String?;
        return PromotionListPage(promotions: promotions, title: title);
      },
    ),
    GetPage(
      name: facilities,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final facilities = args?['facilities'] as List<dynamic>? ?? [];
        final title = args?['title'] as String?;
        return FacilitiesListPage(facilities: facilities, title: title);
      },
    ),
    GetPage(name: outlet, page: () => const OutletPage()),
    GetPage(
      name: BookingDetails,
      page: () {
        final args = Get.arguments;
        String bookingCode = '';
        String propertyCode = '';
        if (args is Map<String, dynamic>) {
          bookingCode = args['bookingCode'] as String? ?? '';
          propertyCode = args['propertyCode'] as String? ?? '';
        }
        return BookingDetailsPage(
          bookingCode: bookingCode,
          propertyCode: propertyCode,
        );
      },
    ),
    GetPage(name: tourism, page: () => const DubaiSustainableTourismPage()),
    GetPage(
      name: AppRoutes.quickActions,
      page: () => const QuickActionPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qafacilities,
      page: () => const FacilitiesPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qaweddings,
      page: () => const WeddingPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qagallery,
      page: () => const GalleryPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qafaq,
      page: () => const FaqPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qadinning,
      page: () => const DiningPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qaoffers,
      page: () => const OffersPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.qablog,
      page: () => const BlogPage(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
