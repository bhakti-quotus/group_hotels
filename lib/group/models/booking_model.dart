// models/booking_model.dart
import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 0)
class BookingModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String propertyId;

  @HiveField(2)
  final String hotelName;

  @HiveField(3)
  final String roomTypeCode;

  @HiveField(4)
  final String bookingCode;

  @HiveField(5)
  final DateTime bookedAt;

  @HiveField(6)
  final DateTime checkInDate;

  @HiveField(7)
  final DateTime checkOutDate;

  @HiveField(8)
  final List<Guest> guests;

  @HiveField(9)
  final String bookingUserEmail;

  @HiveField(10)
  final String bookingUserPhone;

  @HiveField(11)
  final double amount;

  @HiveField(12)
  final String currencyCode;

  @HiveField(13)
  final String bookingStatus;

  @HiveField(14)
  final String paymentMethod;

  @HiveField(15)
  final int numberOfNights;

  @HiveField(16)
  final int requestedRooms;

  @HiveField(17)
  final Map<String, dynamic> originalResponse;

  BookingModel({
    required this.id,
    required this.propertyId,
    required this.hotelName,
    required this.roomTypeCode,
    required this.bookingCode,
    required this.bookedAt,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.bookingUserEmail,
    required this.bookingUserPhone,
    required this.amount,
    required this.currencyCode,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.numberOfNights,
    required this.requestedRooms,
    required this.originalResponse,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // Parse guests
    final List<Guest> guests = [];
    if (data['guests'] != null && data['guests'] is List) {
      for (var guest in data['guests']) {
        guests.add(
          Guest(
            firstName: guest['firstName'] ?? '',
            lastName: guest['lastName'] ?? '',
            type: guest['type'] ?? 'adult',
          ),
        );
      }
    }

    final priceData = data['finalPrice'] as Map<String, dynamic>? ?? {};

    return BookingModel(
      id: data['id'] ?? '',
      propertyId: data['propertyId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      roomTypeCode: data['roomTypeCode'] ?? '',
      bookingCode: data['bookingCode'] ?? '',
      bookedAt: DateTime.parse(
        data['bookedAt'] ?? DateTime.now().toIso8601String(),
      ),
      checkInDate: DateTime.parse(
        data['checkInDate'] ?? DateTime.now().toIso8601String(),
      ),
      checkOutDate: DateTime.parse(
        data['checkOutDate'] ?? DateTime.now().toIso8601String(),
      ),
      guests: guests,
      bookingUserEmail: data['bookingUserEmail'] ?? '',
      bookingUserPhone: data['bookingUserPhone'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currencyCode: data['currencyCode'] ?? 'USD',
      bookingStatus: data['bookingStatus'] ?? 'confirmed',
      paymentMethod: data['paymentMethod'] ?? '',
      numberOfNights: (priceData['numberOfNights'] as int?) ??
          (data['numberOfNights'] as int?) ??
          1,
      requestedRooms: (priceData['requestedRooms'] as int?) ??
          (data['requestedRooms'] as int?) ??
          1,
      originalResponse: json,
    );
  }

  // Helper methods
  int get numberOfAdults {
    return guests.where((guest) => guest.type == 'adult').length;
  }

  int get numberOfChildren {
    return guests
        .where((guest) => guest.type == 'child' || guest.type == 'children')
        .length;
  }

  // Get number of infants
  int get numberOfInfants {
    return guests.where((guest) => guest.type.toLowerCase() == 'infant').length;
  }

  // Get primary guest name
  String get primaryGuestName {
    if (guests.isEmpty) return 'Guest';
    return '${guests.first.firstName} ${guests.first.lastName}';
  }

  String get guestNames {
    return guests
        .map((guest) => '${guest.firstName} ${guest.lastName}')
        .join(', ');
  }

  String get formattedCheckIn {
    return '${checkInDate.day}/${checkInDate.month}/${checkInDate.year}';
  }

  String get formattedCheckOut {
    return '${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}';
  }

  String get duration {
    return '$numberOfNights ${numberOfNights == 1 ? 'night' : 'nights'}';
  }

  String get totalPriceFormatted {
    return '$currencyCode $amount';
  }

  String get formattedBookedAt {
    return '${bookedAt.day}/${bookedAt.month}/${bookedAt.year} ${bookedAt.hour}:${bookedAt.minute.toString().padLeft(2, '0')}';
  }
}

@HiveType(typeId: 1)
class Guest {
  @HiveField(0)
  final String firstName;

  @HiveField(1)
  final String lastName;

  @HiveField(2)
  final String type;

  Guest({required this.firstName, required this.lastName, required this.type});
}
