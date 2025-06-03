import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/quiz.dart';
import '../../../models/question.dart';
import '../../../models/quiz_attempt.dart';
import '../../../models/auth_notifier.dart';
import '../../../services/quiz_service.dart';
import 'quiz_results_screen.dart';

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
  final Map<int, String> _selectedAnswers = {};

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
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.failedToLoadQuiz}: $e')));
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
    final l10n = AppLocalizations.of(context)!;
    final user = Provider.of<AuthNotifier>(context, listen: false).appUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a quiz.'),
        ),
      );
      return;
    }

    int score = 0;
    for (int i = 0; i < _quiz!.questions.length; i++) {
      if (_selectedAnswers[i] == _quiz!.questions[i].correctAnswer) {
        score++;
      }
    }

    final attempt = QuizAttempt(
      id: '',
      userId: user.id,
      quizId: widget.quizId,
      quizTitle: _quiz!.title,
      score: score,
      totalQuestions: _quiz!.questions.length,
      attemptedAt: Timestamp.now(),
    );

    try {
      final quizService = Provider.of<QuizService>(context, listen: false);
      await quizService.saveQuizAttempt(attempt);

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
          SnackBar(content: Text('${l10n.failedToSaveAttempt}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.quizNotFound)),
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
              '${l10n.question('${_currentQuestionIndex + 1}')} ${l10n.totalQuestions('${_quiz!.questions.length}')}',
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
            }),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  _selectedAnswers[_currentQuestionIndex] == null
                      ? null
                      : (isLastQuestion ? _submitQuiz : _nextQuestion),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isLastQuestion ? l10n.submitQuiz : l10n.nextQuestion),
            ),
          ],
        ),
      ),
    );
  }
}
