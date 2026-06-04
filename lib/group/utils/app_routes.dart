import 'package:royalcontinent/group/views/about/about.dart';
import 'package:royalcontinent/group/views/auth/register.dart';
import 'package:royalcontinent/group/views/auth/verify_email.dart';
import 'package:royalcontinent/group/views/contact/contact.dart';
import 'package:royalcontinent/group/views/room/room.dart';
import 'package:royalcontinent/ui/booking_details_page.dart';
import 'package:royalcontinent/ui/offer_page/offer_list_page.dart';
import 'package:royalcontinent/ui/booking_page/confirm_booking_page.dart';
import 'package:royalcontinent/ui/booking_page/modify_booking_page.dart';
import 'package:royalcontinent/ui/booking_page/cancel_booking_page.dart';
import 'package:royalcontinent/ui/booking_page/bookings_page.dart';
import 'package:royalcontinent/ui/profile_screen/profile_screen.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/ui/room_screen/room_details_screen.dart';
import 'package:royalcontinent/ui/promotions_page/promotions_list_page.dart';
import 'package:royalcontinent/ui/facilities_page/facilities_list_page.dart';
import 'package:royalcontinent/ui/restaurants_page/restaurants_list_page.dart';
import 'package:royalcontinent/ui/spa_page/spa_list_page.dart';
import 'package:royalcontinent/ui/meetings_events_page/meetings_events_list_page.dart';
import 'package:royalcontinent/ui/attractions_page/attractions_list_page.dart';
import 'package:royalcontinent/ui/outlet_page/outlet_page.dart';
import 'package:royalcontinent/ui/tourism/dubai_sustainable_tourism_ui.dart';
import '../views/splash/splash_page.dart';
import '../views/auth/login.dart';
import '../views/auth/forgot_password.dart';
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
  static const groupMyBookings = '/groupmybookings';
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
  static const forgotPassword = '/forgot-password';
  static const profile = '/profile';


  static const roomDetails = '/room-details';
  static const promotions = '/promotions';
  static const facilities = '/facilities';
  static const restaurant = '/restaurant';
  static const spa = '/spa';
  static const meetingsEvents = '/meetings-events';
  static const attractions = '/attractions';
  static const outlet = '/outlet';

  static const tourism = '/tourism';

  static final routes = [
    GetPage(name: groupHome, page: () => const GroupHomePage()),
    GetPage(name: groupAbout, page: () => const GroupAbout()),
    GetPage(name: groupContact, page: () => const GroupContact()),
    GetPage(name: hotels, page: () => const Hotels()),
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: register, page: () => const RegisterPage()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordPage()),
    GetPage(
      name: verifyEmail,
      page: () => const VerifyEmailPage(email: '', nextRoute: ''),
    ),

    GetPage(name: language, page: () => const LanguagePage()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: about, page: () => const About()),
    GetPage(name: rooms, page: () => const Room()),
    GetPage(name: contact, page: () => const Contact()),
    GetPage(
      name: offers,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final offers = args?['offers'] as List<dynamic>?;
        final title = args?['title'] as String?;
        return OfferListPage(offers: offers, title: title);
      },
    ),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: roomDetails, page: () => const RoomDetailsScreen()),
    GetPage(name: confirmBooking, page: () => const ConfirmBookingPage()),
    GetPage(name: modifyBooking, page: () => const ModifyBookingPage()),
    GetPage(name: cancelBooking, page: () => const CancelBookingPage()),
    GetPage(name: groupBookingDetails, page: () => const BookingDetailsPage()),
    GetPage(name: groupMyBookings, page: () => const MyBookingsPage()),
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
    GetPage(
      name: restaurant,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final restaurants = args?['restaurants'] as List<dynamic>? ?? [];
        final title = args?['title'] as String?;
        return RestaurantListPage(restaurants: restaurants, title: title);
      },
    ),
    GetPage(
      name: spa,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final spas = args?['spas'] as List<dynamic>? ?? [];
        final title = args?['title'] as String?;
        return SpaListPage(spas: spas, title: title);
      },
    ),
    GetPage(
      name: meetingsEvents,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final meetingsEvents = args?['meetingsEvents'] as List<dynamic>? ?? [];
        final title = args?['title'] as String?;
        return MeetingsEventsListPage(meetingsEvents: meetingsEvents, title: title);
      },
    ),
    GetPage(
      name: attractions,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final attractions = args?['attractions'] as List<dynamic>? ?? [];
        final title = args?['title'] as String?;
        return AttractionsListPage(attractions: attractions, title: title);
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
  ];
}
