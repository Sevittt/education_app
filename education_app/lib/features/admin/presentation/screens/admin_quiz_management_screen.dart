// lib/screens/admin/admin_quiz_management_screen.dart
//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart' show AppLocalizations;
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/create_quiz_screen.dart'; // For adding new or editing quiz details
import 'package:sud_qollanma/features/quiz/presentation/screens/add_questions_screen.dart'; // For managing questions of a quiz

class AdminQuizManagementScreen extends StatefulWidget {
  const AdminQuizManagementScreen({super.key});

  @override
  State<AdminQuizManagementScreen> createState() =>
      _AdminQuizManagementScreenState();
}

class _AdminQuizManagementScreenState extends State<AdminQuizManagementScreen> {
  Future<void> _deleteQuiz(
    BuildContext context,
    Quiz quiz,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmDeleteTitle),
          content: Text(
            l10n.confirmDeleteQuizMessage(quiz.title),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancelButtonText),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n.deleteButtonText),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<QuizProvider>().deleteQuiz(quiz.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.quizDeletedSuccess(quiz.title),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.failedToDeleteQuiz(quiz.title, e.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageQuizzesTitle), // "Manage Quizzes"
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.addQuizTooltip, // "Add New Quiz"
            onPressed: () {
              // Navigate to CreateQuizScreen for adding a new quiz.
              // CreateQuizScreen will need to be able to handle creating a quiz
              // without a resourceId or with a generic/admin-defined one if necessary.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateQuizScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (quizProvider.error != null) {
            return Center(
              child: Text(
                l10n.errorLoadingQuizzesAdmin(quizProvider.error.toString()),
              ),
            ); // "Error loading quizzes: {error}"
          }
          final quizzes = quizProvider.quizzes;
          if (quizzes.isEmpty) {
            return Center(
              child: Text(l10n.noQuizzesFoundManager),
            ); // "No quizzes found. Add one!"
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.quiz_outlined,
                        size: 30,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        quiz.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        quiz.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // onTap: () {
                      //   // Optionally navigate to a quiz detail view for admin if needed
                      // },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: OverflowBar(
                        alignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton.icon(
                            icon: Icon(
                              Icons.edit_note_outlined,
                              size: 20,
                              color: colorScheme.secondary,
                            ),
                            label: Text(
                              l10n.editDetailsButton,
                            ), // "Edit Details"
                            onPressed: () {
                              // For editing quiz details (title, description, resourceId)
                              // You might need a dedicated screen or adapt CreateQuizScreen
                              // For now, let's assume CreateQuizScreen can be adapted if it takes an optional Quiz object
                              // Or you'd create an AdminEditQuizDetailsScreen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Edit Details for "${quiz.title}" (To be implemented)',
                                  ),
                                ),
                              );
                              // Example:
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateQuizScreen(quizToEdit: quiz)));
                            },
                          ),
                          TextButton.icon(
                            icon: Icon(
                              Icons.list_alt_outlined,
                              size: 20,
                              color: colorScheme.secondary,
                            ),
                            label: Text(
                              l10n.manageQuestionsButton,
                            ), // "Manage Questions"
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddQuestionsScreen(quiz: quiz),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            tooltip: l10n.deleteQuizTooltip, // "Delete Quiz"
                            onPressed: () => _deleteQuiz(context, quiz),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 4),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.addQuizButton), // "Add Quiz"
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQuizScreen()),
          );
        },
      ),
    );
  }
}

// Add these localization keys to your .arb files:
// "manageQuizzesTitle": "Manage Quizzes",
// "addQuizTooltip": "Add New Quiz",
// "errorLoadingQuizzesAdmin": "Error loading quizzes: {error}",
// "noQuizzesFoundManager": "No quizzes found. Add one!",
// "confirmDeleteQuizMessage": "Are you sure you want to delete quiz \"{quizTitle}\" and all its questions? This action cannot be undone.",
// "quizDeletedSuccess": "Quiz \"{quizTitle}\" and its questions deleted successfully.",
// "failedToDeleteQuiz": "Failed to delete quiz \"{quizTitle}\": {error}",
// "editDetailsButton": "Edit Details",
// "manageQuestionsButton": "Questions",
// "deleteQuizTooltip": "Delete Quiz and Questions",
// "addQuizButton": "Add Quiz"
// (You should already have "confirmDeleteTitle", "cancelButtonText", "deleteButtonText")
