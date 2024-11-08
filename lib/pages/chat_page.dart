import 'package:groq/groq.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:therapai2/pages/mood_tracker_page.dart';
import 'package:therapai2/services/query_service.dart';
import '../services/chat_history.dart';
import 'journal_page.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String chatId;

  const ChatPage({super.key,
    required this.userId,
    required this.chatId
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatHistory? chatHistory;

  final groq = Groq(
    apiKey: ('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'),
    model: GroqModel.llama_31_70b_versatile, // Set a different model
  );

  // Class-level messages list
  List<Map<String, dynamic>> messages = [
    {'text': 'Hello! How can I assist you today?', 'isBot': true},
  ];

  String systemMessageForMoodTracker = "You are a bot that when received with a conversation history between a user and a chatbot, you take the texts of the user and you give me the mood of the user accordingly. The mood of the user can be only between these 11 values: Anger, Anticipation, Disgust, Fear, Joy, Love, Optimism, Pessimism,Sadness, Surprise, and Trust. Your response to any conversation sent to you must only respond with either of these 5 values and nothing else";
  String systemMessageForJournalingPrompt = "You are a bot that when received with a conversation history between a user and a chatbot, you take the texts of the user and the responses given by the chatbot and then provide me with a set of 2 journaling prompts based off of the chat history, that may make the user think and write it in for them to look at and reflect upon later. I just want you to give me the two questions, no formatting, nor any text before or after it.";
  // Load chat history when the widget initializes
  @override
  void initState() {
    super.initState();
    chatHistory = ChatHistory(userId: widget.userId, chatId: widget.chatId);
    chatHistory!.loadChatHistory().then((_) {
      setState(() {
        messages = chatHistory!.messages; // Load chat history into the messages list
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
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
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
              title: const Text('TherapAI Chat'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Journaling'),
              onTap: () async{
                String result = jsonEncode(messages);
                final promptString = await sendGroqQuery(result, systemMessageForJournalingPrompt);
                List<String> prompts = promptString.split('\n');
                Navigator.push(context, MaterialPageRoute(builder: (context) => JournalingPage(userId: widget.userId, chatId: widget.chatId, prompts: prompts)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mood),
              title: const Text('Mood Tracker'),
              onTap: () async{
                String result = jsonEncode(messages);
                final promptString = await sendGroqQuery(result, systemMessageForJournalingPrompt);
                List<String> prompts = promptString.split('\n');
                Navigator.push(context, MaterialPageRoute(builder: (context) => MoodTrackerPage(userId: widget.userId, chatId: widget.chatId, prompts: prompts)));
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
                      await SendQuery(chatHistory!).sendQueryToOllama(query);
                      print(messages);
                      String result = jsonEncode(messages);
                      final mood = await sendGroqQuery(result, systemMessageForMoodTracker);
                      print(mood);
                      if (mood.isNotEmpty) {
                        await chatHistory?.saveMoodToFirestore(mood);
                      }

                      setState(() {
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

  sendGroqQuery(String query, String systemPrompt) async{
    groq.startChat();
    groq.setCustomInstructionsWith(systemPrompt);

    try {
      GroqResponse response = await groq.sendMessage(query);
      return (response.choices.first.message.content);
    } on GroqException catch (error) {
      return (error.message);
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
