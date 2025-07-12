// // import 'dart:convert';

// import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:odoo25/model/answers_model.dart';
// // import 'package:odoo25/model/questions_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // class HomeController extends ChangeNotifier {
// //   List<Question> _questions = [];
// //   List<Question> _filteredQuestions = [];
// //   bool _isLoading = false;
// //   String? _errorMessage;
// //   String? _authToken;
// //   String? _currentUserId; // To store the current logged-in user's ID
// //   String? _currentUserName; // To store the current logged-in user's name

// //   List<Question> get questions => _filteredQuestions;
// //   bool get isLoading => _isLoading;
// //   String? get errorMessage => _errorMessage;
// //   String? get currentUserId => _currentUserId;
// //   String? get currentUserName => _currentUserName;

// //   // Constructor no longer calls _loadAuthTokenAndUserDataAndFetchQuestions
// //   HomeController();

// //   // Make this method public so the View can call it after initialization
// //   Future<void> initializeData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     _authToken = prefs.getString('authToken');
// //     _currentUserId = prefs.getString('userId');
// //     print(_currentUserId);
// //     _currentUserName = prefs.getString('userName');
// //     await fetchQuestions();
// //   }

// //   Future<void> fetchQuestions() async {
// //     _isLoading = true;
// //     _errorMessage = null;
// //     notifyListeners();

// //     if (_authToken == null) {
// //       _errorMessage = 'Authentication token not found. Please log in.';
// //       _isLoading = false;
// //       notifyListeners();
// //       return;
// //     }

// //     try {
// //       final response = await http.get(
// //         Uri.parse('http://192.168.0.106:5000/api/v1/questions'),
// //         headers: {
// //           'Authorization': 'Bearer $_authToken',
// //           'Content-Type': 'application/json',
// //         },
// //       );

