import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/usecases/get_leaderboard.dart';
import '../../domain/usecases/get_leaderboard_by_region.dart';
import '../../domain/usecases/get_leaderboard_by_court.dart';
import '../../../../shared/widgets/user_avatar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Safely access AuthNotifier
    final authNotifier = context.watch<AuthNotifier>();
    final currentUserId = authNotifier.appUser?.id;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.leaderboardTitle),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: l10n.leaderboardTabGlobal),
              Tab(text: l10n.leaderboardTabRegion),
              Tab(text: l10n.leaderboardTabCourt),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeaderboardTab(
                context, context.read<GetLeaderboard>().call(), currentUserId),
            if (authNotifier.appUser?.regionId != null)
              _buildLeaderboardTab(
                  context,
                  context.read<GetLeaderboardByRegion>().call(
                      regionId: authNotifier.appUser!.regionId!),
                  currentUserId)
            else
              Center(child: Text(l10n.noRegionInfo)),
            if (authNotifier.appUser?.courtId != null)
              _buildLeaderboardTab(
                  context,
                  context.read<GetLeaderboardByCourt>().call(
                      courtId: authNotifier.appUser!.courtId!),
                  currentUserId)
            else
              Center(child: Text(l10n.noCourtInfo)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(
      BuildContext context, Stream<List<AppUser>> stream, String? currentUserId) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<AppUser>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: SelectableText('${l10n.errorPrefix}: ${snapshot.error}'));
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

                      return _buildLeaderboardTile(
                          context, user, rank, isCurrentUser);
                    },
                    childCount: others.length,
                  ),
                ),
              ),
          ],
        );
      },
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
        if (top3.length > 2) _buildPodiumItem(context, top3[2], 3, 80), // 3rd
      ],
    );
  }

  Widget _buildPodiumItem(
      BuildContext context, AppUser user, int rank, double height) {
    final color = rank == 1
        ? Colors.amber
        : (rank == 2 ? Colors.grey.shade400 : const Color(0xFFCD7F32));
    final emoji = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        UserAvatar(
          profilePictureUrl: user.profilePictureUrl,
          radius: rank == 1 ? 35 : 28,
          backgroundColor: color.withAlpha(26),
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
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color.withAlpha(150)),
              ),
              _buildRankChangeIndicator(rank, user.previousRank, mini: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
      BuildContext context, AppUser user, int rank, bool isCurrentUser) {
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
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                _buildRankChangeIndicator(rank, user.previousRank, mini: true),
              ],
            ),
            const SizedBox(width: 8),
            UserAvatar(
              profilePictureUrl: user.profilePictureUrl,
              radius: 18,
            ),
          ],
        ),
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: null,
        trailing: Text(
          '${user.xp} XP',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildRankChangeIndicator(int currentRank, int? previousRank,
      {bool mini = false}) {
    if (previousRank == null || previousRank == currentRank) {
      return const SizedBox.shrink();
    }

    final delta = previousRank - currentRank;
    final isUp = delta > 0;
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: mini ? 14 : 18),
        Text(
          '${delta.abs()}',
          style: TextStyle(
            color: color,
            fontSize: mini ? 9 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
