import 'package:flutter/material.dart';
import 'package:odoo25/controller/guest_controller.dart';
import 'package:odoo25/controller/login_controller.dart';
import 'package:odoo25/controller/signup_controller.dart';
import 'package:odoo25/view/login_page.dart';
import 'package:odoo25/view/signup_page.dart';

class GuestQuestionView extends StatefulWidget {
  final GuestQuestionController controller;

  const GuestQuestionView({Key? key, required this.controller}) : super(key: key);

  @override
  State<GuestQuestionView> createState() => _GuestQuestionViewState();
}

class _GuestQuestionViewState extends State<GuestQuestionView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    setState(() {});
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Show login/signup popup
                _showLoginSignupPopup(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Login/Signup'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: widget.controller.filteredQuestions.length,
              itemBuilder: (context, index) {
                final question = widget.controller.filteredQuestions[index];
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: () => _showLoginSignupPopup(context),
                              color: Colors.green,
                            ),
                            Text('${question.upvotes}'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: () => _showLoginSignupPopup(context),
                              color: Colors.red,
                            ),
                            Text('${question.downvotes}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginSignupPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login/Signup Required'),
          content: const Text('Please login or sign up to perform this action.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Login'),
              onPressed: () {
               Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView(controller: LoginController())),
                  );
              },
            ),
            TextButton(
              child: const Text('Signup'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupView(controller: SignupController(),)));
              },
            ),
          ],
        );
      },
    );
  }
}