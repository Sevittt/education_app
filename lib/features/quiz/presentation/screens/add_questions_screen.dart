import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/question.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:sud_qollanma/shared/widgets/animated_button.dart';
import 'package:sud_qollanma/shared/widgets/radio_group.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

class AddQuestionsScreen extends StatefulWidget {
  final Quiz quiz;

  const AddQuestionsScreen({super.key, required this.quiz});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();

  QuestionType _questionType = QuestionType.multipleChoice;
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  String? _correctAnswer;
  bool _isLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<QuizProvider>(context, listen: false)
            .fetchQuizById(widget.quiz.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onQuestionTypeChanged(QuestionType? newValue) {
    if (newValue != null) {
      setState(() {
        _questionType = newValue;
        _correctAnswer = null;
      });
    }
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      if (_optionControllers.length > 2) {
        final removedController = _optionControllers.removeAt(index);
        removedController.dispose();
        if (_correctAnswer != null) {
          _correctAnswer = null;
        }
      }
    });
  }

  Future<void> _deleteQuestion(String questionId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteQuestionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButtonText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final provider = Provider.of<QuizProvider>(context, listen: false);
        await provider.deleteQuestion(widget.quiz.id, questionId);
        await provider.fetchQuizById(widget.quiz.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.questionDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.errorPrefix}$e')),
          );
        }
      }
    }
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    if (_correctAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCorrectAnswer)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      List<String> options = [];
      String actualCorrectAnswer = '';

      if (_questionType == QuestionType.multipleChoice) {
        options = _optionControllers.map((c) => c.text.trim()).toList();
        actualCorrectAnswer = options[int.parse(_correctAnswer!)];
      } else if (_questionType == QuestionType.trueFalse) {
        options = ['True', 'False'];
        actualCorrectAnswer = _correctAnswer!;
      }

      final newQuestion = Question(
        id: const Uuid().v4(),
        questionText: _questionTextController.text.trim(),
        questionType: _questionType,
        options: options,
        correctAnswer: actualCorrectAnswer,
      );

      await quizProvider.addQuestion(widget.quiz.id, newQuestion);
      await quizProvider.fetchQuizById(widget.quiz.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.questionAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
        // Switch to questions list tab to show the new question
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToAddQuestion}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _questionTextController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _questionType = QuestionType.multipleChoice;
      _correctAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    final quizProvider = Provider.of<QuizProvider>(context);
    final currentQuiz = quizProvider.quizzes.cast<Quiz>().firstWhere(
          (q) => q.id == widget.quiz.id,
          orElse: () => widget.quiz,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editQuestionsTitle(currentQuiz.title),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: isWide
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.list_alt_rounded),
                    text: l10n.questionsListTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.add_circle_outline),
                    text: l10n.addQuestionTab,
                  ),
                ],
              ),
      ),
      body: isWide
          ? _buildDesktopLayout(currentQuiz, l10n, theme)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsList(currentQuiz, l10n, theme),
                _buildAddQuestionForm(l10n, theme),
              ],
            ),
      // Floating action button on mobile to quickly switch to add tab
      floatingActionButton: isWide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.add),
              label: Text(l10n.addQuestion),
            ),
    );
  }

  /// Desktop: side-by-side layout
  Widget _buildDesktopLayout(
      Quiz quiz, AppLocalizations l10n, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildQuestionsList(quiz, l10n, theme),
        ),
        Expanded(
          flex: 3,
          child: _buildAddQuestionForm(l10n, theme),
        ),
      ],
    );
  }

  /// Questions list panel
  Widget _buildQuestionsList(
      Quiz quiz, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count
          Row(
            children: [
              Icon(Icons.quiz_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.questionsListTab,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.questionsCount(quiz.questions.length),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Questions list
          Expanded(
            child: quiz.questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 64,
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noQuestionsAddedYet,
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: quiz.questions.length,
                    itemBuilder: (context, index) {
                      final question = quiz.questions[index];
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.zero,
                        child: _QuestionCard(
                          index: index,
                          question: question,
                          l10n: l10n,
                          theme: theme,
                          onDelete: () => _deleteQuestion(question.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Add question form panel
  Widget _buildAddQuestionForm(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.add_circle_outline,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.addQuestion,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question Text
            TextFormField(
              controller: _questionTextController,
              decoration: InputDecoration(
                labelText: l10n.questionText,
                hintText: l10n.pleaseEnterAQuestion,
                prefixIcon: const Icon(Icons.help_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterAQuestion;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Question Type
            DropdownButtonFormField<QuestionType>(
              // ignore: deprecated_member_use
              value: _questionType,
              decoration: InputDecoration(
                labelText: l10n.questionType,
                prefixIcon: const Icon(Icons.category_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              items: [
                DropdownMenuItem(
                  value: QuestionType.multipleChoice,
                  child: Text(l10n.multipleChoice),
                ),
                DropdownMenuItem(
                  value: QuestionType.trueFalse,
                  child: Text(l10n.trueFalse),
                ),
              ],
              onChanged: _onQuestionTypeChanged,
            ),
            const SizedBox(height: 20),

            // Dynamic Options
            if (_questionType == QuestionType.multipleChoice) ...[
              Text(
                l10n.multipleChoice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.pleaseSelectCorrectAnswer,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              AppRadioGroup<String>(
                groupValue: _correctAnswer ?? '',
                onChanged: (value) {
                  setState(() => _correctAnswer = value);
                },
                child: Column(
                  children: List.generate(_optionControllers.length, (index) {
                    final isSelected = _correctAnswer == index.toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 12,
                        isHighlighted: isSelected,
                        child: Row(
                          children: [
                            AppRadio<String>(
                              value: index.toString(),
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: l10n.option(index + 1),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.pleaseEnterAnOption;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_optionControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.red, size: 20),
                                onPressed: () => _removeOption(index),
                                tooltip: l10n.deleteButtonText,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addOptionButton),
                  onPressed: _addOption,
                ),
              ),
            ] else if (_questionType == QuestionType.trueFalse) ...[
              Text(
                l10n.trueFalse,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              AppRadioGroup<String>(
                groupValue: _correctAnswer ?? '',
                onChanged: (value) {
                  setState(() => _correctAnswer = value);
                },
                child: Column(
                  children: [
                    _buildTrueFalseOption(
                      label: l10n.trueOption,
                      value: 'True',
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    _buildTrueFalseOption(
                      label: l10n.falseOption,
                      value: 'False',
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit Button
            AnimatedButton(
              onPressed: _isLoading ? null : _submitQuestion,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: null, // Handled by AnimatedButton
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    l10n.saveButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseOption({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    final isSelected = _correctAnswer == value;
    return GlassCard(
      onTap: () => setState(() => _correctAnswer = value),
      borderRadius: 12,
      padding: EdgeInsets.zero,
      isHighlighted: isSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            AppRadio<String>(
              value: value,
              activeColor: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual question card widget
class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.l10n,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Question text
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 20),
                  onPressed: onDelete,
                  tooltip: l10n.deleteButtonText,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Type badge + correct answer
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildChip(
                  icon: question.questionType == QuestionType.multipleChoice
                      ? Icons.checklist_rounded
                      : Icons.toggle_on_rounded,
                  label: question.questionType == QuestionType.multipleChoice
                      ? l10n.multipleChoice
                      : l10n.trueFalse,
                  color: theme.colorScheme.secondaryContainer,
                  textColor: theme.colorScheme.onSecondaryContainer,
                ),
                _buildChip(
                  icon: Icons.check_circle_outline,
                  label: '${l10n.correctAnswer}: ${question.correctAnswer}',
                  color: Colors.green.shade50,
                  textColor: Colors.green.shade800,
                ),
              ],
            ),
            // Show options as mini-list
            if (question.options.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...question.options.asMap().entries.map((entry) {
                final isCorrect = entry.value == question.correctAnswer;
                return Padding(
                  padding: const EdgeInsets.only(left: 42, bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: isCorrect
                            ? Colors.green
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isCorrect ? FontWeight.w600 : FontWeight.w400,
                            color: isCorrect
                                ? Colors.green.shade700
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
