import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/create_quiz_screen.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/add_questions_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final quizProvider = Provider.of<QuizProvider>(context);
    final user = context.watch<AuthNotifier>().appUser;
    final canManage =
        user?.role == CourtRole.judge || user?.role == CourtRole.ict_specialist;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizzesTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.addQuestion,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
                );
              },
            ),
        ],
      ),
      body: quizProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizProvider.quizzes.isEmpty
              ? _buildEmptyState(l10n, theme)
              : _buildQuizList(quizProvider, canManage, l10n, theme),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.quiz_rounded,
              size: 72,
              color: theme.colorScheme.outline.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            l10n.noQuizzesFoundManager,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(QuizProvider quizProvider, bool canManage,
      AppLocalizations l10n, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizProvider.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizProvider.quizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (canManage) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddQuestionsScreen(quiz: quiz)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => QuizScreen(quizId: quiz.id)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Quiz icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + description + question count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (quiz.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            quiz.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        // Question count chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.questionsCount(quiz.questionCount),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow or manage actions
                  if (canManage)
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddQuestionsScreen(quiz: quiz)),
                          );
                        } else if (value == 'take') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => QuizScreen(quizId: quiz.id)),
                          );
                        } else if (value == 'delete') {
                          _confirmDelete(quiz.id, quiz.title);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'take',
                          child: Row(
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.startQuiz),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded,
                                  size: 20, color: Colors.red.shade400),
                              const SizedBox(width: 8),
                              Text(l10n.deleteButtonText,
                                  style: TextStyle(color: Colors.red.shade400)),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(String quizId, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteQuestionConfirm),
        content: Text(title),
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
        await Provider.of<QuizProvider>(context, listen: false)
            .deleteQuiz(quizId);
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
}
