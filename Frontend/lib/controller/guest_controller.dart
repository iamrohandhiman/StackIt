import 'package:flutter/material.dart';
import 'package:odoo25/model/guest_model.dart';

class GuestQuestionController extends ChangeNotifier {
  List<Question> _allQuestions = [];
  List<Question> _filteredQuestions = [];

  GuestQuestionController() {
    _loadDummyQuestions();
  }

  List<Question> get filteredQuestions => _filteredQuestions;

  void _loadDummyQuestions() {
    _allQuestions = [
      Question(
        id: '1',
        title: 'How to calculate the equivalent resistance of a complex circuit?',
        description: 'I am struggling with a problem involving a circuit with multiple resistors in series and parallel. Are there any general steps or formulas I should follow to simplify it?',
        tags: ['Physics', 'JEE', 'Circuits'],
        userName: 'PhysicsEnthusiast',
        upvotes: 25,
        downvotes: 2,
      ),
      Question(
        id: '2',
        title: 'What are the key differences between SN1 and SN2 reactions?',
        description: 'I often get confused between SN1 and SN2 mechanisms in organic chemistry. Can someone explain the main distinctions regarding intermediates, stereochemistry, and solvent effects?',
        tags: ['Chemistry', 'JEE', 'Organic Chemistry'],
        userName: 'ChemWhiz',
        upvotes: 30,
        downvotes: 1,
      ),
      Question(
        id: '3',
        title: 'Tips for time management during the JEE Main exam?',
        description: 'I find it challenging to complete all sections within the given time limit. What strategies can I use to improve my speed and accuracy during the JEE Main exam?',
        tags: ['JEE', 'Exam Prep', 'Strategy'],
        userName: 'AspiringEngineer',
        upvotes: 40,
        downvotes: 5,
      ),
      Question(
        id: '4',
        title: 'Derivation of the formula for the range of a projectile?',
        description: 'Could someone provide a detailed derivation of the formula for the horizontal range of a projectile launched at an angle?',
        tags: ['Physics', 'JEE', 'Kinematics'],
        userName: 'MathLover',
        upvotes: 18,
        downvotes: 0,
      ),
      Question(
        id: '5',
        title: 'Explain the concept of hybridization in chemical bonding.',
        description: 'I need a clear explanation of hybridization, including how to determine the hybridization of central atoms in molecules and its significance.',
        tags: ['Chemistry', 'JEE', 'Chemical Bonding'],
        userName: 'ScienceSeeker',
        upvotes: 22,
        downvotes: 3,
      ),
    ];
    _filteredQuestions = List.from(_allQuestions); // Initialize filtered list
    notifyListeners();
  }

  void searchQuestions(String query) {
    if (query.isEmpty) {
      _filteredQuestions = List.from(_allQuestions);
    } else {
      _filteredQuestions = _allQuestions.where((question) {
        return question.title.toLowerCase().contains(query.toLowerCase()) ||
               question.description.toLowerCase().contains(query.toLowerCase()) ||
               question.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    notifyListeners();
  }
}