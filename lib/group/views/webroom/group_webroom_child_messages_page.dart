import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'ui/message/group_webroom_child_conversation_page.dart';
import 'ui/webroom_bottom_navbar.dart';

class GroupWebRoomChildMessagesPage extends StatelessWidget {
  const GroupWebRoomChildMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {
        'name': 'Yoga Class',
        'message': 'Your class is starting in 15 minutes.',
        'time': '9:41 am',
        'unread': 1,
      },
      {
        'name': 'Room Service',
        'message': 'Your order is on the way.',
        'time': '8:12 am',
        'unread': 0,
      },
      {
        'name': 'Front Desk',
        'message': 'Your reservation has been confirmed.',
        'time': 'Yesterday',
        'unread': 0,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFF003087), 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF0F1F5), 
            height: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search messages...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF003087), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = messages[index];
                final unreadCount = item['unread'] as int;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, 
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFE9EEF9),
                      child: Text(
                        item['name'][0], 
                        style: const TextStyle(
                          color: Color(0xFF003087), 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      item['name'] as String, 
                      style: TextStyle(
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                        color: unreadCount > 0 ? Colors.black87 : Colors.grey[800],
                      ),
                    ),
                    subtitle: Text(
                      item['message'] as String, 
                      style: TextStyle(
                        color: unreadCount > 0 ? Colors.grey[700] : Colors.grey[500],
                        fontSize: 13,
                        fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['time'] as String, 
                          style: TextStyle(
                            color: unreadCount > 0 ? Colors.grey[700] : Colors.grey[500],
                            fontSize: 12,
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8414A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupWebRoomChildConversationPage(
                            title: item['name'] as String,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 2),
    );
  }
}