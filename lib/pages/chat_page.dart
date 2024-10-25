import 'package:flutter/material.dart';
import 'package:therapai2/services/query_service.dart';
import '../services/chat_history.dart';

class chatPage extends StatefulWidget {
  const chatPage({super.key});

  @override
  State<chatPage> createState() => _chatPageState();
}

class _chatPageState extends State<chatPage> {
  ChatHistory chatHistory = ChatHistory();

  // Class-level messages list
  List<Map<String, dynamic>> messages = [
    {'text': 'Hello! How can I assist you today?', 'isBot': true},
  ];

  // Load chat history when the widget initializes
  @override
  void initState() {
    super.initState();
    chatHistory.loadChatHistory().then((_) {
      setState(() {
        messages = chatHistory.messages; // Load chat history into the messages list
      });
    });
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('TherapAI', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text('TherapAI Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Journaling'),
              onTap: () {
                // Navigate to Journaling
              },
            ),
            ListTile(
              leading: const Icon(Icons.mood),
              title: const Text('Mood Tracker'),
              onTap: () {
                // Navigate to Mood Tracker
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return ChatBubble(
                  message: message['text'],
                  isBot: message['isBot'],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final query = _controller.text;
                    sendMessage(); // Add user message first
                    if (query.isNotEmpty) {
                      await SendQuery(chatHistory).sendQueryToOllama(query);
                      setState(()  {

                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0F7FA),
    );
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        String userMessage = _controller.text;
        messages.add({'text': userMessage, 'isBot': false});
        _controller.clear(); // Clear the input field
      });
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;

  const ChatBubble({super.key, required this.message, required this.isBot});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12.5),
        decoration: BoxDecoration(
          color: isBot ? const Color(0xFFD0E8D0) : const Color(0xFFE3C8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 14.5, color: Colors.black),
        ),
      ),
    );
  }
}
