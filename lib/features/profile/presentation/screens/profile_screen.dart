import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/config/gamification_rules.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/gamification/presentation/screens/leaderboard_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_history_screen.dart';
import 'package:sud_qollanma/features/settings/presentation/screens/settings_screen.dart';
import 'package:sud_qollanma/features/settings/presentation/screens/theme_options_screen.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';
import 'package:sud_qollanma/shared/widgets/level_names.dart';
import 'package:sud_qollanma/shared/widgets/user_avatar.dart';
import 'profile_edit_screen.dart';

/// Profil (Figma "08 · Profil"): daraja talablari, statistika, reyting va menyu.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static String roleName(CourtRole role, AppLocalizations l10n) => switch (role) {
        CourtRole.judge => l10n.registrationRoleJudge,
        CourtRole.assistant => l10n.registrationRoleAssistant,
        CourtRole.chancellery => l10n.registrationRoleChancellery,
        CourtRole.archive => l10n.registrationRoleArchive,
        CourtRole.ict_specialist => l10n.registrationRoleIctSpecialist,
        CourtRole.admin => l10n.dsRoleAdmin,
        CourtRole.unknown => l10n.dsRoleUnknown,
      };

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final auth = context.watch<AuthNotifier>();
    final user = auth.appUser;
    final courses = context.watch<CourseProvider>();

    final completed = courses.courses.where((c) => courses.getUserProgress(c.id)?.isCompleted == true).toList();
    final certificates = completed.where((c) => c.hasCertificate).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s24),
        children: [
          Row(children: [
            Expanded(child: Text(l10n.profileScreenTitle, style: text.displayMedium)),
            CircleIconButton(Icons.settings_outlined,
                tooltip: l10n.settingsTitle, onPressed: () => _push(context, const SettingsScreen())),
          ]),
          const SizedBox(height: AppSpace.s16),
          AppCard(
            onTap: user == null ? null : () => _push(context, const ProfileEditScreen()),
            child: Row(children: [
              UserAvatar(
                profilePictureUrl: user?.profilePictureUrl ?? auth.currentUser?.profilePictureUrl,
                radius: 32,
                backgroundColor: t.brandContainer,
              ),
              const SizedBox(width: AppSpace.s16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? auth.currentUser?.email ?? l10n.guestUser, style: text.titleLarge),
                  if (user != null) Text(roleName(user.role, l10n), style: text.bodyMedium?.copyWith(color: t.textSecondary)),
                  if (user?.courtName?.isNotEmpty == true) _InfoLine(Icons.account_balance_outlined, user!.courtName!),
                  if (user?.regionName?.isNotEmpty == true) _InfoLine(Icons.place_outlined, user!.regionName!),
                ]),
              ),
              Icon(Icons.edit_outlined, size: 18, color: t.textTertiary),
            ]),
          ),
          if (user != null) ...[
            const SizedBox(height: AppSpace.s20),
            _LevelCard(user: user),
            const SizedBox(height: AppSpace.s20),
            _StatsGrid(items: [
              (Icons.local_fire_department_outlined, t.streakContainer, t.streakSolid, l10n.dsStreakDays(user.currentStreak), l10n.dsStatStreak),
              (Icons.menu_book_outlined, t.brandContainer, t.brandPrimary, '${completed.length}', l10n.dsStatCoursesDone),
              (Icons.workspace_premium_outlined, t.goldContainer, t.goldSolid, '$certificates', l10n.dsStatCertificates),
              (Icons.checklist_rounded, t.successContainer, t.successSolid, '${user.quizzesPassed}', l10n.dsStatQuizzesPassed),
            ]),
            const SizedBox(height: AppSpace.s20),
            AppCard(
              onTap: () => _push(context, const LeaderboardScreen()),
              child: Row(children: [
                IconTile(Icons.emoji_events_outlined, background: t.goldContainer, foreground: t.goldSolid),
                const SizedBox(width: AppSpace.s12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.dsLeaderboard, style: text.titleSmall),
                    Text(l10n.dsLeaderboardLinkSubtitle, style: text.bodySmall?.copyWith(color: t.textSecondary)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: t.textTertiary),
              ]),
            ),
          ],
          const SizedBox(height: AppSpace.s20),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              if (user != null)
                _MenuRow(Icons.history_rounded, l10n.myQuizHistory, onTap: () => _push(context, const QuizHistoryScreen())),
              if (user != null)
                _MenuRow(Icons.manage_accounts_outlined, l10n.editProfileButtonText,
                    onTap: () => _push(context, const ProfileEditScreen())),
              _MenuRow(Icons.palette_outlined, l10n.themeOptionsTitle, onTap: () => _push(context, const ThemeOptionsScreen())),
              if (user?.isAdmin == true)
                _MenuRow(Icons.admin_panel_settings_outlined, l10n.adminPanelTitle,
                    color: t.streakSolid, onTap: () => _push(context, const AdminPanelScreen())),
              if (user != null)
                _MenuRow(Icons.logout_rounded, l10n.logoutButtonText,
                    color: t.dangerSolid, last: true, onTap: () => _confirmLogout(context, l10n)),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancelButton)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logoutButton, style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) await context.read<AuthNotifier>().signOut();
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoLine(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14, color: t.textTertiary),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary))),
      ]),
    );
  }
}

