import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/create_quiz_screen.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/models/users.dart';

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
      if (mounted) {
        context.read<QuizProvider>().fetchQuizzes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quizProvider = Provider.of<QuizProvider>(context);
    final user = context.watch<AuthNotifier>().appUser;
    final canManage =
        user?.role == UserRole.ekspert || user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(l10n.quizzesTitle), // Ensure this key exists or use 'Quizzes'
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.add),
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
              ? Center(
                  child: Text(l10n.noQuizzesFoundManager)) // Ensure key exists
              : ListView.builder(
                  itemCount: quizProvider.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizProvider.quizzes[index];
                    return ListTile(
                      title: Text(quiz.title),
                      subtitle: Text(quiz.description),
                      onTap: () {
                        // Navigate to quiz detail/start
                      },
                    );
                  },
                ),
    );
  }
}
