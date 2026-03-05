import 'package:group/group/models/chat_message.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/booking_model.dart';
class HiveService {
  static const String _bookingBox = 'bookings';
  static const String _chatBox = 'chat_messages'; // new box name

  late Box<BookingModel> _bookingBoxInstance;
  late Box<ChatMessage> _chatBoxInstance;
  Future<void> init() async {
    print('Opening Hive boxes...');
    try {
      _bookingBoxInstance = await Hive.openBox<BookingModel>(_bookingBox);
      _chatBoxInstance = await Hive.openBox<ChatMessage>(_chatBox);
      print(
        'Hive boxes opened successfully (${_bookingBoxInstance.length} bookings, ${_chatBoxInstance.length} messages)',
      );
    } catch (e, stack) {
      print('Failed to open Hive boxes: $e');
      print(stack);
      rethrow; // let main.dart catch it if needed
    }
  }

  Future<void> saveBooking(Map<String, dynamic> response) async {
    if (response['success'] == true) {
      final booking = BookingModel.fromJson(response);
      await _bookingBoxInstance.put(booking.id, booking);
    }
  }

  List<BookingModel> getAllBookings() {
    return _bookingBoxInstance.values.toList();
  }

  List<BookingModel> getBookingsSortedByDate() {
    final bookings = getAllBookings();
    bookings.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
    return bookings;
  }

  BookingModel? getBookingById(String id) {
    return _bookingBoxInstance.get(id);
  }

  Future<void> deleteBooking(String id) async {
    await _bookingBoxInstance.delete(id);
  }

  Future<void> clearAllBookings() async {
    await _bookingBoxInstance.clear();
  }

  Future<void> close() async {
    await _bookingBoxInstance.close();
    await _chatBoxInstance.close();
  }

  // ── New: Chat message methods ──

  // In HiveService class

  Future<void> addChatMessage(ChatMessage message) async {
    // Hive will assign the next available integer key automatically
    await _chatBoxInstance.add(message);
  }

  List<ChatMessage> getAllChatMessages() {
    // Hive boxes with integer keys keep insertion order by default
    return _chatBoxInstance.values.toList();
    // → messages will appear in the order they were added
  }

  Future<void> clearChatHistory() async {
    await _chatBoxInstance.clear();
  }
}