/// Joriy daraja, keyingi darajagacha progress va gatekeeper talablari.
class _LevelCard extends StatelessWidget {
  final AppUser user;

  const _LevelCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final next = nextLevelId(user.xp);
    final (start, target) = _bounds(user.xp);

    final requirements = <(String, String, bool)>[
      if (next != null) (l10n.dsReqXp(target), '${user.xp} / $target', user.xp >= target),
      if (next == GamificationRules.levelExpert) ...[
        (l10n.dsReqQuizzes(GamificationRules.reqQuizzesPassedForExpert),
            '${user.quizzesPassed} / ${GamificationRules.reqQuizzesPassedForExpert}',
            user.quizzesPassed >= GamificationRules.reqQuizzesPassedForExpert),
        (l10n.dsReqAced(GamificationRules.reqQuizzesAcedForExpert),
            '${user.totalQuizzesAced} / ${GamificationRules.reqQuizzesAcedForExpert}',
            user.totalQuizzesAced >= GamificationRules.reqQuizzesAcedForExpert),
      ],
      if (next == GamificationRules.levelMaster) ...[
        (l10n.dsReqStreak(GamificationRules.reqStreakForMaster),
            '${user.currentStreak} / ${GamificationRules.reqStreakForMaster}',
            user.currentStreak >= GamificationRules.reqStreakForMaster),
        (l10n.dsReqSims(GamificationRules.reqSimsForMaster),
            '${user.simulationsCompleted} / ${GamificationRules.reqSimsForMaster}',
            user.simulationsCompleted >= GamificationRules.reqSimsForMaster),
      ],
    ];

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconTile(Icons.workspace_premium_outlined, size: 48, background: t.brandContainer, foreground: t.brandPrimary),
          const SizedBox(width: AppSpace.s12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.dsCurrentLevel, style: text.labelSmall?.copyWith(color: t.textTertiary)),
              Text(levelName(l10n, user.level), style: text.titleLarge),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${user.xp}', style: text.titleLarge),
            Text('XP', style: text.labelMedium?.copyWith(color: t.textSecondary)),
          ]),
        ]),
        const SizedBox(height: 14),
        ProgressLine(value: AppUser.getLevelProgress(user.xp)),
        const SizedBox(height: 6),
        Row(children: [
          Text('$start', style: text.labelMedium?.copyWith(color: t.textTertiary)),
          const Spacer(),
          Text(next == null ? l10n.dsMaxLevel : '${levelName(l10n, next)} · $target XP',
              style: text.labelMedium?.copyWith(color: t.textSecondary)),
        ]),
        if (requirements.isNotEmpty) ...[
          const SizedBox(height: 14),
          Divider(color: t.borderDefault),
          const SizedBox(height: 14),
          Text(l10n.dsRequirementsFor(levelName(l10n, next!)), style: text.titleSmall),
          for (final (label, value, done) in requirements)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(children: [
                Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 20, color: done ? t.successSolid : t.textTertiary),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: text.bodyMedium)),
                Text(value, style: text.labelMedium?.copyWith(color: done ? t.successSolid : t.textSecondary)),
              ]),
            ),
        ],
      ]),
    );
  }

  static (int, int) _bounds(int xp) {
    const thresholds = [
      0,
      GamificationRules.xpThresholdIntermediate,
      GamificationRules.xpThresholdAdvanced,
      GamificationRules.xpThresholdSpecialist,
      GamificationRules.xpThresholdExpert,
      GamificationRules.xpThresholdMaster,
    ];
    for (var i = thresholds.length - 1; i >= 0; i--) {
      if (xp >= thresholds[i]) {
        return (thresholds[i], i + 1 < thresholds.length ? thresholds[i + 1] : thresholds[i]);
      }
    }
    return (0, thresholds[1]);
  }
}

class _StatsGrid extends StatelessWidget {
  final List<(IconData, Color, Color, String, String)> items;

  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    Widget tile((IconData, Color, Color, String, String) e) => Expanded(
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconTile(e.$1, size: 36, background: e.$2, foreground: e.$3),
              const SizedBox(height: 10),
              Text(e.$4, style: text.titleLarge),
              Text(e.$5, style: text.bodySmall?.copyWith(color: t.textSecondary)),
            ]),
          ),
        );
    return Column(children: [
      for (var i = 0; i < items.length; i += 2) ...[
        if (i > 0) const SizedBox(height: AppSpace.s12),
        Row(children: [
          tile(items[i]),
          const SizedBox(width: AppSpace.s12),
          if (i + 1 < items.length) tile(items[i + 1]) else const Spacer(),
        ]),
      ],
    ]);
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool last;

  const _MenuRow(this.icon, this.label, {required this.onTap, this.color, this.last = false});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: 14),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: t.borderDefault)),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: color ?? t.textSecondary),
          const SizedBox(width: AppSpace.s12),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color ?? t.textPrimary)),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: t.textTertiary),
        ]),
      ),
    );
  }
}
