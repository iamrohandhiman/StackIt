import 'package:odoo25/model/answers_model.dart';

class Question {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String userName;
  int upvotes; // Made mutable for local voting
  int downvotes; // Made mutable for local voting
  List<Answer> answers; // Made mutable for adding answers
  final String userId; // User who asked the question

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.userName,
    this.upvotes = 0,
    this.downvotes = 0,
    this.answers = const [],
    required this.userId,
  });

  // Method to create a new instance with updated answers
  Question copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    String? userName,
    int? upvotes,
    int? downvotes,
    List<Answer>? answers,
    String? userId,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      userName: userName ?? this.userName,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      answers: answers ?? this.answers,
      userId: userId ?? this.userId,
    );
  }
}

