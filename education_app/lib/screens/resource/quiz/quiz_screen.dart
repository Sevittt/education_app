// lib/screens/resource/quiz/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/quiz.dart';
import '../../../models/question.dart';
import '../../../models/quiz_attempt.dart';
import '../../../models/auth_notifier.dart';
import '../../../services/quiz_service.dart';
import 'quiz_results_screen.dart'; // We will create this next

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Quiz? _quiz;
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {}; // Map to store selected answers

  @override
  void initState() {
    super.initState();
    _fetchQuiz();
  }

  Future<void> _fetchQuiz() async {
    try {
      final quizService = Provider.of<QuizService>(context, listen: false);
      final quizData = await quizService.getQuizWithQuestions(widget.quizId);
      if (mounted) {
        setState(() {
          _quiz = quizData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load quiz: $e')));
      }
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  Future<void> _submitQuiz() async {
    final user = Provider.of<AuthNotifier>(context, listen: false).appUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a quiz.'),
        ),
      );
      return;
    }

    // Calculate score
    int score = 0;
    for (int i = 0; i < _quiz!.questions.length; i++) {
      if (_selectedAnswers[i] == _quiz!.questions[i].correctAnswer) {
        score++;
      }
    }

    // Create a quiz attempt object
    final attempt = QuizAttempt(
      id: '', // Firestore will generate
      userId: user.id,
      quizId: widget.quizId,
      score: score,
      totalQuestions: _quiz!.questions.length,
      attemptedAt: Timestamp.now(),
    );

    // Save the attempt
    try {
      final quizService = Provider.of<QuizService>(context, listen: false);
      await quizService.saveQuizAttempt(attempt);

      // Navigate to results screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizResultsScreen(
                  score: score,
                  totalQuestions: _quiz!.questions.length,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save your attempt: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Quiz not found.')),
      );
    }

    final Question currentQuestion = _quiz!.questions[_currentQuestionIndex];
    final bool isLastQuestion =
        _currentQuestionIndex == _quiz!.questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text(_quiz!.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_quiz!.questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              currentQuestion.questionText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ...currentQuestion.options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedAnswers[_currentQuestionIndex],
                onChanged: (value) {
                  setState(() {
                    _selectedAnswers[_currentQuestionIndex] = value!;
                  });
                },
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  _selectedAnswers[_currentQuestionIndex] == null
                      ? null
                      : (isLastQuestion ? _submitQuiz : _nextQuestion),
              child: Text(isLastQuestion ? 'Submit Quiz' : 'Next Question'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
