import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sud_qollanma/config/gamification_rules.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/question.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_result.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

/// Test ekrani (Figma "05 · Test", "06/07 · Natija"): boshlash, savollar, natija.
/// Yopilganda eng yaxshi [QuizResult] ni qaytaradi; test topshirilmagan bo'lsa null.
class QuizScreen extends StatefulWidget {
  final String quizId;

  /// Kurs darsining oʻtish chegarasi; berilmasa umumiy qoida (70%).
  final int? minPassPercent;

  const QuizScreen({super.key, required this.quizId, this.minPassPercent});

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
  QuizResult? _bestResult;
  late DateTime _startTime;
  final PageController _pageController = PageController();
  bool _showReview = false;

  int get _passPercent => widget.minPassPercent ?? GamificationRules.quizPassPercent;

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
          _phase = _QuizPhase.start;
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
      _showReview = false;
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
      _bestResult = QuizResult(
        correct: correct,
        total: _quiz!.questions.length,
      ).bestOf(_bestResult);
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
      _showReview = false;
    });
  }

  void _close() => Navigator.pop(context, _bestResult);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Natija bo'lsa, har qanday orqaga qaytish (tizim tugmasi, AppBar) uni qaytaradi
    return PopScope(
      canPop: _bestResult == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _bestResult);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: switch (_phase) {
            _QuizPhase.loading => const Center(child: CircularProgressIndicator()),
            _QuizPhase.start => _buildStartPage(l10n),
            _QuizPhase.playing => _buildPlayingPage(l10n),
            _QuizPhase.results => _buildResultsPage(l10n),
          },
        ),
      ),
    );
  }

  Widget _topBar(String title, {String? subtitle}) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s8),
      child: Row(children: [
        CircleIconButton(Icons.close_rounded, onPressed: _close),
        const SizedBox(width: AppSpace.s12),
        Expanded(
          child: Column(children: [
            if (subtitle != null)
              Text(subtitle,
                  style: text.labelMedium?.copyWith(color: t.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            Text(title, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 52),
      ]),
    );
  }

  /// Boshlash sahifasi — test haqida maʼlumot va boshlash tugmasi
  Widget _buildStartPage(AppLocalizations l10n) {
    final quiz = _quiz;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final empty = quiz == null || quiz.questions.isEmpty;

    return Column(children: [
      _topBar(l10n.dsQuizTitle),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(children: [
                IconTile(Icons.checklist_rounded, size: 88, background: t.brandContainer, foreground: t.brandPrimary),
                const SizedBox(height: AppSpace.s24),
                Text(quiz?.title ?? l10n.loading, style: text.displayMedium, textAlign: TextAlign.center),
                if (quiz?.description.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpace.s8),
                  Text(quiz!.description,
                      style: text.bodyMedium?.copyWith(color: t.textSecondary), textAlign: TextAlign.center),
                ],
                const SizedBox(height: AppSpace.s20),
                if (quiz != null)
                  Wrap(spacing: AppSpace.s8, runSpacing: AppSpace.s8, alignment: WrapAlignment.center, children: [
                    StatusBadge(l10n.questionsCount(quiz.questions.length), tone: BadgeTone.neutral, icon: Icons.help_outline_rounded),
                    StatusBadge(l10n.dsPassThreshold(_passPercent), tone: BadgeTone.brand, icon: Icons.flag_outlined),
                  ]),
                const SizedBox(height: AppSpace.s32),
                if (quiz != null && quiz.questions.isEmpty)
                  AppCard(
                    color: t.bgSubtle,
                    border: false,
                    child: Column(children: [
                      Icon(Icons.inbox_rounded, size: 40, color: t.textTertiary),
                      const SizedBox(height: AppSpace.s8),
                      Text(l10n.noQuestionsInQuiz, style: text.bodyMedium?.copyWith(color: t.textSecondary)),
                    ]),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: empty ? null : _startQuiz,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.startQuiz),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  /// Savollar bosqichi
  Widget _buildPlayingPage(AppLocalizations l10n) {
    if (_quiz == null) return const SizedBox.shrink();
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final questions = _quiz!.questions;
    final isLastQuestion = _currentIndex == questions.length - 1;

    return Column(children: [
      _topBar(_quiz!.title),
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s4, AppSpace.s16, 0),
        child: Column(children: [
          Row(children: [
            Text(l10n.questionOfTotal(_currentIndex + 1, questions.length), style: text.titleSmall),
            const Spacer(),
            Text(l10n.dsPassThreshold(_passPercent), style: text.labelMedium?.copyWith(color: t.textTertiary)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < questions.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentIndex
                        ? t.goldSolid
                        : _answers.containsKey(i)
                            ? t.brandPrimary
                            : t.bgSubtle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ]),
        ]),
      ),
      Expanded(
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) => _buildQuestionPage(questions[index], index, l10n),
        ),
      ),
      StickyActionBar(children: [
        Row(children: [
          if (_currentIndex > 0) ...[
            OutlinedButton.icon(
              onPressed: _goToPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
              label: Text(l10n.previousQuestion),
            ),
            const SizedBox(width: AppSpace.s12),
          ],
          Expanded(
            child: isLastQuestion
                ? FilledButton.icon(
                    onPressed: _answers.length == questions.length ? _submitQuiz : null,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.submitQuiz),
                  )
                : FilledButton.icon(
                    onPressed: _answers.containsKey(_currentIndex) ? _goToNext : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(l10n.nextQuestion),
                  ),
          ),
        ]),
      ]),
    ]);
  }

  /// Bitta savol sahifasi
  Widget _buildQuestionPage(Question question, int index, AppLocalizations l10n) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s20, AppSpace.s16, AppSpace.s24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l10n.selectAnAnswer.toUpperCase(), style: text.labelSmall?.copyWith(color: t.textTertiary)),
        const SizedBox(height: AppSpace.s8),
        Text(question.questionText, style: text.titleLarge),
        const SizedBox(height: AppSpace.s20),
        for (final (optionIndex, optionText) in question.options.indexed) ...[
          _OptionCard(
            letter: String.fromCharCode(65 + optionIndex),
            text: optionText,
            selected: _answers[index] == optionText,
            onTap: () => _selectAnswer(index, optionText),
          ),
          const SizedBox(height: AppSpace.s12),
        ],
      ]),
    );
  }

  /// Natija sahifasi (oʻtdi / oʻtmadi)
  Widget _buildResultsPage(AppLocalizations l10n) {
    if (_quiz == null) return const SizedBox.shrink();
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final questions = _quiz!.questions;
    final total = questions.length;
    final result = QuizResult(correct: _score, total: total);
    final passed = result.passes(_passPercent);
    final needed = ((_passPercent * total) / 100).ceil() - _score;
    final wrong = [for (var i = 0; i < total; i++) if (_answers[i] != questions[i].correctAnswer) i];

    return Column(children: [
      _topBar(l10n.dsQuizResultTitle, subtitle: _quiz!.title),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s16, AppSpace.s16, AppSpace.s24),
          child: Column(children: [
            ProgressRing(
              value: total > 0 ? _score / total : 0,
              size: 168,
              thickness: 14,
              color: passed ? t.successSolid : t.dangerSolid,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${result.percent}%', style: text.headlineLarge),
                Text(l10n.dsCorrectOfTotal(_score, total), style: text.bodySmall?.copyWith(color: t.textSecondary)),
              ]),
            ),
            const SizedBox(height: AppSpace.s20),
            StatusBadge(passed ? l10n.dsPassed : l10n.dsNotPassed,
                tone: passed ? BadgeTone.success : BadgeTone.danger,
                icon: passed ? Icons.check_rounded : Icons.close_rounded),
            const SizedBox(height: AppSpace.s8),
            Text(passed ? l10n.dsQuizPassedTitle : l10n.dsQuizFailedTitle,
                style: text.displayMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.s8),
            Text(
              passed ? l10n.dsQuizPassedBody(_passPercent) : l10n.dsQuizFailedBody(_passPercent, needed.clamp(1, total)),
              style: text.bodyMedium?.copyWith(color: t.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!passed) ...[
              const SizedBox(height: AppSpace.s20),
              AppCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, color: t.textSecondary),
                  const SizedBox(width: AppSpace.s12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.dsNoXpThisAttempt, style: text.titleSmall),
                      Text(l10n.dsNoXpThisAttemptBody, style: text.bodySmall?.copyWith(color: t.textSecondary)),
                    ]),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: AppSpace.s20),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(l10n.dsQuestions, style: text.titleSmall),
                  const Spacer(),
                  Text(l10n.dsCorrectWrong(_score, wrong.length),
                      style: text.labelMedium?.copyWith(color: t.textSecondary)),
                ]),
                const SizedBox(height: AppSpace.s12),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (var i = 0; i < total; i++)
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: wrong.contains(i) ? t.dangerContainer : t.successContainer,
                      ),
                      child: Text('${i + 1}',
                          style: text.labelMedium
                              ?.copyWith(color: wrong.contains(i) ? t.dangerSolid : t.successSolid)),
                    ),
                ]),
              ]),
            ),
            if (_showReview) ...[
              const SizedBox(height: AppSpace.s12),
              for (final i in wrong) ...[
                AppCard(
                  color: t.dangerContainer,
                  border: false,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${i + 1}. ${questions[i].questionText}', style: text.titleSmall),
                    const SizedBox(height: 4),
                    Text(l10n.correctAnswerIs(questions[i].correctAnswer),
                        style: text.bodySmall?.copyWith(color: t.successSolid)),
                  ]),
                ),
                const SizedBox(height: AppSpace.s8),
              ],
            ],
          ]),
        ),
      ),
      StickyActionBar(children: [
        if (passed)
          FilledButton.icon(
            onPressed: _close,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(l10n.dsContinueButton),
          )
        else
          FilledButton.icon(
            onPressed: _retakeQuiz,
            icon: const Icon(Icons.replay_rounded),
            label: Text(l10n.retakeQuiz),
          ),
        const SizedBox(height: AppSpace.s8),
        if (wrong.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => setState(() => _showReview = !_showReview),
            icon: Icon(_showReview ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            label: Text(l10n.dsReviewAnswers),
          )
        else
          OutlinedButton(onPressed: _close, child: Text(l10n.backToQuizList)),
      ]),
    ]);
  }
}

class _OptionCard extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({required this.letter, required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = Theme.of(context).textTheme;
    return Material(
      color: selected ? t.brandContainer : t.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? t.brandPrimary : t.borderDefault, width: selected ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s16),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? t.brandPrimary : t.bgSubtle),
              child: Text(letter, style: style.titleSmall?.copyWith(color: selected ? t.textOnBrand : t.textSecondary)),
            ),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: Text(text, style: style.bodyLarge?.copyWith(color: selected ? t.brandOnContainer : t.textPrimary)),
            ),
            if (selected) ...[
              const SizedBox(width: AppSpace.s8),
              Icon(Icons.check_circle_outline_rounded, color: t.brandPrimary),
            ],
          ]),
        ),
      ),
    );
  }
}
