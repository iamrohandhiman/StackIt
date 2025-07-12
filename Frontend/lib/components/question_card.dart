import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tags;
  final int answers;
  final int upvotes;
  final VoidCallback onTap;

  const QuestionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.tags,
    required this.answers,
    required this.upvotes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue.shade50,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.question_answer, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text('$answers'),
                  const SizedBox(width: 16),
                  Icon(Icons.thumb_up, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text('$upvotes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 