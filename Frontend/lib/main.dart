import 'package:flutter/material.dart';
import 'package:odoo25/controller/guest_controller.dart';
import 'package:odoo25/view/guest_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GuestQuestionController controller = GuestQuestionController();
    return MaterialApp(
      title: 'StackIt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: GuestQuestionView(controller: controller),
    );
  }
}
