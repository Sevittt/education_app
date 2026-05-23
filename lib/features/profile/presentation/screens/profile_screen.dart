import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/core/constants/gamification_rules.dart';
import 'package:sud_qollanma/features/settings/presentation/screens/settings_screen.dart';
import 'package:sud_qollanma/features/settings/presentation/screens/theme_options_screen.dart';
import 'profile_edit_screen.dart';

import 'package:sud_qollanma/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:sud_qollanma/features/gamification/presentation/screens/leaderboard_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_history_screen.dart';
import 'package:sud_qollanma/widgets/quiz_attempt_card.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/shared/widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
    Color? iconColor,
  }) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultAccent = isDark ? AppColors.amber : AppColors.primary;
    final effectiveIconColor = iconColor ?? defaultAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 14,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: enabled
                    ? effectiveIconColor.withValues(alpha: isDark ? 0.15 : 0.12)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: enabled ? effectiveIconColor : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null && enabled)
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHistoryList(BuildContext context, String userId, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return FutureBuilder<List<QuizAttempt>>(
      future: context.read<QuizProvider>().fetchRecentUserAttempts(userId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('${l10n.errorPrefix}: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.noQuizAttempts,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }

        final attempts = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attempts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 14,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: QuizAttemptCard(attempt: attempts[index], onTap: () {}),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _getRoleName(CourtRole role, AppLocalizations l10n) {
    switch (role) {
      case CourtRole.judge:
        return l10n.registrationRoleJudge;
      case CourtRole.assistant:
        return l10n.registrationRoleAssistant;
      case CourtRole.chancellery:
        return l10n.registrationRoleChancellery;
      case CourtRole.archive:
        return l10n.registrationRoleArchive;
      case CourtRole.ict_specialist:
        return l10n.registrationRoleIctSpecialist;
      case CourtRole.admin:
        return 'Administrator';
      case CourtRole.unknown:
        return 'Noma\'lum';
    }
  }

  String _getLocalizedLevelName(String level, AppLocalizations l10n) {
    switch (level) {
      case 'levelBeginner':
        return l10n.levelBeginner;
      case 'levelIntermediate':
        return l10n.levelIntermediate;
      case 'levelAdvanced':
        return l10n.levelAdvanced;
      case 'levelSpecialist':
        return l10n.levelSpecialist;
      case 'levelExpert':
        return l10n.levelExpert;
      case 'levelMaster':
        return l10n.levelMaster;
      default:
        return level;
    }
  }

  Widget _buildStreakBadge(BuildContext context, AppUser appUser, AppLocalizations l10n) {
    if (appUser.currentStreak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.streakAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakAccent.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '${appUser.currentStreak} ${l10n.days}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, AppUser appUser, AppLocalizations l10n) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent    = isDark ? AppColors.amber : AppColors.primary;
    final accentBg  = isDark ? AppColors.amberContainer : AppColors.primaryContainer;

    int currentXP = appUser.xp;
    String nextLevelName = '';
    int xpStart = 0;
    int xpTarget = 0;
    int quizzesTarget = 0;
    int simsTarget = 0;
    bool isMaxLevel = false;

    if (appUser.level == GamificationRules.levelBeginner) {
      nextLevelName = GamificationRules.levelIntermediate;
      xpStart = 0;
      xpTarget = GamificationRules.xpThresholdIntermediate;
    } else if (appUser.level == GamificationRules.levelIntermediate) {
      nextLevelName = GamificationRules.levelAdvanced;
      xpStart = GamificationRules.xpThresholdIntermediate;
      xpTarget = GamificationRules.xpThresholdAdvanced;
    } else if (appUser.level == GamificationRules.levelAdvanced) {
      nextLevelName = GamificationRules.levelSpecialist;
      xpStart = GamificationRules.xpThresholdAdvanced;
      xpTarget = GamificationRules.xpThresholdSpecialist;
    } else if (appUser.level == GamificationRules.levelSpecialist) {
      nextLevelName = GamificationRules.levelExpert;
      xpStart = GamificationRules.xpThresholdSpecialist;
      xpTarget = GamificationRules.xpThresholdExpert;
      quizzesTarget = GamificationRules.reqQuizzesPassedForExpert;
    } else if (appUser.level == GamificationRules.levelExpert) {
      nextLevelName = GamificationRules.levelMaster;
      xpStart = GamificationRules.xpThresholdExpert;
      xpTarget = GamificationRules.xpThresholdMaster;
      simsTarget = GamificationRules.reqSimsForMaster;
    } else if (appUser.level == GamificationRules.levelMaster) {
      isMaxLevel = true;
      xpStart = GamificationRules.xpThresholdMaster;
      xpTarget = GamificationRules.xpThresholdMaster;
    } else {
      nextLevelName = GamificationRules.levelIntermediate;
      xpStart = 0;
      xpTarget = GamificationRules.xpThresholdIntermediate;
    }

    double progress = isMaxLevel
        ? 1.0
        : ((currentXP - xpStart) / (xpTarget - xpStart)).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedLevelName(appUser.level, l10n),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  if (!isMaxLevel)
                    Text(
                      '${l10n.nextLevel}: ${_getLocalizedLevelName(nextLevelName, l10n)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              _buildStreakBadge(context, appUser, l10n),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isMaxLevel
                ? 'XP: $currentXP / $xpTarget'
                : '${currentXP - xpStart} / ${xpTarget - xpStart} XP (${l10n.nextLevel})',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: accentBg,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          if (!isMaxLevel) ...[
            _buildRequirementRow(
              context: context,
              icon: Icons.star_outline,
              label: '$currentXP / $xpTarget XP',
              isMet: currentXP >= xpTarget,
            ),
            if (quizzesTarget > 0)
              _buildRequirementRow(
                context: context,
                icon: Icons.quiz_outlined,
                label: '${l10n.quizzes}: ${appUser.quizzesPassed} / $quizzesTarget',
                isMet: appUser.quizzesPassed >= quizzesTarget,
              ),
            if (appUser.level == GamificationRules.levelSpecialist)
              _buildRequirementRow(
                context: context,
                icon: Icons.workspace_premium_outlined,
                label: 'Aced Quizzes: ${appUser.totalQuizzesAced} / ${GamificationRules.reqQuizzesAcedForExpert}',
                isMet: appUser.totalQuizzesAced >= GamificationRules.reqQuizzesAcedForExpert,
              ),
            if (appUser.level == GamificationRules.levelExpert)
              _buildRequirementRow(
                context: context,
                icon: Icons.local_fire_department_outlined,
                label: 'Streak: ${appUser.currentStreak} / ${GamificationRules.reqStreakForMaster} ${l10n.days}',
                isMet: appUser.currentStreak >= GamificationRules.reqStreakForMaster,
              ),
            if (simsTarget > 0)
              _buildRequirementRow(
                context: context,
                icon: Icons.science_outlined,
                label: '${l10n.simulations}: ${appUser.simulationsCompleted} / $simsTarget',
                isMet: appUser.simulationsCompleted >= simsTarget,
              ),
          ] else
            Text(
              'Max Level Reached!',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isMet,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isMet
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n    = AppLocalizations.of(context)!;
    final isDark  = theme.brightness == Brightness.dark;

    final authNotifier = context.watch<AuthNotifier>();
    final firebaseUser = authNotifier.currentUser;
    final appUser      = authNotifier.appUser;

    // Header styling
    final headerBg = isDark ? AppColors.scaffoldDark : null;
    final headerDecoration = isDark
        ? BoxDecoration(color: headerBg)
        : const BoxDecoration(gradient: AppColors.primaryGradient);

    final headerTextColor   = isDark ? AppColors.textPrimary : Colors.white;
    final headerSubColor    = isDark
        ? AppColors.textSecondary
        : Colors.white.withValues(alpha: 0.8);
    final rolePillBg        = isDark
        ? AppColors.amberContainer
        : Colors.white.withValues(alpha: 0.2);
    final rolePillText      = isDark ? AppColors.amber : Colors.white;
    final avatarRingColor   = isDark
        ? AppColors.amber.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.2);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER ──────────────────────────────────────────────────
            Container(
              decoration: headerDecoration,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 24,
                20,
                36,
              ),
              child: Column(
                children: [
                  UserAvatar(
                    profilePictureUrl:
                        appUser?.profilePictureUrl ?? firebaseUser?.profilePictureUrl,
                    radius: 48,
                    backgroundColor: avatarRingColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    appUser?.name ??
                        firebaseUser?.name ??
                        firebaseUser?.email ??
                        l10n.guestUser,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: headerTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (firebaseUser?.email != null &&
                      (appUser?.name != firebaseUser!.email))
                    Text(
                      firebaseUser.email ?? l10n.noEmailProvided,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: headerSubColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: rolePillBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${l10n.roleLabel} ${appUser != null ? _getRoleName(appUser.role, l10n) : l10n.loading}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: rolePillText,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENT ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP Stats card
                  if (appUser != null) ...[
                    _buildUserStats(context, appUser, l10n),
                    const SizedBox(height: 20),
                  ],

                  // Menu options
                  _buildMenuOption(
                    context: context,
                    icon: Icons.leaderboard_outlined,
                    title: l10n.leaderboardTitle,
                    enabled: appUser != null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      );
                    },
                  ),
                  _buildMenuOption(
                    context: context,
                    icon: Icons.manage_accounts_outlined,
                    title: l10n.editProfileButtonText,
                    subtitle: appUser != null
                        ? l10n.updateYourInformation
                        : l10n.loginToEditProfile,
                    enabled: appUser != null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                      );
                    },
                  ),
                  _buildMenuOption(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: l10n.settingsTitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _buildMenuOption(
                    context: context,
                    icon: Icons.color_lens_outlined,
                    title: l10n.themeOptionsTitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ThemeOptionsScreen()),
                      );
                    },
                  ),

                  // Admin panel (role-gated) — only for CourtRole.admin
                  if (appUser != null && appUser.isAdmin) ...[
                    const SizedBox(height: 4),
                    Divider(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                    const SizedBox(height: 4),
                    _buildMenuOption(
                      context: context,
                      icon: Icons.admin_panel_settings_outlined,
                      title: l10n.adminPanelTitle,
                      subtitle: l10n.manageNewsSubtitle,
                      iconColor: AppColors.warning,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                        );
                      },
                    ),
                  ],

                  // Quiz history
                  if (appUser != null) ...[
                    const SizedBox(height: 4),
                    Divider(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.myQuizHistory,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const QuizHistoryScreen()),
                            );
                          },
                          child: Text(l10n.seeAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildQuizHistoryList(context, appUser.id, l10n),
                  ],

                  // Logout
                  if (appUser != null) ...[
                    const SizedBox(height: 4),
                    Divider(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                    const SizedBox(height: 4),
                    _buildMenuOption(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: l10n.logoutButtonText,
                      iconColor: AppColors.error,
                      onTap: () async {
                        final confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text(l10n.logoutConfirmTitle),
                            content: Text(l10n.logoutConfirmMessage),
                            actions: [
                              TextButton(
                                child: Text(l10n.cancelButton),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                              ),
                              TextButton(
                                child: Text(
                                  l10n.logoutButton,
                                  style: TextStyle(
                                      color: theme.colorScheme.error),
                                ),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                              ),
                            ],
                          ),
                        );
                        if (confirmLogout == true) {
                          if (!context.mounted) return;
                          await context.read<AuthNotifier>().signOut();
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
