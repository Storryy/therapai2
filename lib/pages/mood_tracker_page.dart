import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:therapai2/pages/chat_list_page.dart';

import 'journal_page.dart';

class MoodTrackerPage extends StatefulWidget {
  final String userId;
  final String chatId;
  List<String> prompts;

  MoodTrackerPage({super.key, required this.userId, required this.chatId, required this.prompts});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<DateTime, String> moodData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  Future<void> _fetchMoodData() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_moods')
          .doc(widget.userId)
          .collection('moods')
          .where('date', isGreaterThanOrEqualTo: monthStart.toIso8601String())
          .where('date', isLessThan: monthEnd.toIso8601String())
          .get();

      Map<DateTime, String> loadedMoods = {};

      for (var doc in snapshot.docs) {
        DateTime date = DateTime.parse(doc['date']);
        String mood = doc['mood'];
        loadedMoods[date] = mood;
      }

      setState(() {
        moodData = loadedMoods;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching mood data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  int daysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.difference(firstDay).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat.MMMM().format(now);

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
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListPage(userId: widget.userId, chatId: widget.chatId,)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Journaling'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => JournalingPage(userId: widget.userId, chatId: widget.chatId, prompts: widget.prompts,)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mood),
              title: const Text('Mood Tracker'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Mood for $monthName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7 columns for the week
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 20,
                ),
                itemCount: daysInMonth(now),
                itemBuilder: (context, index) {
                  final day = DateTime(now.year, now.month, index + 1);
                  final mood = moodData[day];
                  return MoodTile(
                    day: day.day,
                    mood: mood,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE0F7FA),
    );
  }
}

class MoodTile extends StatelessWidget {
  final int day;
  final String? mood;

  const MoodTile({super.key, required this.day, this.mood});

  @override
  Widget build(BuildContext context) {
    String emoji;
    switch (mood) {
      case 'Anger':
        emoji = '😡';
        break;
      case 'Anticipation':
        emoji = '🤔';
        break;
      case 'Disgust':
        emoji = '🤢';
        break;
      case 'Fear':
        emoji = '😨';
        break;
      case 'Joy':
        emoji = '😊';
        break;
      case 'Love':
        emoji = '❤️';
        break;
      case 'Optimism':
        emoji = '🌞';
        break;
      case 'Pessimism':
        emoji = '🌧️';
        break;
      case 'Sadness':
        emoji = '😢';
        break;
      case 'Surprise':
        emoji = '😲';
        break;
      case 'Trust':
        emoji = '🤝';
        break;
      default:
        emoji = '';  // No mood recorded for this day
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal, width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
