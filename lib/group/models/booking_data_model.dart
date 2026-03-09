// lib/group/models/booking_data_model.dart
class BookingDataModel {
  final String roomName;
  final int basePrice;
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int adults;
  final int children;
  final int infants;
  final List<int> childAges;
  final List<String> infantAges;

  BookingDataModel({
    required this.roomName,
    required this.basePrice,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.infants,
    required this.childAges,
    required this.infantAges,
  });
}
