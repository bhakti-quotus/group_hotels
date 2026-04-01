import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart'
    show rootBundle, RawKeyDownEvent, LogicalKeyboardKey;
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/group/controllers/chat_controller.dart';
import 'package:sunswept/group/controllers/api_controller.dart';
import 'package:sunswept/group/controllers/search_controller.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final chatCtrl = Get.find<ChatController>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ApiController apiController = Get.find<ApiController>();
  final searchController = Get.find<AppSearchController>();

  bool _isSending = false;
  final List<String> _currentActivityLogs = [];

  @override
  void initState() {
    super.initState();
    _initChatContext();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addActivityLog(String message) {
    setState(() {
      _currentActivityLogs.add(message);
    });
    _scrollToBottom();
  }

  void _clearActivityLogs() {
    setState(() {
      _currentActivityLogs.clear();
    });
  }

  Future<void> _initChatContext() async {
    if (chatCtrl.chatContextInitialized.value) return;

    String deviceId = "UNKNOWN_DEVICE";

    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      deviceId = android.id ?? "UNKNOWN_ANDROID_ID";
    } else if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? "UNKNOWN_IOS_ID";
    } else {
      deviceId = "550e8400-e29b-41d4-a716-446655440000";
    }

    chatCtrl.deviceId.value = deviceId;

    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      final data = jsonDecode(jsonString);
      chatCtrl.hotelCode.value = data["code"] ?? "UNKNOWN_HOTEL";
    } catch (e) {
      chatCtrl.hotelCode.value = "CONFIG_LOAD_ERROR";
    }

    chatCtrl.chatContextInitialized.value = true;
  }

  Future<void> onSubmit() async {
    if (_isSending) return;
    if (!chatCtrl.chatContextInitialized.value) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    _clearActivityLogs();

    chatCtrl.addMessage({
      'action': 'USER_MESSAGE',
      'payload': {'text': text},
    });
    _scrollToBottom();

    final messageText = text;
    _textController.clear();

    _focusNode.requestFocus();

    final payload = {
      'message': messageText,
      'deviceId': chatCtrl.deviceId.value,
      'propertyCode': chatCtrl.hotelCode.value,
    };

    _addActivityLog('Connecting to server...');

    await apiController.chatWithSSE(
      payload,
      (String event, Map<String, dynamic> data) {
        switch (event) {
          case 'connected':
            _addActivityLog('Connected successfully');
            break;

          case 'thinking':
            final thinkingMsg = data['message'] ?? 'Agent is thinking...';
            _addActivityLog(thinkingMsg);
            break;

          case 'tool_start':
            final toolName = data['tool_name'] ?? 'tool';
            _addActivityLog('Executing $toolName...');
            break;

          case 'tool_end':
            _addActivityLog('Tool execution completed');
            break;

          case 'ping':
            break;

          case 'done':
            _clearActivityLogs();
            if (data['success'] == true) {
              final responseData = data['data'] as Map<String, dynamic>;
              if (responseData['action'] == "SHOW_ROOMS") {
               // print("Search criteria: ${responseData['payload']}");
                searchController.updateSearchPayload(responseData['payload']);
                Future.delayed(const Duration(milliseconds: 200), () {
                  chatCtrl.closeChat();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Get.offNamed('/rooms');
                    chatCtrl.addMessage({
                      'action': 'SHOW_MESSAGE',
                      'payload': {'text': 'Redirecting to Rooms...'},
                    });
                  });
                });
              } else {
                chatCtrl.addMessage(responseData);
              }
            }
            _scrollToBottom();
            break;

          case 'error':
            _clearActivityLogs();
            final errorMsg = data['message'] ?? 'Unknown error';
            chatCtrl.addMessage({
              'action': 'SHOW_MESSAGE',
              'payload': {'text': 'Error: $errorMsg'},
            });
            _scrollToBottom();
            break;
        }
      },
      (String error) {
        _clearActivityLogs();
        chatCtrl.addMessage({
          'action': 'SHOW_MESSAGE',
          'payload': {'text': 'Error: $error'},
        });
        _scrollToBottom();
        setState(() {
          _isSending = false;
        });
      },
      () {
        setState(() {
          _isSending = false;
        });
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final isEnterPressed = event.logicalKey == LogicalKeyboardKey.enter;
      final isShiftPressed = event.isShiftPressed;

      if (isEnterPressed && !isShiftPressed && !_isSending) {
        onSubmit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ---- Modern Header ----
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 8) {
                chatCtrl.closeChat();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hotel Assistant",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Always here to help",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          chatCtrl.closeChat();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ---- Messages Area ----
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                color: Colors.grey[50],
                child: Obx(() {
                  final hasMessages = chatCtrl.messages.isNotEmpty;
                  final hasActivity = _currentActivityLogs.isNotEmpty;

                  if (!hasMessages && !hasActivity) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 250,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 64,
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColor.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ask me anything about the hotel',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: chatCtrl.messages.length + (hasActivity ? 1 : 0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (hasActivity && index == chatCtrl.messages.length) {
                        return _buildActivityLogsWidget();
                      }

                      final msg = chatCtrl.messages[index];
                      final isUser = msg.action == 'USER_MESSAGE';
                      final text =
                          msg.payload['text'] as String? ?? '(no text)';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.smart_toy_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppColor.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : AppColor.text,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),

          // ---- Modern Input Area ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: _handleKeyEvent,
                      child: TextField(
                        cursorColor: AppColor.primary,
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: !_isSending,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        smartDashesType: SmartDashesType.enabled,
                        smartQuotesType: SmartQuotesType.enabled,
                        enableInteractiveSelection: true,
                        autocorrect: true,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(
                              color: AppColor.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          suffixIcon:
                              _textController.text.isNotEmpty && !_isSending
                              ? IconButton(
                                  onPressed: () {
                                    _textController.clear();
                                    _focusNode.requestFocus();
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary,
                        AppColor.primary.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSending ? null : onSubmit,
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogsWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColor.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Agent is working...',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(_currentActivityLogs.map(
                    (log) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              log,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}