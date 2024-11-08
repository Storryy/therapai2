import 'package:cloud_firestore/cloud_firestore.dart';


class ChatHistory {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String chatId;

  ChatHistory({required this.userId, required this.chatId});

  List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! How can I assist you today?', 'isBot': true},
  ];

  List<Map<String, dynamic>> get messages => _messages;

  void addMessage(String text, bool isBot) {
    _messages.add({'text': text, 'isBot': isBot});
    _saveChatHistory();
  }


  // Save chat history for the specific chatId
  Future<void> _saveChatHistory() async {
    try {
      await _firestore
          .collection('chat_history')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .set({'messages': _messages});
    } catch (e) {
      print("Failed to save chat history: $e");
    }
  }

  // Load chat history for the specific chatId
  Future<void> loadChatHistory() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('chat_history')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .get();

      if (snapshot.exists) {
        _messages = List<Map<String, dynamic>>.from(snapshot['messages']);
      }
    } catch (e) {
      print("Failed to load chat history: $e");
    }
  }
  Future<void> saveMoodToFirestore(String mood) async {
    try {
      // Get the current date
      String currentDate = DateTime.now().toIso8601String().split('T').first; // "YYYY-MM-DD"

      // Reference to Firestore document
      DocumentReference moodDocRef = _firestore
          .collection('user_moods')
          .doc(userId)
          .collection('moods')
          .doc(currentDate);  // Use date as document ID to ensure one mood per day

      // Save mood to Firestore
      await moodDocRef.set({
        'mood': mood,
        'date': currentDate,
      }, SetOptions(merge: true));  // merge to avoid overwriting data on subsequent updates

      print('Mood saved to Firestore for $currentDate');
    } catch (e) {
      print("Failed to save mood to Firestore: $e");
    }
  }

}

