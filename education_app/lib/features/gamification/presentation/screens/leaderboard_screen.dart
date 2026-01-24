import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/usecases/get_leaderboard.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Safely access AuthNotifier
    final authNotifier = context.watch<AuthNotifier>();
    final currentUserId = authNotifier.appUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboardTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AppUser>>(
        // Using Clean Architecture UseCase injected via Provider
        stream: context.read<GetLeaderboard>().call(),
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

          final top3 = users.take(3).toList();
          final others = users.skip(3).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildPodium(context, top3),
                ),
              ),
              if (others.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = others[index];
                        final isCurrentUser = user.id == currentUserId;
                        final rank = index + 4;

                        return _buildLeaderboardTile(context, user, rank, isCurrentUser);
                      },
                      childCount: others.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<AppUser> top3) {
    if (top3.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (top3.length > 1) _buildPodiumItem(context, top3[1], 2, 100), // 2nd
        if (top3.isNotEmpty) _buildPodiumItem(context, top3[0], 1, 130), // 1st
        if (top3.length > 2) _buildPodiumItem(context, top3[2], 3, 80),  // 3rd
      ],
    );
  }

  Widget _buildPodiumItem(BuildContext context, AppUser user, int rank, double height) {
    final color = rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey.shade400 : const Color(0xFFCD7F32));
    final emoji = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        CircleAvatar(
          radius: rank == 1 ? 35 : 28,
          backgroundColor: color.withAlpha(26),
          child: Icon(Icons.person, size: rank == 1 ? 40 : 30, color: color),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            user.name.split(' ')[0],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${user.xp} XP',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.bold, color: color.withAlpha(150)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, AppUser user, int rank, bool isCurrentUser) {
    return Card(
      elevation: isCurrentUser ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser 
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${user.id.substring(0, 4)}...'), // Assuming user.level was legacy or not in Entity
        trailing: Text(
          '${user.xp} XP',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
