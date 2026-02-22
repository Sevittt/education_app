
import 'package:flutter/material.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';

class AddQuestionsScreen extends StatelessWidget {
  final Quiz quiz;

  const AddQuestionsScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Questions: ${quiz.title}'),
      ),
      body: const Center(
        child: Text('Questions Management Coming Soon'),
      ),
    );
  }
}
