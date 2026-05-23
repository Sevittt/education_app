import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/question.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

/// Full quiz-taking screen with start page, question stepper, and results.
class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

enum _QuizPhase { loading, start, playing, results }

class _QuizScreenState extends State<QuizScreen> {
  _QuizPhase _phase = _QuizPhase.loading;
  Quiz? _quiz;
  int _currentIndex = 0;
  final Map<int, String> _answers = {};
  int _score = 0;
  late DateTime _startTime;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final provider = Provider.of<QuizProvider>(context, listen: false);
      final quiz = await provider.fetchQuizById(widget.quizId);
      if (mounted) {
        setState(() {
          _quiz = quiz;
          _phase = (quiz != null && quiz.questions.isNotEmpty)
              ? _QuizPhase.start
              : _QuizPhase.start; // Show start page even if empty
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _phase = _QuizPhase.start);
      }
    }
  }

  void _startQuiz() {
    _startTime = DateTime.now();
    setState(() {
      _phase = _QuizPhase.playing;
      _currentIndex = 0;
      _answers.clear();
    });
  }

  void _selectAnswer(int questionIndex, String answer) {
    setState(() {
      _answers[questionIndex] = answer;
    });
  }

  void _goToNext() {
    if (_currentIndex < (_quiz?.questions.length ?? 1) - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuiz() async {
    if (_quiz == null) return;

    // Calculate score
    int correct = 0;
    for (int i = 0; i < _quiz!.questions.length; i++) {
      final question = _quiz!.questions[i];
      if (_answers[i] == question.correctAnswer) {
        correct++;
      }
    }

    final timeTaken = DateTime.now().difference(_startTime).inSeconds;
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _score = correct;
      _phase = _QuizPhase.results;
    });

    // Submit attempt to Firestore
    if (user != null) {
      try {
        final attempt = QuizAttempt(
          id: const Uuid().v4(),
          userId: user.uid,
          quizId: _quiz!.id,
          quizTitle: _quiz!.title,
          score: correct,
          totalQuestions: _quiz!.questions.length,
          attemptedAt: DateTime.now(),
          timeTakenSeconds: timeTaken,
        );

        final provider = Provider.of<QuizProvider>(context, listen: false);
        await provider.submitResult(attempt);
      } catch (e) {
        // Non-blocking error — results are shown regardless
        debugPrint('Failed to save quiz attempt: $e');
      }
    }
  }

  void _retakeQuiz() {
    setState(() {
      _phase = _QuizPhase.start;
      _currentIndex = 0;
      _answers.clear();
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _phase == _QuizPhase.playing
          ? AppBar(
              title: Text(
                l10n.questionOfTotal(
                    _currentIndex + 1, _quiz?.questions.length ?? 0),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_quiz?.questions.isNotEmpty ?? false)
                      ? (_currentIndex + 1) / _quiz!.questions.length
                      : 0,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            )
          : null,
      body: _buildBody(l10n, theme),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    switch (_phase) {
      case _QuizPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case _QuizPhase.start:
        return _buildStartPage(l10n, theme);
      case _QuizPhase.playing:
        return _buildPlayingPage(l10n, theme);
      case _QuizPhase.results:
        return _buildResultsPage(l10n, theme);
    }
  }

  /// Start page — quiz info + start button
  Widget _buildStartPage(AppLocalizations l10n, ThemeData theme) {
    final quiz = _quiz;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quiz icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  quiz?.title ?? l10n.loading,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                if (quiz?.description.isNotEmpty ?? false)
                  Text(
                    quiz!.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),

                // Stats chips
                if (quiz != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildInfoChip(
                        Icons.help_outline_rounded,
                        l10n.questionsCount(quiz.questions.length),
                        theme,
                      ),
                    ],
                  ),
                const SizedBox(height: 40),

                // Start or empty message
                if (quiz != null && quiz.questions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noQuestionsInQuiz,
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: quiz != null ? _startQuiz : null,
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: Text(
                        l10n.startQuiz,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Back button
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(l10n.backToQuizList),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Playing phase — PageView with questions
  Widget _buildPlayingPage(AppLocalizations l10n, ThemeData theme) {
    if (_quiz == null) return const SizedBox.shrink();

    final questions = _quiz!.questions;
    final isLastQuestion = _currentIndex == questions.length - 1;

    return Column(
      children: [
        // Question pages
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _buildQuestionPage(questions[index], index, theme, l10n);
            },
          ),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Previous
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _goToPrevious,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.previousQuestion),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),

                const SizedBox(width: 12),

                // Next or Submit
                Expanded(
                  child: isLastQuestion
                      ? FilledButton.icon(
                          onPressed: _answers.length == questions.length
                              ? _submitQuiz
                              : null,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(l10n.submitQuiz),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: _answers.containsKey(_currentIndex)
                              ? _goToNext
                              : null,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(l10n.nextQuestion),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Single question page
  Widget _buildQuestionPage(
      Question question, int index, ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Instruction
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l10n.selectAnAnswer,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final optionText = entry.value;
              final isSelected = _answers[index] == optionText;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectAnswer(index, optionText),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.08)
                            : theme.colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          // Option letter badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              String.fromCharCode(
                                  65 + optionIndex), // A, B, C, D
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                                color: theme.colorScheme.primary, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Results page
  Widget _buildResultsPage(AppLocalizations l10n, ThemeData theme) {
    if (_quiz == null) return const SizedBox.shrink();

    final total = _quiz!.questions.length;
    final percentage = total > 0 ? (_score / total * 100).round() : 0;
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 50 && percentage < 80;

    String scoreMessage;
    IconData scoreIcon;
    Color scoreColor;

    if (isExcellent) {
      scoreMessage = l10n.excellentScore;
      scoreIcon = Icons.emoji_events_rounded;
      scoreColor = Colors.amber;
    } else if (isGood) {
      scoreMessage = l10n.goodScore;
      scoreIcon = Icons.thumb_up_rounded;
      scoreColor = Colors.green;
    } else {
      scoreMessage = l10n.needsImprovement;
      scoreIcon = Icons.fitness_center_rounded;
      scoreColor = Colors.orange;
    }

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(scoreIcon, size: 52, color: scoreColor),
                ),
                const SizedBox(height: 20),

                // Score message
                Text(
                  scoreMessage,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Your Score label
                Text(
                  l10n.yourScore,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),

                // Score display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_score',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        ' / $total',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Answer review
                ...List.generate(_quiz!.questions.length, (index) {
                  final question = _quiz!.questions[index];
                  final userAnswer = _answers[index];
                  final isCorrect = userAnswer == question.correctAnswer;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.red.withValues(alpha: 0.5),
                      ),
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.05)
                          : Colors.red.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${question.questionText}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (!isCorrect) ...[
                                const SizedBox(height: 4),
                                Text(
                                  l10n.correctAnswerIs(question.correctAnswer),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _retakeQuiz,
                        icon: const Icon(Icons.replay_rounded),
                        label: Text(l10n.retakeQuiz),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text(l10n.backToQuizList),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
