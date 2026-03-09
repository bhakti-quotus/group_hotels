import 'package:group/group/views/about/about.dart';
import 'package:group/group/views/auth/register.dart';
import 'package:group/group/views/auth/verify_email.dart';
import 'package:group/group/views/contact/contact.dart';
import 'package:group/group/views/offers/offers.dart';
import 'package:group/group/views/room/room.dart';
import 'package:group/ui/booking_details_page.dart';
import 'package:group/ui/booking_page/confirm_booking_page.dart';
import 'package:group/ui/profile_screen/profile_screen.dart';
import 'package:get/get.dart';
import 'package:group/ui/room_screen/room_details_screen.dart';
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
  static const groupAbout = '/groupabout';
  static const groupContact = '/groupcontact';
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
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verifyEmail';
  static const profile = '/profile';

  static const roomDetails = '/room-details';

  static final routes = [
    GetPage(name: groupHome, page: () => const GroupHomePage()),
    GetPage(name: groupAbout, page: () => const GroupAbout()),
    GetPage(name: groupContact, page: () => const GroupContact()),
    GetPage(name: hotels, page: () => const Hotels()),
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
    // ✅ FIX: Read bookingCode and propertyCode from Get.arguments
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
  ];
}
