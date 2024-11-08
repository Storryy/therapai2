import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  final String userId;
  final String chatId;

  const ChatListPage({Key? key, required this.userId, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chats'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chat_history')
            .doc(userId)
            .collection('chats')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatId = chatDocs[index].id;

              return ListTile(
                title: Text('Chat $chatId'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(userId: userId, chatId: chatId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Generate a new chat ID (unique ID based on current timestamp)
          final newChatId = DateTime.now().toString();
          _firestore
              .collection('chat_history')
              .doc(userId)
              .collection('chats')
              .doc(newChatId)
              .set({'createdAt': Timestamp.now()});

          // Navigate to ChatPage with the new chatId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(userId: userId, chatId: newChatId),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        tooltip: 'Create New Chat',
      ),
    );
  }
}
