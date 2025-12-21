import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../l10n/app_localizations.dart';

class QuizResultsScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Auto-play confetti if score is decent (e.g., > 70%)
    if (widget.score / widget.totalQuestions >= 0.7) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double percentage = (widget.score / widget.totalQuestions) * 100;
    final bool isSuccess = percentage >= 70;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizResults),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Confetti on top
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Icon/Emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          isSuccess ? '🎉' : '😔',
                          style: const TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isSuccess ? l10n.quizSuccessMessage : l10n.quizFailureMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.yourScore}: ${widget.score}/${widget.totalQuestions}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${percentage.toInt()}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.backToKnowledgeBase),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
