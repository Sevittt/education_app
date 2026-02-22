import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import '../../models/quiz_attempt.dart';
import '../../services/quiz_service.dart';
import '../../widgets/quiz_attempt_card.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = context.read<AuthNotifier>().appUser?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quizHistoryTitle)),
        body: Center(child: Text(l10n.loginRequired)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizHistoryTitle),
      ),
      body: StreamBuilder<List<QuizAttempt>>(
        stream: Provider.of<QuizService>(context, listen: false)
            .getAttemptsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('${l10n.errorPrefix}: ${snapshot.error}'));
          }
          final attempts = snapshot.data ?? [];

          if (attempts.isEmpty) {
            return Center(child: Text(l10n.noResultsFound));
          }

          // Use a simple list view with basic date headers
          // Since building a full StickyHeader list is complex from scratch,
          // we will manually insert header items into the list.
          final groupedItems = _groupAttempts(attempts, l10n);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groupedItems.length,
            itemBuilder: (context, index) {
              final item = groupedItems[index];
              if (item is String) {
                // Header
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              } else if (item is QuizAttempt) {
                // Attempt Card
                return QuizAttemptCard(
                  quizTitle: item.quizTitle,
                  score: item.score,
                  totalQuestions: item.totalQuestions,
                  attemptedAt: item.attemptedAt.toDate(),
                  onTap: () {},
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  // Helper to group attempts by date
  List<dynamic> _groupAttempts(
      List<QuizAttempt> attempts, AppLocalizations l10n) {
    final List<dynamic> items = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    String? currentHeader;

    for (var attempt in attempts) {
      final date = attempt.attemptedAt.toDate();
      final dateOnly = DateTime(date.year, date.month, date.day);

      String header;
      if (dateOnly.isAtSameMomentAs(today)) {
        header = l10n.today;
      } else if (dateOnly.isAtSameMomentAs(yesterday)) {
        header = l10n.yesterday;
      } else if (date.isAfter(weekAgo)) {
        header = l10n.thisWeek; // Ensure this key is added
      } else {
        header = l10n.older; // Ensure this key is added
      }

      if (currentHeader != header) {
        items.add(header);
        currentHeader = header;
      }
      items.add(attempt);
    }
    return items;
  }
}
