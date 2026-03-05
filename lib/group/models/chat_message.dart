import 'package:hive/hive.dart';

part 'chat_message.g.dart'; // ← will be generated

@HiveType(typeId: 2) // Choose a unique typeId (different from BookingModel)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String action;

  @HiveField(1)
  Map<String, dynamic> payload;

  ChatMessage({required this.action, required this.payload});

  // Optional: factory from map (for API responses)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      action: map['action'] as String,
      payload: Map<String, dynamic>.from(map['payload'] as Map),
    );
  }

  Map<String, dynamic> toMap() {
    return {'action': action, 'payload': payload};
  }
}
