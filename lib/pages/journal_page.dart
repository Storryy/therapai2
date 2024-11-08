import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:therapai2/pages/chat_list_page.dart';
import 'package:therapai2/pages/mood_tracker_page.dart';

class JournalingPage extends StatefulWidget {
  final String userId;
  final String chatId;
  List<String> prompts;
  JournalingPage({super.key, required this.userId, required this.chatId, required this.prompts});

  @override
  _JournalingPageState createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Controllers for the text fields
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each prompt
    for (var prompt in widget.prompts) {
      _controllers[prompt] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose of controllers when done
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to save journal entries to Firestore
  Future<void> _saveJournalEntries() async {
    try {
      for (var prompt in widget.prompts) {
        final response = _controllers[prompt]!.text;
        if (response.isNotEmpty) {
          await _firestore
              .collection('user_journals')
              .doc(widget.userId)
              .collection('entries')
              .add({
            'prompt': prompt,
            'response': response,
            'date': DateTime.now().toIso8601String(),
          });
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journal entries saved successfully!")),
      );
    } catch (e) {
      print("Error saving entries: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('TherapAI Journaling', style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('TherapAI Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('TherapAI Chat'),
              onTap: () {
                // Navigate to Mood Tracker
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListPage(userId: widget.userId, chatId: widget.chatId))); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Journaling'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Mood Tracker'),
              onTap: () {
                // Navigate to Mood Tracker
                Navigator.push(context, MaterialPageRoute(builder: (context) => MoodTrackerPage(userId: widget.userId, chatId: widget.chatId, prompts: widget.prompts))); // Close drawer
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE0F7FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Journal Prompts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.prompts.length,
                itemBuilder: (context, index) {
                  final prompt = widget.prompts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prompt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controllers[prompt],
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Write your response here...',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveJournalEntries,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