// //       if (response.statusCode == 200) {
// //         List<dynamic> data = json.decode(response.body);
// //         _questions = data.map((json) => Question.fromJson(json)).toList();
// //         _filteredQuestions = List.from(_questions);
// //         _errorMessage = null;
// //       } else {
// //         _errorMessage = 'Failed to load questions: ${response.body}';
// //         print('Failed to load questions: ${response.statusCode} - ${response.body}');
// //       }
// //     } catch (e) {
// //       _errorMessage = 'Error fetching questions: $e';
// //       print('Error fetching questions: $e');
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   void searchQuestions(String query) {
// //     if (query.isEmpty) {
// //       _filteredQuestions = List.from(_questions);
// //     } else {
// //       _filteredQuestions = _questions.where((question) {
// //         return question.title.toLowerCase().contains(query.toLowerCase()) ||
// //                question.description.toLowerCase().contains(query.toLowerCase()) ||
// //                question.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
// //       }).toList();
// //     }
// //     notifyListeners();
// //   }

// //   Future<void> postQuestion(String title, String description, List<String> tags) async {
// //     _isLoading = true;
// //     _errorMessage = null;
// //     notifyListeners();

// //     if (_authToken == null || _currentUserId == null || _currentUserName == null) {
// //       _errorMessage = 'Authentication token or User ID/Name not found. Please log in.';
// //       _isLoading = false;
// //       notifyListeners();
// //       return;
// //     }

// //     try {
// //       final response = await http.post(
// //         Uri.parse('http://192.168.0.106:5000/api/v1/questions'), // Assuming this is the endpoint for posting questions
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $_authToken',
// //         },
// //         body: json.encode({
// //           'title': title,
// //           'body': description, // API expects 'body' for description
// //           'tags': tags,
// //           'userId': _currentUserId,
// //           'userName': _currentUserName,
// //         }),
// //       );

// //       if (response.statusCode == 201) {
// //         final newQuestionData = json.decode(response.body);
// //         _questions.add(Question.fromJson(newQuestionData));
// //         _filteredQuestions = List.from(_questions); // Refresh filtered list
// //         _errorMessage = null;
// //         print('Question posted successfully!');
// //       } else {
// //         _errorMessage = 'Failed to post question: ${response.body}';
// //         print('Failed to post question: ${response.statusCode} - ${response.body}');
// //       }
// //     } catch (e) {
// //       _errorMessage = 'Error posting question: $e';
// //       print('Error posting question: $e');
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   Future<void> postAnswer(String questionId, String content, String questionUserId) async {
// //     _isLoading = true;
// //     _errorMessage = null;
// //     notifyListeners();

// //     if (_authToken == null || _currentUserId == null || _currentUserName == null) {
// //       _errorMessage = 'Authentication token or User ID/Name not found. Please log in. $_authToken $_currentUserId $_currentUserName';
// //       _isLoading = false;
// //       notifyListeners();
// //       return;
// //     }

// //     try {
// //       final response = await http.post(
// //         Uri.parse('http://192.168.0.106:5000/api/v1/questions/$questionId/answers'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $_authToken',
// //         },
// //         body: json.encode({
// //           'userId': _currentUserId,
// //           'userName': _currentUserName,
// //           'body': content, // API expects 'body' for answer content
// //           'mentions': [questionUserId], // Mention the user who asked the question
// //         }),
// //       );

// //       if (response.statusCode == 201 || response.statusCode == 200) {
// //         final newAnswerData = json.decode(response.body);
// //         Answer newAnswer = Answer.fromJson(newAnswerData);

// //         // Find the question and add the answer
// //         int questionIndex = _questions.indexWhere((q) => q.id == questionId);
// //         if (questionIndex != -1) {
// //           Question oldQuestion = _questions[questionIndex];
// //           List<Answer> updatedAnswers = List.from(oldQuestion.answers)..add(newAnswer);
// //           _questions[questionIndex] = Question(
// //             id: oldQuestion.id,
// //             title: oldQuestion.title,
// //             description: oldQuestion.description,
// //             tags: oldQuestion.tags,
// //             userName: oldQuestion.userName,
// //             upvotes: oldQuestion.upvotes,
// //             downvotes: oldQuestion.downvotes,
// //             answers: updatedAnswers,
// //             userId: oldQuestion.userId,
// //           );
// //           _filteredQuestions = List.from(_questions);
// //         }
// //         _errorMessage = null;
// //         print('Answer posted successfully!');
// //       } else {
// //         _errorMessage = 'Failed to post answer: ${response.body}';
// //         print('Failed to post answer: ${response.statusCode} - ${response.body}');
// //       }
// //     } catch (e) {
// //       _errorMessage = 'Error posting answer: $e';
// //       print('Error posting answer: $e');
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   Future<void> voteAnswer(String answerId, bool isUpvote) async {
// //     _isLoading = true;
// //     _errorMessage = null;
// //     notifyListeners();

// //     if (_authToken == null || _currentUserId == null) {
// //       _errorMessage = 'Authentication token or User ID not found. Please log in.';
// //       _isLoading = false;
// //       notifyListeners();
// //       return;
// //     }

// //     final String endpoint = isUpvote ? 'upvote' : 'downvote';
// //     final String url = 'http://192.168.0.106:5000/api/v1/answers/$answerId/$endpoint';

// //     try {
// //       final response = await http.post(
// //         Uri.parse(url),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $_authToken',
// //         },
// //         body: json.encode({'userId': _currentUserId}),
// //       );

// //       if (response.statusCode == 200) {
// //         await fetchQuestions(); // Re-fetch all questions to update votes
// //         _errorMessage = null;
// //         print('Vote successful for answer $answerId ($endpoint)!');
// //       } else {
// //         _errorMessage = 'Failed to vote: ${response.body}';
// //         print('Failed to vote: ${response.statusCode} - ${response.body}');
// //       }
// //     } catch (e) {
// //       _errorMessage = 'Error voting: $e';
// //       print('Error voting: $e');
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }


// //   Future<void> logout() async {
// //     _isLoading = true;
// //     _errorMessage = null;
// //     notifyListeners();
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
      
// //       // Perform API logout if applicable (optional, depends on backend)
// //       final response = await http.post(
// //         Uri.parse('http://192.168.0.106:5000/api/v1/auth/logout'), // Updated logout API URL
// //         headers: {
// //           'Authorization': 'Bearer $_authToken', // Pass token as bearer token
// //           'Content-Type': 'application/json',
// //         },
// //       );

// //       if (response.statusCode == 200) {
// //         print('Backend logout successful.');
// //       } else {
// //         print('Backend logout failed: ${response.statusCode} - ${response.body}');
// //       }

// //       await prefs.remove('authToken');
// //       await prefs.remove('userId'); // Also remove userId on logout
// //       await prefs.remove('userName'); // Also remove userName on logout
// //       _authToken = null;
// //       _currentUserId = null;
// //       _currentUserName = null;
// //       _errorMessage = null;
// //       print('Logged out successfully.');
// //       // After logout, you would typically navigate back to the login/guest screen
// //     } catch (e) {
// //       _errorMessage = 'Error during logout: $e';
// //       print('Error during logout: $e');
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }
// // }











// class Question {
//   final String id;
//   final String title;
//   final String description;
//   final List<String> tags;
//   final String userName;
//   int upvotes; // Made mutable for local voting
//   int downvotes; // Made mutable for local voting
//   List<Answer> answers; // Made mutable for adding answers
//   final String userId; // User who asked the question
//   final String? pollQuestion; // New: For poll-based questions
//   final List<String>? pollOptions; // New: For poll options
//   final Map<String, int>? pollVotes; // New: To store poll votes (optionId -> count)

//   Question({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.tags,
//     required this.userName,
//     this.upvotes = 0,
//     this.downvotes = 0,
//     this.answers = const [],
//     required this.userId,
//     this.pollQuestion,
//     this.pollOptions,
//     this.pollVotes,
//   });

//   // Method to create a new instance with updated answers
//   Question copyWith({
//     String? id,
//     String? title,
//     String? description,
//     List<String>? tags,
//     String? userName,
//     int? upvotes,
//     int? downvotes,
//     List<Answer>? answers,
//     String? userId,
//     String? pollQuestion,
//     List<String>? pollOptions,
//     Map<String, int>? pollVotes,
//   }) {
//     return Question(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       tags: tags ?? this.tags,
//       userName: userName ?? this.userName,
//       upvotes: upvotes ?? this.upvotes,
//       downvotes: downvotes ?? this.downvotes,
//       answers: answers ?? this.answers,
//       userId: userId ?? this.userId,
//       pollQuestion: pollQuestion ?? this.pollQuestion,
//       pollOptions: pollOptions ?? this.pollOptions,
//       pollVotes: pollVotes ?? this.pollVotes,
//     );
//   }
// }

// class Answer {
//   final String id;
//   final String content;
//   final String userName;
//   int upvotes; // Made mutable for local voting
//   int downvotes; // Made mutable for local voting
//   bool isAccepted; // Made mutable for accepting answers
//   final String userId; // User who posted the answer

//   Answer({
//     required this.id,
//     required this.content,
//     required this.userName,
//     this.upvotes = 0,
//     this.downvotes = 0,
//     this.isAccepted = false,
//     required this.userId,
//   });

//   // Method to create a new instance with updated properties
//   Answer copyWith({
//     String? id,
//     String? content,
//     String? userName,
//     int? upvotes,
//     int? downvotes,
//     bool? isAccepted,
//     String? userId,
//   }) {
//     return Answer(
//       id: id ?? this.id,
//       content: content ?? this.content,
//       userName: userName ?? this.userName,
//       upvotes: upvotes ?? this.upvotes,
//       downvotes: downvotes ?? this.downvotes,
//       isAccepted: isAccepted ?? this.isAccepted,
//       userId: userId ?? this.userId,
//     );
//   }
// }


// // --- Controller ---
// class HomeController extends ChangeNotifier {
//   List<Question> _questions = [];
//   List<Question> _filteredQuestions = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _authToken;
//   String? _currentUserId; // To store the current logged-in user's ID
//   String? _currentUserName; // To store the current logged-in user's name
//   List<String> _notifications = []; // List to store notifications

//   List<Question> get questions => _filteredQuestions;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   String? get currentUserId => _currentUserId;
//   String? get currentUserName => _currentUserName;
//   List<String> get notifications => _notifications;

//   HomeController() {
//     // No initial data loading in constructor
//   }

//   Future<void> initializeData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _authToken = prefs.getString('authToken');
//     _currentUserId = prefs.getString('userId');
//     _currentUserName = prefs.getString('userName');

//     print('HomeController initializeData: authToken = $_authToken');
//     print('HomeController initializeData: currentUserId = $_currentUserId');
//     print('HomeController initializeData: currentUserName = $_currentUserName');
//     await fetchQuestions();
//     _loadDummyNotifications(); // Load dummy notifications on init
//   }

//   void _loadDummyNotifications() {
//     _notifications = [
//       'New answer to "How to implement BLoC pattern in Flutter?"',
//       'Someone mentioned you in a comment.',
//       'Your question "What are the best practices for REST API design?" received an upvote.',
//       'New feature: Polls are now available!',
//     ];
//     notifyListeners();
//   }

//   void clearNotifications() {
//     _notifications.clear();
//     notifyListeners();
//   }

//   Future<void> fetchQuestions() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     // Simulate API call with dummy data
//     await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

//     _questions = [
//       Question(
//         id: 'q1',
//         title: 'How to implement BLoC pattern in Flutter?',
//         description: 'I\'m looking for a clear example of how to structure a Flutter application using the BLoC pattern for state management. Specifically, how to handle events, states, and integrate with UI widgets.',
//         tags: ['Flutter', 'BLoC', 'State Management'],
//         userName: 'FlutterDev',
//         upvotes: 15,
//         downvotes: 2,
//         answers: [
//           Answer(
//             id: 'a1',
//             content: 'The BLoC pattern separates business logic from UI. You define events (inputs), states (outputs), and map events to states. Use `flutter_bloc` package for easy implementation.',
//             userName: 'CodeMaster',
//             upvotes: 8,
//             downvotes: 0,
//             isAccepted: true,
//             userId: 'user123', // Dummy user ID
//           ),
//           Answer(
//             id: 'a2',
//             content: 'You can also use Cubit, which is a simpler version of BLoC, for less complex state management scenarios. It only uses functions to emit new states.',
//             userName: 'FlutterFan',
//             upvotes: 5,
//             downvotes: 1,
//             isAccepted: false,
//             userId: 'user124', // Dummy user ID
//           ),
//         ],
//         userId: 'user123', // Dummy user ID
//       ),
//       Question(
//         id: 'q2',
//         title: 'What are the best practices for REST API design?',
//         description: 'I\'m designing a new REST API and want to follow industry best practices. What are the key principles and common pitfalls to avoid?',
//         tags: ['API', 'REST', 'Backend'],
//         userName: 'BackendGuru',
//         upvotes: 20,
//         downvotes: 1,
//         answers: [
//           Answer(
//             id: 'a3',
//             content: 'Use clear, consistent naming conventions for endpoints and resources. Employ HTTP methods correctly (GET for retrieval, POST for creation, PUT for updates, DELETE for deletion).',
//             userName: 'APIArchitect',
//             upvotes: 12,
//             downvotes: 0,
//             isAccepted: false,
//             userId: 'user125', // Dummy user ID
//           ),
//         ],
//         userId: 'user126', // Dummy user ID
//       ),
//       Question(
//         id: 'q3',
//         title: 'How to optimize database queries in SQL?',
//         description: 'My SQL queries are running slow. What are some common techniques to optimize database performance, such as indexing, query rewriting, and avoiding N+1 problems?',
//         tags: ['SQL', 'Database', 'Performance'],
//         userName: 'DBA_Learner',
//         upvotes: 10,
//         downvotes: 0,
//         answers: [],
//         userId: 'user127', // Dummy user ID
//       ),
//       Question(
//         id: 'q4',
//         title: 'Is Flutter the best choice for cross-platform mobile development?',
//         description: 'I\'m deciding on a framework for my next mobile project. What are the pros and cons of Flutter compared to React Native or native development?',
//         tags: ['Flutter', 'MobileDev', 'Cross-Platform'],
//         userName: 'TechExplorer',
//         upvotes: 8,
//         downvotes: 0,
//         answers: [],
//         userId: 'user128',
//         pollQuestion: 'Do you think Flutter is the best cross-platform framework?',
//         pollOptions: ['Yes', 'No', 'Maybe'],
//         pollVotes: {'Yes': 5, 'No': 2, 'Maybe': 1},
//       ),
//       Question(
//         id: 'q5',
//         title: 'Should I learn Python or JavaScript first for web development?',
//         description: 'As a beginner, which language would be more beneficial to learn first for a career in web development?',
//         tags: ['Web Development', 'Python', 'JavaScript'],
//         userName: 'NewbieDev',
//         upvotes: 12,
//         downvotes: 0,
//         answers: [],
//         userId: 'user129',
//         pollQuestion: 'Which language is better for a beginner in web dev?',
//         pollOptions: ['Python', 'JavaScript'],
//         pollVotes: {'Python': 7, 'JavaScript': 5},
//       ),
//     ];
//     _filteredQuestions = List.from(_questions);
//     _errorMessage = null;

//     _isLoading = false;
//     notifyListeners();
//   }

//   void searchQuestions(String query) {
//     if (query.isEmpty) {
//       _filteredQuestions = List.from(_questions);
//     } else {
//       _filteredQuestions = _questions.where((question) {
//         return question.title.toLowerCase().contains(query.toLowerCase()) ||
//                question.description.toLowerCase().contains(query.toLowerCase()) ||
//                question.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
//       }).toList();
//     }
//     notifyListeners();
//   }

//   Future<void> postQuestion(String title, String description, List<String> tags,
//       {String? pollQuestion, List<String>? pollOptions}) async { // Added poll parameters
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     // Removed the authentication check as requested
//     // if (_authToken == null || _currentUserId == null || _currentUserName == null) {
//     //   _errorMessage = 'Authentication token or User ID/Name not found. Please log in.';
//     //   _isLoading = false;
//     //   notifyListeners();
//     //   return;
//     // }

//     // Simulate successful question post with dummy data
//     await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

//     final newQuestion = Question(
//       id: 'q${_questions.length + 1}',
//       title: title,
//       description: description,
//       tags: tags,
//       userName: _currentUserName ?? 'Anonymous', // Use current logged-in user's name or fallback
//       upvotes: 0,
//       downvotes: 0,
//       answers: [],
//       userId: _currentUserId ?? 'dummyUser', // Use current logged-in user's ID or fallback
//       pollQuestion: pollQuestion,
//       pollOptions: pollOptions,
//       pollVotes: pollOptions != null ? {for (var option in pollOptions) option: 0} : null, // Initialize poll votes
//     );
//     _questions.add(newQuestion);
//     _filteredQuestions = List.from(_questions);
//     _errorMessage = null;
//     print('Question posted successfully (dummy)!');

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> postAnswer(String questionId, String content, String questionUserId) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     // Removed the authentication check as requested
//     // if (_authToken == null || _currentUserId == null || _currentUserName == null) {
//     //   _errorMessage = 'Authentication token or User ID/Name not found. Please log in. (Token: $_authToken, UserID: $_currentUserId, UserName: $_currentUserName)';
//     //   _isLoading = false;
//     //   notifyListeners();
//     //   return;
//     // }

//     // Simulate successful answer post with dummy data
//     await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

//     int questionIndex = _questions.indexWhere((q) => q.id == questionId);
//     if (questionIndex != -1) {
//       Question oldQuestion = _questions[questionIndex];
//       Answer newAnswer = Answer(
//         id: 'a${oldQuestion.answers.length + 1}',
//         content: content,
//         userName: _currentUserName ?? 'Anonymous', // Use current logged-in user's name or fallback
//         upvotes: 0,
//         downvotes: 0,
//         isAccepted: false,
//         userId: _currentUserId ?? 'dummyUser', // Use current logged-in user's ID or fallback
//       );
//       List<Answer> updatedAnswers = List.from(oldQuestion.answers)..add(newAnswer);
//       _questions[questionIndex] = oldQuestion.copyWith(answers: updatedAnswers); // Use copyWith
//       _filteredQuestions = List.from(_questions);
//       _errorMessage = null;
//       print('Answer posted successfully (dummy)!');

//       // Add a dummy notification for the question owner
//       // Only add if current user is not the question owner
//       if ((_currentUserId ?? 'dummyUser') != questionUserId) {
//         _notifications.add('New answer to "${oldQuestion.title}" by ${_currentUserName ?? 'Anonymous'}!');
//       }

//     } else {
//       _errorMessage = 'Question not found to post answer.';
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   void voteAnswer(String answerId, bool isUpvote) {
//     int questionIndex = _questions.indexWhere((q) => q.answers.any((a) => a.id == answerId));
//     if (questionIndex != -1) {
//       int answerIndex = _questions[questionIndex].answers.indexWhere((a) => a.id == answerId);
//       if (answerIndex != -1) {
//         Answer oldAnswer = _questions[questionIndex].answers[answerIndex];
//         Answer updatedAnswer;
//         if (isUpvote) {
//           updatedAnswer = oldAnswer.copyWith(upvotes: oldAnswer.upvotes + 1);
//         } else {
//           updatedAnswer = oldAnswer.copyWith(downvotes: oldAnswer.downvotes + 1);
//         }

//         List<Answer> newAnswers = List.from(_questions[questionIndex].answers);
//         newAnswers[answerIndex] = updatedAnswer;

//         Question oldQuestion = _questions[questionIndex];
//         _questions[questionIndex] = oldQuestion.copyWith(answers: newAnswers);
//         _filteredQuestions = List.from(_questions);
//         notifyListeners();
//         print('Vote successful for answer $answerId ($isUpvote)!');
//       }
//     }
//   }

//   void votePoll(String questionId, String option) {
//     int questionIndex = _questions.indexWhere((q) => q.id == questionId);
//     if (questionIndex != -1) {
//       Question oldQuestion = _questions[questionIndex];
//       if (oldQuestion.pollVotes != null && oldQuestion.pollVotes!.containsKey(option)) {
//         Map<String, int> updatedPollVotes = Map.from(oldQuestion.pollVotes!);
//         updatedPollVotes[option] = (updatedPollVotes[option] ?? 0) + 1;

//         _questions[questionIndex] = oldQuestion.copyWith(pollVotes: updatedPollVotes);
//         _filteredQuestions = List.from(_questions);
//         notifyListeners();
//         print('Voted for poll option "$option" on question $questionId!');
//       }
//     }
//   }

//   void markAnswerAccepted(String questionId, String answerId) {
//     // Only the question owner can mark an answer as accepted
//     int questionIndex = _questions.indexWhere((q) => q.id == questionId);
//     if (questionIndex != -1) {
//       Question question = _questions[questionIndex];
//       // Allow accepting even if _currentUserId is null for dummy data interaction
//       // In a real app, this check would be crucial: if (question.userId == _currentUserId)
      
//       int answerIndex = question.answers.indexWhere((a) => a.id == answerId);
//       if (answerIndex != -1) {
//         Answer oldAnswer = question.answers[answerIndex];
//         // Ensure only one answer can be accepted
//         List<Answer> updatedAnswers = question.answers.map((ans) {
//           if (ans.id == answerId) {
//             return ans.copyWith(isAccepted: true);
//           } else {
//             return ans.copyWith(isAccepted: false); // Unmark other accepted answers
//           }
//         }).toList();

//         _questions[questionIndex] = question.copyWith(answers: updatedAnswers);
//         _filteredQuestions = List.from(_questions);
//         notifyListeners();
//         print('Answer $answerId marked as accepted for question $questionId!');

//         // Add notification for the accepted answer's owner
//         if (oldAnswer.userId != (_currentUserId ?? 'dummyUser')) {
//           _notifications.add('Your answer to "${question.title}" was accepted by ${question.userName}!');
//         }

//       }
//     } else {
//       _errorMessage = 'Only the question owner can accept an answer.'; // This error message is now less relevant without auth check
//       notifyListeners();
//     }
//   }


//   Future<void> logout() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final prefs = await SharedPreferences.getInstance();
      
//       // Perform API logout if applicable (optional, depends on backend)
//       // final response = await http.post(
//       //   Uri.parse('http://192.168.0.106:5000/api/v1/auth/logout'), // Updated logout API URL
//       //   headers: {
//       //     'Authorization': 'Bearer $_authToken', // Pass token as bearer token
//       //     'Content-Type': 'application/json',
//       //   },
//       // );

//       // if (response.statusCode == 200) {
//       //   print('Backend logout successful.');
//       // } else {
//       //   print('Backend logout failed: ${response.statusCode} - ${response.body}');
//       // }

//       await prefs.remove('authToken');
//       await prefs.remove('userId'); // Also remove userId on logout
//       await prefs.remove('userName'); // Also remove userName on logout
//       _authToken = null;
//       _currentUserId = null;
//       _currentUserName = null;
//       _errorMessage = null;
//       print('Logged out successfully.');
//       // After logout, you would typically navigate back to the login/guest screen
//     } catch (e) {
//       _errorMessage = 'Error during logout: $e';
//       print('Error during logout: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }



