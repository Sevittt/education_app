import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/get_leaderboard.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/get_leaderboard_by_court.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/get_leaderboard_by_region.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';
import 'package:sud_qollanma/shared/widgets/user_avatar.dart';

enum _Scope { court, region, global }

/// Reyting (Figma "09 · Reyting"): sud / viloyat / respublika, mening oʻrnim, top-3.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late _Scope _scope;
  final Map<_Scope, Stream<List<AppUser>>> _streams = {};

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthNotifier>().appUser;
    _scope = user?.courtId != null
        ? _Scope.court
        : user?.regionId != null
            ? _Scope.region
            : _Scope.global;
  }

  /// Oqim bir marta yaratiladi — har qayta chizishda qayta obuna boʻlinmaydi.
  Stream<List<AppUser>>? _stream(AppUser? user) {
    if (_streams.containsKey(_scope)) return _streams[_scope];
    final Stream<List<AppUser>>? s = switch (_scope) {
      _Scope.court => user?.courtId == null ? null : context.read<GetLeaderboardByCourt>().call(courtId: user!.courtId!),
      _Scope.region =>
        user?.regionId == null ? null : context.read<GetLeaderboardByRegion>().call(regionId: user!.regionId!),
      _Scope.global => context.read<GetLeaderboard>().call(),
    };
    if (s != null) _streams[_scope] = s;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final me = context.watch<AuthNotifier>().appUser;
    final stream = _stream(me);
    final scopeLabel = switch (_scope) {
      _Scope.court => me?.courtName,
      _Scope.region => me?.regionName,
      _Scope.global => null,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s24),
          children: [
            Row(children: [
              CircleIconButton(Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.maybePop(context)),
              const SizedBox(width: AppSpace.s12),
              Expanded(child: Text(l10n.dsLeaderboard, style: text.displayMedium)),
            ]),
            const SizedBox(height: AppSpace.s20),
            _Segmented(
              value: _scope,
              items: [
                (_Scope.court, l10n.dsScopeCourt),
                (_Scope.region, l10n.dsScopeRegion),
                (_Scope.global, l10n.dsScopeGlobal),
              ],
              onChanged: (s) => setState(() => _scope = s),
            ),
            if (scopeLabel != null) ...[
              const SizedBox(height: AppSpace.s12),
              Text(scopeLabel, style: text.bodySmall?.copyWith(color: t.textSecondary)),
            ],
            const SizedBox(height: AppSpace.s20),
            if (stream == null)
              _Message(_scope == _Scope.court ? l10n.noCourtInfo : l10n.noRegionInfo)
            else
              StreamBuilder<List<AppUser>>(
                stream: stream,
                builder: (context, snap) {
                  if (snap.hasError) return _Message('${l10n.errorPrefix}: ${snap.error}');
                  if (!snap.hasData) {
                    return const Padding(padding: EdgeInsets.all(AppSpace.s32), child: Center(child: CircularProgressIndicator()));
                  }
                  final users = snap.data!;
                  if (users.isEmpty) return _Message(l10n.noResultsFound);
                  return _Board(users: users, meId: me?.id);
                },
              ),
            const SizedBox(height: AppSpace.s20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 16, color: t.textTertiary),
              const SizedBox(width: AppSpace.s8),
              Expanded(child: Text(l10n.dsLeaderboardNote, style: text.bodySmall?.copyWith(color: t.textTertiary))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  final List<AppUser> users;
  final String? meId;

  const _Board({required this.users, required this.meId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final myIndex = users.indexWhere((u) => u.id == meId);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (myIndex >= 0) ...[
        _MyRankCard(users: users, index: myIndex),
        const SizedBox(height: AppSpace.s20),
      ] else ...[
        AppCard(
          color: t.brandContainer,
          border: false,
          child: Text(l10n.dsNotRanked, style: text.bodyMedium?.copyWith(color: t.brandOnContainer)),
        ),
        const SizedBox(height: AppSpace.s20),
      ],
      _Podium(top: users.take(3).toList()),
      if (users.length > 3) ...[
        const SizedBox(height: AppSpace.s16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (var i = 3; i < users.length; i++)
              _RankRow(user: users[i], rank: i + 1, isMe: users[i].id == meId, last: i == users.length - 1),
          ]),
        ),
      ],
    ]);
  }
}

class _MyRankCard extends StatelessWidget {
  final List<AppUser> users;
  final int index;

