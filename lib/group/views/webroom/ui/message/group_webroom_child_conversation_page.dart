import 'package:flutter/material.dart';

class GroupWebRoomChildConversationPage extends StatelessWidget {
  final String title;

  const GroupWebRoomChildConversationPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messages = [
      {'text': 'Hey! Can you extend my reservation?', 'fromMe': false, 'time': '9:41 am'},
      {'text': 'Sure, let me check and get back to you.', 'fromMe': true, 'time': '9:41 am'},
      {
        'text': 'Great, thank you! I need the room until next Monday.',
        'fromMe': false,
        'time': '9:42 am'
      },
    ];

    return Scaffold(
         backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
             backgroundColor: const Color(0xFFF5F6FA),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                title[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF003087),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
       
        foregroundColor: const Color(0xFF003087),
        elevation: 1,
      ),
      body: Column(
        children: [
            Container(
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white, // matches scaffold background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final fromMe = message['fromMe'] as bool;
                  return Align(
                    alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: fromMe ? const Color(0xFF003087) : const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            message['text'] as String,
                            style: TextStyle(
                              color: fromMe ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message['time'] as String,
                            style: TextStyle(
                                color: fromMe ? Colors.white70 : Colors.grey[500],
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 16,
                    child: const Icon(Icons.send, color: Colors.red, size: 20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
