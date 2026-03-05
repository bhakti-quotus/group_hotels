import 'package:get/get.dart';
import 'package:group/group/models/chat_message.dart';
import 'package:group/group/services/hive_service.dart';

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs; // ← now typed!

  late final HiveService hiveService;

  final isOpen = false.obs;

  final buttonX = 0.0.obs;
  final buttonY = 0.0.obs;

  final positionInitialized = false.obs;
  final currentRoute = '/'.obs;

  final deviceId = ''.obs;
  final hotelCode = ''.obs;

  // 👇 renamed flag
  final chatContextInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    hiveService = Get.find<HiveService>(); // safe here
    _loadMessages();
  }

  void _loadMessages() {
    messages.assignAll(hiveService.getAllChatMessages());
  }

  void addMessage(Map<String, dynamic> rawMessage) {
    final chatMsg = ChatMessage.fromMap(rawMessage);
    messages.add(chatMsg);
    hiveService.addChatMessage(chatMsg);
  }

  void clearChat() {
    messages.clear();
    hiveService.clearChatHistory();
  }

  void toggleChat() => isOpen.value = !isOpen.value;
  void closeChat() => isOpen.value = false;

  void updateButtonPosition(double x, double y) {
    buttonX.value = x;
    buttonY.value = y;
  }

  void updateCurrentRoute(String route) {
    currentRoute.value = route;
  }

  void setDeviceId(String id) => deviceId.value = id;
  void setHotelCode(String code) => hotelCode.value = code;
}
