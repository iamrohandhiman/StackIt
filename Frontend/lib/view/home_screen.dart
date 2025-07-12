import 'package:flutter/material.dart';
import '../components/question_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int notificationCount = 3; // Dummy notification count

  // Dummy questions
  final List<Map<String, dynamic>> questions = [
    {
      'title': 'How to learn Express.js effectively?',
      'description': 'Looking for resources and tips to master Express.js.',
      'tags': ['NodeJS', 'Backend'],
      'answers': 2,
      'upvotes': 5,
    },
    {
      'title': 'How to deploy MongoDB on AWS?',
      'description': 'Best practices for deploying MongoDB securely on AWS.',
      'tags': ['MongoDB', 'AWS'],
      'answers': 1,
      'upvotes': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StackIt'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  // TODO: Navigate to notifications screen
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return QuestionCard(
            title: q['title'],
            description: q['description'],
            tags: List<String>.from(q['tags']),
            answers: q['answers'],
            upvotes: q['upvotes'],
            onTap: () {
              // TODO: Navigate to question detail screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Ask Question screen
        },
        child: const Icon(Icons.add),
        tooltip: 'Ask Question',
      ),
    );
  }
} 