
import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Quiz')),
      body: Center(
        child: Text('Quiz Taking Interface for ID: $quizId\n(Coming Soon)'),
      ),
    );
  }
}
