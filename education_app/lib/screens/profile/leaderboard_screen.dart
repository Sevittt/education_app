import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/users.dart';
import '../../services/gamification_service.dart';
import '../../models/auth_notifier.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authNotifier = context.watch<AuthNotifier>();
    final currentUserId = authNotifier.appUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboardTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: GamificationService().getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.errorPrefix}: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text(l10n.noResultsFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isCurrentUser = user.id == currentUserId;
              final rank = index + 1;

              return Card(
                elevation: isCurrentUser ? 4 : 1,
                color: isCurrentUser 
                    ? Theme.of(context).colorScheme.primaryContainer 
                    : null,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isCurrentUser 
                      ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: _buildRankWidget(rank, context),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    user.level, // Localizing this would be ideal if possible
                    style: TextStyle(
                      color: isCurrentUser 
                          ? Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(179) 
                          : Colors.grey.shade600,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrentUser 
                          ? Theme.of(context).primaryColor 
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${user.xp} XP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRankWidget(int rank, BuildContext context) {
    if (rank == 1) {
      return const CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text('🥇', style: TextStyle(fontSize: 24)),
      );
    } else if (rank == 2) {
      return CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: const Text('🥈', style: TextStyle(fontSize: 24)),
      );
    } else if (rank == 3) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFCD7F32), // Bronze
        child: Text('🥉', style: TextStyle(fontSize: 24)),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Text(
          '#$rank', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).colorScheme.onSurface
          ),
        ),
      );
    }
  }
}
