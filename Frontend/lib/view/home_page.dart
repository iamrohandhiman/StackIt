import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomeView extends StatefulWidget {
  final HomeController controller;

  const HomeView({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
    // Call the initialization method on the controller after the widget is mounted
     WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    setState(() {});
    if (widget.controller.errorMessage != null) {
      _showAlertDialog('Error', widget.controller.errorMessage!);
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showQuestionOptionsModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How would you like to ask your question?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close options modal
                    _showAskQuestionModal(); // Show quick question modal
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Quick Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close options modal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AskQuestionScreen(
                          controller: HomeController(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Detailed Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAskQuestionModal() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController tagsController = TextEditingController(); // For comma-separated tags

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take full height if needed
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask a New Question',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a concise title for your question',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                const SizedBox(height: 15),
                // Placeholder for Rich Text Editor
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description (HTML Rich Text)',
                    hintText: 'Provide detailed information about your question',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    alignLabelWithHint: true, // Align label to the top
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    hintText: 'e.g., Flutter, Dart, UI',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.controller.isLoading
                        ? null
                        : () async {
                            if (titleController.text.isNotEmpty &&
                                descriptionController.text.isNotEmpty &&
                                tagsController.text.isNotEmpty) {
                              List<String> tags = tagsController.text
                                  .split(',')
                                  .map((tag) => tag.trim())
                                  .where((tag) => tag.isNotEmpty)
                                  .toList();
                              await widget.controller.postQuestion(
                                titleController.text,
                                descriptionController.text,
                                tags,
                              );
                              if (widget.controller.errorMessage == null) {
                                Navigator.pop(context); // Close modal on success
                              }
                            } else {
                              _showAlertDialog('Validation Error', 'Please fill all fields.');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: widget.controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Question',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAnswerModal(String questionId, String questionUserId) {
    final TextEditingController answerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post Your Answer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: answerController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    hintText: 'Type your answer here...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.controller.isLoading
                        ? null
                        : () async {
                            if (answerController.text.isNotEmpty) {
                              await widget.controller.postAnswer(
                                questionId,
                                answerController.text,
                                questionUserId,
                              );
                              if (widget.controller.errorMessage == null) {
                                Navigator.pop(context); // Close modal on success
                              }
                            } else {
                              _showAlertDialog('Validation Error', 'Answer cannot be empty.');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: widget.controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Answer',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StackIt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.blueAccent),
                onPressed: () {
                  // Handle profile view or settings
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                await widget.controller.logout();
                // Navigate back to Login/Guest screen after logout
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the first route
                // Or push a specific route:
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GuestQuestionView(controller: GuestQuestionController())));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search questions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    ),
                    onChanged: widget.controller.searchQuestions,
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (String result) {
                    // Handle filter selection
                    print('Selected filter: $result');
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'newest',
                      child: Text('Newest'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'unanswered',
                      child: Text('Unanswered'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'more',
                      child: Text('More Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _showQuestionOptionsModal, // Changed to show options modal
                icon: const Icon(Icons.add),
                label: const Text('Ask New Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          widget.controller.isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.controller.questions.length,
                    itemBuilder: (context, index) {
                      final question = widget.controller.questions[index];
                      return QuestionCard(
                        question: question,
                        onPostAnswer: () => _showAnswerModal(question.id, question.userId), // Pass question.userId
                        homeController: widget.controller, // Pass controller for voting
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onPostAnswer;
  final HomeController homeController; // Added to access vote methods

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onPostAnswer,
    required this.homeController, // Required in constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: question.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              question.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Asked by ${question.userName}',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600]),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {
                        // Upvote for question - not implemented in API, keeping placeholder
                        print('Upvoted question: ${question.id}');
                      },
                      color: Colors.green,
                    ),
                    Text('${question.upvotes}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () {
                        // Downvote for question - not implemented in API, keeping placeholder
                        print('Downvoted question: ${question.id}');
                      },
                      color: Colors.red,
                    ),
                    Text('${question.downvotes}'),
                  ],
                ),
                TextButton(
                  onPressed: onPostAnswer,
                  child: Text(
                    '${question.answers.length} Answers',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Display Answers
            if (question.answers.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Answers:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ...question.answers.map((answer) => AnswerCard(
                answer: answer,
                homeController: homeController, // Pass controller to AnswerCard
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

class AnswerCard extends StatelessWidget {
  final Answer answer;
  final HomeController homeController; // Added to access vote methods

  const AnswerCard({Key? key, required this.answer, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      elevation: 1,
      color: answer.isAccepted ? Colors.green.shade50 : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: answer.isAccepted ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Answered by ${answer.userName}',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      onPressed: () {
                        homeController.voteAnswer(answer.id, true); // Upvote
                      },
                      color: Colors.green,
                      iconSize: 20,
                    ),
                    Text('${answer.upvotes}'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.thumb_down),
                      onPressed: () {
                        homeController.voteAnswer(answer.id, false); // Downvote
                      },
                      color: Colors.red,
                      iconSize: 20,
                    ),
                    Text('${answer.downvotes}'),
                    if (answer.isAccepted) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const Text('Accepted', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
















// Models
class Question {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String userName;
  int upvotes;
  int downvotes;
  List<Answer> answers;
  final String userId;
  final String? pollQuestion;
  final List<String>? pollOptions;
  final Map<String, int>? pollVotes;
  final DateTime createdAt;
  final List<String> userVotes; // Track who voted

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
    this.pollQuestion,
    this.pollOptions,
    this.pollVotes,
    DateTime? createdAt,
    this.userVotes = const [],
  }) : createdAt = createdAt ?? DateTime.now();

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
    String? pollQuestion,
    List<String>? pollOptions,
    Map<String, int>? pollVotes,
    DateTime? createdAt,
    List<String>? userVotes,
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
      pollQuestion: pollQuestion ?? this.pollQuestion,
      pollOptions: pollOptions ?? this.pollOptions,
      pollVotes: pollVotes ?? this.pollVotes,
      createdAt: createdAt ?? this.createdAt,
      userVotes: userVotes ?? this.userVotes,
    );
  }
}

class Answer {
  final String id;
  final String content;
  final String userName;
  int upvotes;
  int downvotes;
  bool isAccepted;
  final String userId;
  final DateTime createdAt;
  final List<String> userVotes; // Track who voted

  Answer({
    required this.id,
    required this.content,
    required this.userName,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isAccepted = false,
    required this.userId,
    DateTime? createdAt,
    this.userVotes = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Answer copyWith({
    String? id,
    String? content,
    String? userName,
    int? upvotes,
    int? downvotes,
    bool? isAccepted,
    String? userId,
    DateTime? createdAt,
    List<String>? userVotes,
  }) {
    return Answer(
      id: id ?? this.id,
      content: content ?? this.content,
      userName: userName ?? this.userName,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      isAccepted: isAccepted ?? this.isAccepted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      userVotes: userVotes ?? this.userVotes,
    );
  }
}

// Controller
class HomeController extends ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _filteredQuestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;
  String? _currentUserId;
  String? _currentUserName;
  List<String> _notifications = [];
  String _currentFilter = 'newest';
  List<String> _availableTags = [];

  List<Question> get questions => _filteredQuestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  List<String> get notifications => _notifications;
  String get currentFilter => _currentFilter;
  List<String> get availableTags => _availableTags;

  HomeController() {
    _initializeAvailableTags();
  }

  void _initializeAvailableTags() {
    _availableTags = [
      'Flutter', 'Dart', 'React', 'JavaScript', 'Python', 'Java', 'C++', 'C#',
      'Node.js', 'Express', 'MongoDB', 'SQL', 'PostgreSQL', 'MySQL',
      'HTML', 'CSS', 'Bootstrap', 'Tailwind', 'Vue.js', 'Angular',
      'API', 'REST', 'GraphQL', 'JWT', 'OAuth', 'Firebase', 'AWS',
      'Docker', 'Kubernetes', 'Git', 'GitHub', 'CI/CD', 'Testing',
      'Mobile Development', 'Web Development', 'Backend', 'Frontend',
      'Full Stack', 'DevOps', 'Machine Learning', 'AI', 'Data Science',
      'UI/UX', 'Design', 'Database', 'Security', 'Performance'
    ];
  }

  Future<void> initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
    _currentUserId = prefs.getString('userId') ?? 'user001';
    _currentUserName = prefs.getString('userName') ?? 'CurrentUser';

    print('HomeController initializeData: currentUserId = $_currentUserId');
    print('HomeController initializeData: currentUserName = $_currentUserName');
    
    await fetchQuestions();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = [
      'Welcome to StackIt! 🎉',
      'New answer to "How to implement BLoC pattern in Flutter?" by CodeMaster',
      'Your question "What are the best practices for REST API design?" received 3 upvotes!',
      'Someone mentioned you in a comment on "Flutter vs React Native"',
      'New feature: Rich text editor is now available! ✨',
      'Your answer was accepted by FlutterDev - Great job! 🌟',
      'Weekly digest: 25 new questions this week',
      'Trending: "How to optimize database queries" is getting lots of attention',
    ];
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _questions = [
      Question(
        id: 'q1',
        title: 'How to implement BLoC pattern in Flutter?',
        description: '''I'm looking for a clear example of how to structure a Flutter application using the BLoC pattern for state management. 

**Specifically, I need help with:**
- How to handle events and states properly
- Integration with UI widgets
- Best practices for folder structure
- Error handling in BLoC

Any code examples would be greatly appreciated! 🙏''',
        tags: ['Flutter', 'BLoC', 'State Management', 'Dart'],
        userName: 'FlutterDev',
        upvotes: 3,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        answers: [
          Answer(
            id: 'a1',
            content: '''**BLoC Pattern Implementation Guide**

The BLoC pattern separates business logic from UI components. Here's a complete example:

```dart
// Event
abstract class CounterEvent {}
class CounterIncrement extends CounterEvent {}
class CounterDecrement extends CounterEvent {}

// State  
class CounterState {
  final int count;
  CounterState(this.count);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0));
  
  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    if (event is CounterIncrement) {
      yield CounterState(state.count + 1);
    } else if (event is CounterDecrement) {
      yield CounterState(state.count - 1);
    }
  }
}
```

**Key Benefits:**
- Clear separation of concerns
- Testable business logic
- Reactive programming model

Use `flutter_bloc` package for easier implementation! 🚀''',
            userName: 'CodeMaster',
            upvotes: 2,
            downvotes: 0,
            isAccepted: true,
            userId: 'user123',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Answer(
            id: 'a2',
            content: '''For simpler state management, consider using **Cubit** instead of full BLoC:

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

**When to use Cubit:**
- Less complex state management
- Simple state transitions
- Fewer abstractions needed

**When to use BLoC:**
- Complex business logic
- Multiple state transitions
- Advanced event handling''',
            userName: 'FlutterFan',
            upvotes: 1,
            downvotes: 0,
            isAccepted: false,
            userId: 'user124',
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
        userId: 'user123',
        userVotes: ['user456', 'user789', 'user001'],
      ),
      Question(
        id: 'q2',
        title: 'What are the best practices for REST API design?',
        description: '''I'm designing a new REST API for my startup and want to follow industry best practices. 

**Key areas I'm focusing on:**
- URL structure and naming conventions
- HTTP methods usage
- Error handling and status codes
- Authentication and authorization
- API versioning strategies
- Rate limiting and throttling

What are the most important principles and common pitfalls to avoid? Any real-world examples would be helpful! 💡''',
        tags: ['API', 'REST', 'Backend', 'HTTP', 'Design'],
        userName: 'BackendGuru',
        upvotes: 2,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        answers: [
          Answer(
            id: 'a3',
            content: '''**Essential REST API Best Practices**

**1. URL Structure & Naming:**
```
✅ Good: /api/v1/users/123/posts
❌ Bad: /api/getUser?id=123&action=posts
```

**2. HTTP Methods:**
- `GET` - Retrieve data
- `POST` - Create new resources
- `PUT` - Update entire resource
- `PATCH` - Partial updates
- `DELETE` - Remove resources

**3. Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Server Error

**4. Consistent Response Format:**
```json
{
  "success": true,
  "data": {...},
  "message": "Operation successful",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**5. Authentication:**
Use JWT tokens with proper expiration and refresh mechanisms.''',
            userName: 'APIArchitect',
            upvotes: 3,
            downvotes: 0,
            isAccepted: false,
            userId: 'user125',
            createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          ),
        ],
        userId: 'user126',
        userVotes: ['user001', 'user456'],
      ),
      Question(
        id: 'q3',
        title: 'How to optimize database queries in SQL?',
        description: '''My SQL queries are running extremely slow on large datasets (millions of records). 

**Current issues:**
- Complex JOIN operations taking 30+ seconds
- Full table scans on frequently accessed data
- N+1 query problems in the application layer
- Inefficient WHERE clauses

**Database:** PostgreSQL 13
**Dataset size:** ~5 million records
**Current query time:** 30-45 seconds
**Target:** Under 2 seconds

What optimization techniques should I prioritize? 🔍''',
        tags: ['SQL', 'Database', 'Performance', 'PostgreSQL', 'Optimization'],
        userName: 'DBA_Learner',
        upvotes: 1,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        answers: [],
        userId: 'user127',
        userVotes: ['user001'],
      ),
      Question(
        id: 'q4',
        title: 'Flutter vs React Native: Which is better in 2024?',
        description: '''I'm starting a new mobile project and need to choose between Flutter and React Native.

**Project requirements:**
- Cross-platform (iOS + Android)
- Real-time features (chat, notifications)
- Complex UI animations
- Integration with native device features
- Team has JavaScript experience

**Key considerations:**
- Performance requirements
- Development speed
- Community support
- Long-term maintenance
- Learning curve for the team

What would you recommend and why? 🤔''',
        tags: ['Flutter', 'React Native', 'Mobile Development', 'Cross-Platform'],
        userName: 'TechExplorer',
        upvotes: 2,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        answers: [],
        userId: 'user128',
        userVotes: ['user001', 'user789'],
        pollQuestion: 'Which framework do you prefer for cross-platform development?',
        pollOptions: ['Flutter', 'React Native', 'Native Development'],
        pollVotes: {'Flutter': 12, 'React Native': 8, 'Native Development': 3},
      ),
      Question(
        id: 'q5',
        title: 'Best practices for JWT authentication in Node.js',
        description: '''I'm implementing JWT authentication in my Node.js application and want to ensure security best practices.

**Current implementation:**
- Express.js backend
- JWT tokens for authentication
- MongoDB for user storage
- Refresh token mechanism

**Security concerns:**
- Token storage (localStorage vs httpOnly cookies)
- Token expiration strategies
- Refresh token rotation
- XSS and CSRF protection
- Rate limiting for auth endpoints

What's the most secure approach? 🔒''',
        tags: ['Node.js', 'JWT', 'Authentication', 'Security', 'Express'],
        userName: 'SecureDevs',
        upvotes: 1,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        answers: [],
        userId: 'user129',
        userVotes: ['user001'],
      ),
    ];
    
    _applyCurrentFilter();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void searchQuestions(String query) {
    if (query.isEmpty) {
      _filteredQuestions = List.from(_questions);
    } else {
      _filteredQuestions = _questions.where((question) {
        return question.title.toLowerCase().contains(query.toLowerCase()) ||
               question.description.toLowerCase().contains(query.toLowerCase()) ||
               question.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())) ||
               question.userName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    _applyCurrentFilter();
    notifyListeners();
  }

  void applyFilter(String filter) {
    _currentFilter = filter;
    _applyCurrentFilter();
    notifyListeners();
  }

  void _applyCurrentFilter() {
    switch (_currentFilter) {
      case 'newest':
        _filteredQuestions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _filteredQuestions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'most_voted':
        _filteredQuestions.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      case 'unanswered':
        _filteredQuestions = _filteredQuestions.where((q) => q.answers.isEmpty).toList();
        break;
      case 'answered':
        _filteredQuestions = _filteredQuestions.where((q) => q.answers.isNotEmpty).toList();
        break;
    }
  }

  Future<void> postQuestion(String title, String description, List<String> tags,
      {String? pollQuestion, List<String>? pollOptions}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newQuestion = Question(
      id: 'q${_questions.length + 1}',
      title: title,
      description: description,
      tags: tags,
      userName: _currentUserName ?? 'Anonymous',
      upvotes: 0,
      downvotes: 0,
      answers: [],
      userId: _currentUserId ?? 'dummyUser',
      createdAt: DateTime.now(),
      pollQuestion: pollQuestion,
      pollOptions: pollOptions,
      pollVotes: pollOptions != null ? {for (var option in pollOptions) option: 0} : null,
    );
    
    _questions.insert(0, newQuestion);
    _filteredQuestions = List.from(_questions);
    _applyCurrentFilter();
    
    _notifications.insert(0, 'Your question "$title" has been posted successfully! 🎉');
    _errorMessage = null;
    print('Question posted successfully!');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> postAnswer(String questionId, String content, String questionUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    int questionIndex = _questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      Question oldQuestion = _questions[questionIndex];
      Answer newAnswer = Answer(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        userName: _currentUserName ?? 'Anonymous',
        upvotes: 0,
        downvotes: 0,
        isAccepted: false,
        userId: _currentUserId ?? 'dummyUser',
        createdAt: DateTime.now(),
      );
      
      List<Answer> updatedAnswers = List.from(oldQuestion.answers)..add(newAnswer);
      _questions[questionIndex] = oldQuestion.copyWith(answers: updatedAnswers);
      _filteredQuestions = List.from(_questions);
      _applyCurrentFilter();
      
      _errorMessage = null;
      print('Answer posted successfully!');

      if ((_currentUserId ?? 'dummyUser') != questionUserId) {
        _notifications.insert(0, 'New answer to "${oldQuestion.title}" by ${_currentUserName ?? 'Anonymous'}! 💬');
      }
    } else {
      _errorMessage = 'Question not found to post answer.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void voteQuestion(String questionId, bool isUpvote) {
    int questionIndex = _questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      Question oldQuestion = _questions[questionIndex];
      List<String> updatedVotes = List.from(oldQuestion.userVotes);
      
      if (!updatedVotes.contains(_currentUserId)) {
        updatedVotes.add(_currentUserId!);
        Question updatedQuestion;
        if (isUpvote) {
          updatedQuestion = oldQuestion.copyWith(
            upvotes: oldQuestion.upvotes + 1,
            userVotes: updatedVotes,
          );
        } else {
          updatedQuestion = oldQuestion.copyWith(
            downvotes: oldQuestion.downvotes + 1,
            userVotes: updatedVotes,
          );
        }
        
        _questions[questionIndex] = updatedQuestion;
        _filteredQuestions = List.from(_questions);
        _applyCurrentFilter();
        notifyListeners();
        
        String voteType = isUpvote ? 'upvoted' : 'downvoted';
        print('Question $questionId $voteType successfully!');
      } else {
        print('User has already voted on this question');
      }
    }
  }

  void voteAnswer(String answerId, bool isUpvote) {
    int questionIndex = _questions.indexWhere((q) => q.answers.any((a) => a.id == answerId));
    if (questionIndex != -1) {
      int answerIndex = _questions[questionIndex].answers.indexWhere((a) => a.id == answerId);
      if (answerIndex != -1) {
        Answer oldAnswer = _questions[questionIndex].answers[answerIndex];
        List<String> updatedVotes = List.from(oldAnswer.userVotes);
        
        if (!updatedVotes.contains(_currentUserId)) {
          updatedVotes.add(_currentUserId!);
          Answer updatedAnswer;
          if (isUpvote) {
            updatedAnswer = oldAnswer.copyWith(
              upvotes: oldAnswer.upvotes + 1,
              userVotes: updatedVotes,
            );
          } else {
            updatedAnswer = oldAnswer.copyWith(
              downvotes: oldAnswer.downvotes + 1,
              userVotes: updatedVotes,
            );
          }

          List<Answer> newAnswers = List.from(_questions[questionIndex].answers);
          newAnswers[answerIndex] = updatedAnswer;

          Question oldQuestion = _questions[questionIndex];
          _questions[questionIndex] = oldQuestion.copyWith(answers: newAnswers);
          _filteredQuestions = List.from(_questions);
          _applyCurrentFilter();
          notifyListeners();
          
          String voteType = isUpvote ? 'upvoted' : 'downvoted';
          print('Answer $answerId $voteType successfully!');
        } else {
          print('User has already voted on this answer');
        }
      }
    }
  }

  void votePoll(String questionId, String option) {
    int questionIndex = _questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      Question oldQuestion = _questions[questionIndex];
      if (oldQuestion.pollVotes != null && oldQuestion.pollVotes!.containsKey(option)) {
        Map<String, int> updatedPollVotes = Map.from(oldQuestion.pollVotes!);
        updatedPollVotes[option] = (updatedPollVotes[option] ?? 0) + 1;

        _questions[questionIndex] = oldQuestion.copyWith(pollVotes: updatedPollVotes);
        _filteredQuestions = List.from(_questions);
        _applyCurrentFilter();
        notifyListeners();
        print('Voted for poll option "$option" on question $questionId!');
      }
    }
  }

  void markAnswerAccepted(String questionId, String answerId) {
    int questionIndex = _questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      Question question = _questions[questionIndex];
      
      int answerIndex = question.answers.indexWhere((a) => a.id == answerId);
      if (answerIndex != -1) {
        Answer oldAnswer = question.answers[answerIndex];
        List<Answer> updatedAnswers = question.answers.map((ans) {
          if (ans.id == answerId) {
            return ans.copyWith(isAccepted: true);
          } else {
            return ans.copyWith(isAccepted: false);
          }
        }).toList();

        _questions[questionIndex] = question.copyWith(answers: updatedAnswers);
        _filteredQuestions = List.from(_questions);
        _applyCurrentFilter();
        notifyListeners();
        
        print('Answer $answerId marked as accepted for question $questionId!');

        if (oldAnswer.userId != (_currentUserId ?? 'dummyUser')) {
          _notifications.insert(0, 'Your answer to "${question.title}" was accepted! 🌟');
        }
      }
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('userName');
      
      _authToken = null;
      _currentUserId = null;
      _currentUserName = null;
      _errorMessage = null;
      
      print('Logged out successfully.');
    } catch (e) {
      _errorMessage = 'Error during logout: $e';
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Rich Text Editor Widget
class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const RichTextEditor({
    Key? key,
    required this.controller,
    this.hintText = 'Enter your text here...',
    this.maxLines = 5,
  }) : super(key: key);

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  TextAlign _textAlign = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Wrap(
            spacing: 8.0,
            children: [
              _buildToolbarButton(
                icon: Icons.format_bold,
                isActive: _isBold,
                onPressed: () => setState(() => _isBold = !_isBold),
                tooltip: 'Bold',
              ),
              _buildToolbarButton(
                icon: Icons.format_italic,
                isActive: _isItalic,
                onPressed: () => setState(() => _isItalic = !_isItalic),
                tooltip: 'Italic',
              ),
              _buildToolbarButton(
                icon: Icons.format_underline,
                isActive: _isUnderline,
                onPressed: () => setState(() => _isUnderline = !_isUnderline),
                tooltip: 'Underline',
              ),
              const VerticalDivider(),
              _buildToolbarButton(
                icon: Icons.format_align_left,
                isActive: _textAlign == TextAlign.left,
                onPressed: () => setState(() => _textAlign = TextAlign.left),
                tooltip: 'Align Left',
              ),
              _buildToolbarButton(
                icon: Icons.format_align_center,
                isActive: _textAlign == TextAlign.center,
                onPressed: () => setState(() => _textAlign = TextAlign.center),
                tooltip: 'Align Center',
              ),
              _buildToolbarButton(
                icon: Icons.format_align_right,
                isActive: _textAlign == TextAlign.right,
                onPressed: () => setState(() => _textAlign = TextAlign.right),
                tooltip: 'Align Right',
              ),
              const VerticalDivider(),
              _buildToolbarButton(
                icon: Icons.format_list_bulleted,
                onPressed: () => _insertText('• '),
                tooltip: 'Bullet List',
              ),
              _buildToolbarButton(
                icon: Icons.format_list_numbered,
                onPressed: () => _insertText('1. '),
                tooltip: 'Numbered List',
              ),
              _buildToolbarButton(
                icon: Icons.link,
                onPressed: () => _insertText('[Link Text](https://example.com)'),
                tooltip: 'Insert Link',
              ),
              _buildToolbarButton(
                icon: Icons.emoji_emotions,
                onPressed: () => _insertText('😊 '),
                tooltip: 'Insert Emoji',
              ),
            ],
          ),
        ),
        // Text Field
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: TextStyle(
            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
          ),
          textAlign: _textAlign,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
              
              
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Icon(
            icon,
            size: 18.0,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _insertText(String text) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + text.length),
    );
  }
}

// Advanced Rich Text Editor with more features
class AdvancedRichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const AdvancedRichTextEditor({
    Key? key,
    required this.controller,
    this.hintText = 'Enter your text here...',
    this.maxLines = 8,
  }) : super(key: key);

  @override
  State<AdvancedRichTextEditor> createState() => _AdvancedRichTextEditorState();
}

class _AdvancedRichTextEditorState extends State<AdvancedRichTextEditor> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  TextAlign _textAlign = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Column(
            children: [
              // First row of toolbar
              Row(
                children: [
                  _buildToolbarButton(
                    icon: Icons.format_bold,
                    isActive: _isBold,
                    onPressed: () => setState(() => _isBold = !_isBold),
                    tooltip: 'Bold',
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_italic,
                    isActive: _isItalic,
                    onPressed: () => setState(() => _isItalic = !_isItalic),
                    tooltip: 'Italic',
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_underlined,
                    isActive: _isUnderline,
                    onPressed: () => setState(() => _isUnderline = !_isUnderline),
                    tooltip: 'Underline',
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_strikethrough,
                    isActive: _isStrikethrough,
                    onPressed: () => setState(() => _isStrikethrough = !_isStrikethrough),
                    tooltip: 'Strikethrough',
                  ),
                  const VerticalDivider(),
                  _buildToolbarButton(
                    icon: Icons.format_align_left,
                    isActive: _textAlign == TextAlign.left,
                    onPressed: () => setState(() => _textAlign = TextAlign.left),
                    tooltip: 'Align Left',
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_align_center,
                    isActive: _textAlign == TextAlign.center,
                    onPressed: () => setState(() => _textAlign = TextAlign.center),
                    tooltip: 'Align Center',
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_align_right,
                    isActive: _textAlign == TextAlign.right,
                    onPressed: () => setState(() => _textAlign = TextAlign.right),
                    tooltip: 'Align Right',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Second row of toolbar
              Row(
                children: [
                  _buildToolbarButton(
                    icon: Icons.format_list_bulleted,
                    onPressed: () => _insertText('• '),
                    tooltip: 'Bullet List',
                  ),
                  _buildToolbarButton(
                    icon: Icons.format_list_numbered,
                    onPressed: () => _insertText('1. '),
                    tooltip: 'Numbered List',
                  ),
                  _buildToolbarButton(
                    icon: Icons.link,
                    onPressed: _insertLink,
                    tooltip: 'Insert Link',
                  ),
                  _buildToolbarButton(
                    icon: Icons.image,
                    onPressed: _insertImage,
                    tooltip: 'Insert Image',
                  ),
                  _buildToolbarButton(
                    icon: Icons.emoji_emotions,
                    onPressed: _showEmojiPicker,
                    tooltip: 'Insert Emoji',
                  ),
                  _buildToolbarButton(
                    icon: Icons.code,
                    onPressed: () => _insertText('`code`'),
                    tooltip: 'Code Block',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Text Field
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: TextStyle(
            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: _getTextDecoration(),
          ),
          textAlign: _textAlign,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  TextDecoration _getTextDecoration() {
    List<TextDecoration> decorations = [];
    if (_isUnderline) decorations.add(TextDecoration.underline);
    if (_isStrikethrough) decorations.add(TextDecoration.lineThrough);
    
    if (decorations.isEmpty) return TextDecoration.none;
    return TextDecoration.combine(decorations);
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Icon(
            icon,
            size: 18.0,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _insertText(String text) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + text.length),
    );
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (context) => _LinkDialog(
        onInsert: (linkText, url) {
          _insertText('[$linkText]($url)');
        },
      ),
    );
  }

  void _insertImage() {
    showDialog(
      context: context,
      builder: (context) => _ImageDialog(
        onInsert: (imageUrl, altText) {
          _insertText('![${altText ?? 'Image'}]($imageUrl)');
        },
      ),
    );
  }

  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => _EmojiPicker(
        onEmojiSelected: (emoji) {
          _insertText('$emoji ');
        },
      ),
    );
  }
}

// Link Dialog
class _LinkDialog extends StatefulWidget {
  final Function(String linkText, String url) onInsert;

  const _LinkDialog({required this.onInsert});

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _linkTextController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _linkTextController,
            decoration: const InputDecoration(
              labelText: 'Link Text',
              hintText: 'Enter link text',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_linkTextController.text.isNotEmpty && _urlController.text.isNotEmpty) {
              widget.onInsert(_linkTextController.text, _urlController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}

// Image Dialog
class _ImageDialog extends StatefulWidget {
  final Function(String imageUrl, String? altText) onInsert;

  const _ImageDialog({required this.onInsert});

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  final _imageUrlController = TextEditingController();
  final _altTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/image.jpg',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _altTextController,
            decoration: const InputDecoration(
              labelText: 'Alt Text (Optional)',
              hintText: 'Description of the image',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_imageUrlController.text.isNotEmpty) {
              widget.onInsert(_imageUrlController.text, _altTextController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}

// Emoji Picker
class _EmojiPicker extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;

  const _EmojiPicker({required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    final emojis = [
      '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
      '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
      '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
      '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
      '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
      '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
      '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
      '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥',
      '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧',
      '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐',
      '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑',
      '🤠', '😈', '👿', '👹', '👺', '🤡', '💩', '👻',
      '💀', '☠️', '👽', '👾', '🤖', '🎃', '😺', '😸',
      '😹', '😻', '😼', '😽', '🙀', '😿', '😾', '👋',
      '🤚', '🖐', '✋', '🖖', '👌', '🤏', '✌️', '🤞',
      '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇',
      '☝️', '👍', '👎', '👊', '✊', '🤛', '🤜', '👏',
      '🙌', '👐', '🤲', '🤝', '🙏', '✍️', '💅', '🤳',
      '💪', '🦾', '🦿', '🦵', '🦶', '👂', '🦻', '👃',
      '🧠', '🦷', '🦴', '👀', '👁', '👅', '👄', '💋',
      '💘', '💝', '💖', '💗', '💓', '💞', '💕', '💟',
      '❣️', '💔', '❤️', '🧡', '💛', '💚', '💙', '💜',
      '🤎', '🖤', '🤍', '💯', '💢', '💥', '💫', '💦',
      '💨', '🕳', '💣', '💬', '👁‍🗨', '🗨', '🗯', '💭',
      '💤', '👋', '🤚', '🖐', '✋', '🖖', '👌', '🤏',
    ];

    return AlertDialog(
      title: const Text('Select Emoji'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                onEmojiSelected(emojis[index]);
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Multi-Select Tags Widget
class MultiSelectTagsWidget extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final String hintText;

  const MultiSelectTagsWidget({
    Key? key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagsChanged,
    this.hintText = 'Select tags...',
  }) : super(key: key);

  @override
  State<MultiSelectTagsWidget> createState() => _MultiSelectTagsWidgetState();
}

class _MultiSelectTagsWidgetState extends State<MultiSelectTagsWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredTags = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredTags = widget.availableTags;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Tags Display
        if (widget.selectedTags.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedTags.map((tag) => _buildTagChip(tag)).toList(),
            ),
          ),
        const SizedBox(height: 8),
        
        // Search Field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(_isDropdownOpen ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isDropdownOpen = !_isDropdownOpen;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _filteredTags = widget.availableTags
                  .where((tag) => tag.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
          onTap: () {
            setState(() {
              _isDropdownOpen = true;
            });
          },
        ),
        
        // Dropdown List
        if (_isDropdownOpen)
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView.builder(
              itemCount: _filteredTags.length,
              itemBuilder: (context, index) {
                final tag = _filteredTags[index];
                final isSelected = widget.selectedTags.contains(tag);
                
                return ListTile(
                  title: Text(tag),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    _toggleTag(tag);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () {
        _toggleTag(tag);
      },
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void _toggleTag(String tag) {
    List<String> newSelectedTags = List.from(widget.selectedTags);
    if (newSelectedTags.contains(tag)) {
      newSelectedTags.remove(tag);
    } else {
      newSelectedTags.add(tag);
    }
    widget.onTagsChanged(newSelectedTags);
  }
}

// Ask Question Screen
class AskQuestionScreen extends StatefulWidget {
  final HomeController controller;

  const AskQuestionScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pollQuestionController = TextEditingController();
  final _pollOptionController = TextEditingController();
  
  List<String> _selectedTags = [];
  List<String> _pollOptions = [];
  bool _includesPoll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Question'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            const Text(
              'Question Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter a short and descriptive title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Description Field with Rich Text Editor
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AdvancedRichTextEditor(
              controller: _descriptionController,
              hintText: 'Provide detailed information about your question...',
              maxLines: 10,
            ),
            const SizedBox(height: 24),
            
            // Tags Selection
            const Text(
              'Tags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MultiSelectTagsWidget(
              availableTags: widget.controller.availableTags,
              selectedTags: _selectedTags,
              onTagsChanged: (tags) {
                setState(() {
                  _selectedTags = tags;
                });
              },
              hintText: 'Search and select relevant tags...',
            ),
            const SizedBox(height: 24),
            
            // Poll Option
            Row(
              children: [
                Checkbox(
                  value: _includesPoll,
                  onChanged: (value) {
                    setState(() {
                      _includesPoll = value ?? false;
                      if (!_includesPoll) {
                        _pollOptions.clear();
                        _pollQuestionController.clear();
                        _pollOptionController.clear();
                      }
                    });
                  },
                ),
                const Text('Include a poll with this question'),
              ],
            ),
            
            if (_includesPoll) ...[
              const SizedBox(height: 16),
              const Text(
                'Poll Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pollQuestionController,
                decoration: InputDecoration(
                  hintText: 'Enter your poll question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Poll Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Poll Options List
              if (_pollOptions.isNotEmpty)
                Column(
                  children: _pollOptions.map((option) => _buildPollOption(option)).toList(),
                ),
              
              // Add Poll Option
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pollOptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter poll option...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addPollOption,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: widget.controller.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Question', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollOption(String option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(option)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _pollOptions.remove(option);
              });
            },
          ),
        ],
      ),
    );
  }

  void _addPollOption() {
    if (_pollOptionController.text.isNotEmpty) {
      setState(() {
        _pollOptions.add(_pollOptionController.text);
        _pollOptionController.clear();
      });
    }
  }

  void _submitQuestion() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one tag')),
      );
      return;
    }

    widget.controller.postQuestion(
      _titleController.text,
      _descriptionController.text,
      _selectedTags,
      pollQuestion: _includesPoll ? _pollQuestionController.text : null,
      pollOptions: _includesPoll ? _pollOptions : null,
    ).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question posted successfully!')),
      );
    });
  }
}