  const _MyRankCard({required this.users, required this.index});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final me = users[index];
    final rank = index + 1;
    final gap = index > 0 ? users[index - 1].xp - me.xp : 0;
    final delta = me.previousRank == null ? 0 : me.previousRank! - rank;
    final progress = index > 0 && users[index - 1].xp > 0 ? me.xp / users[index - 1].xp : 1.0;

    return AppCard(
      color: t.heroBg,
      border: false,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpace.s20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.dsYourRank, style: text.labelSmall?.copyWith(color: t.heroMuted)),
            Text('#$rank', style: text.headlineLarge?.copyWith(color: t.heroFg)),
            if (delta != 0)
              Row(children: [
                Icon(delta > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: t.goldSolid),
                const SizedBox(width: 4),
                Text(delta > 0 ? l10n.dsRankUp(delta) : l10n.dsRankDown(-delta),
                    style: text.labelMedium?.copyWith(color: t.heroFg)),
              ]),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(l10n.dsXpValue('${me.xp}'), style: text.titleLarge?.copyWith(color: t.heroFg)),
            if (index > 0) Text(l10n.dsRankGap(rank - 1, gap), style: text.bodySmall?.copyWith(color: t.heroMuted)),
          ]),
        ]),
        const SizedBox(height: 14),
        ProgressLine(value: progress, color: t.goldSolid, trackColor: t.heroTrack),
      ]),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<AppUser> top;

  const _Podium({required this.top});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final order = [if (top.length > 1) (top[1], 2), (top[0], 1), if (top.length > 2) (top[2], 3)];
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (final (user, rank) in order)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _PodiumColumn(
              user: user,
              rank: rank,
              ring: switch (rank) { 1 => t.goldSolid, 2 => t.borderStrong, _ => t.streakSolid },
              block: switch (rank) { 1 => t.goldContainer, 2 => t.bgSubtle, _ => t.streakContainer },
              blockText: switch (rank) { 1 => t.goldInk, 2 => t.textSecondary, _ => t.streakSolid },
            ),
          ),
        ),
    ]);
  }
}

class _PodiumColumn extends StatelessWidget {
  final AppUser user;
  final int rank;
  final Color ring;
  final Color block;
  final Color blockText;

  const _PodiumColumn({
    required this.user,
    required this.rank,
    required this.ring,
    required this.block,
    required this.blockText,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ring, width: 3)),
        child: UserAvatar(profilePictureUrl: user.profilePictureUrl, radius: rank == 1 ? 28 : 22, backgroundColor: t.brandContainer),
      ),
      const SizedBox(height: 6),
      Text(user.name.split(' ').first, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      Text('${user.xp} XP', style: text.labelMedium?.copyWith(color: t.textSecondary)),
      const SizedBox(height: 6),
      Container(
        height: switch (rank) { 1 => 80.0, 2 => 56.0, _ => 44.0 },
        alignment: Alignment.center,
        decoration: BoxDecoration(color: block, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Text('$rank', style: text.titleLarge?.copyWith(color: blockText)),
      ),
    ]);
  }
}

class _RankRow extends StatelessWidget {
  final AppUser user;
  final int rank;
  final bool isMe;
  final bool last;

  const _RankRow({required this.user, required this.rank, required this.isMe, required this.last});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final fg = isMe ? t.brandOnContainer : t.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: AppSpace.s12),
      decoration: BoxDecoration(
        color: isMe ? t.brandContainer : null,
        border: last ? null : Border(bottom: BorderSide(color: t.borderDefault)),
      ),
      child: Row(children: [
        SizedBox(
          width: 24,
          child: Text('$rank', textAlign: TextAlign.center,
              style: text.titleSmall?.copyWith(color: isMe ? t.brandOnContainer : t.textTertiary)),
        ),
        const SizedBox(width: AppSpace.s12),
        UserAvatar(profilePictureUrl: user.profilePictureUrl, radius: 18, backgroundColor: t.bgSubtle),
        const SizedBox(width: AppSpace.s12),
        Expanded(
          child: Text(isMe ? '${user.name} ${l10n.dsYou}' : user.name,
              style: text.titleSmall?.copyWith(color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text('${user.xp} XP', style: text.titleSmall?.copyWith(color: fg)),
      ]),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const _Segmented({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: t.bgSubtle, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(children: [
        for (final (v, label) in items)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v == value ? t.bgSurface : null,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(label,
                    style: v == value
                        ? text.titleSmall
                        : text.labelLarge?.copyWith(color: t.textSecondary)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Message extends StatelessWidget {
  final String message;

  const _Message(this.message);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s32),
        child: Center(
          child: Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.tokens.textSecondary)),
        ),
      );
}
