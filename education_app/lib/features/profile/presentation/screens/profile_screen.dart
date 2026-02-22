// lib/screens/profile/profile_screen.dart

import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart'; // Clean Arch Entity
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart'; // Clean Arch Provider
import 'package:sud_qollanma/models/users.dart';
import 'package:sud_qollanma/core/constants/gamification_rules.dart';
// import '../../services/quiz_service.dart'; // REMOVED
import 'package:sud_qollanma/features/settings/presentation/screens/settings_screen.dart';
import 'package:sud_qollanma/features/settings/presentation/screens/theme_options_screen.dart';
import 'profile_edit_screen.dart';

// --- ADDED ---
import 'package:sud_qollanma/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:sud_qollanma/features/gamification/presentation/screens/leaderboard_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_history_screen.dart'; // --- ADDED ---
import 'package:sud_qollanma/widgets/quiz_attempt_card.dart';
// Add Gamification Rules
// --- END ADDED ---

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? colorScheme.primary : Colors.grey.shade400,
          size: 26,
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: enabled ? colorScheme.onSurface : Colors.grey.shade600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : Colors.grey.shade500,
                ),
              )
            : null,
        trailing: onTap != null && enabled
            ? Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        onTap: enabled ? onTap : null,
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
      ),
    );
  }

  // New widget to build the quiz history list
  Widget _buildQuizHistoryList(
    BuildContext context,
    String userId,
    AppLocalizations l10n,
  ) {
    // Clean Architecture: Using QuizProvider and FutureBuilder
    return FutureBuilder<List<QuizAttempt>>(
      future: context
          .read<QuizProvider>()
          .fetchRecentUserAttempts(userId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${l10n.errorPrefix}: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(l10n.noQuizAttempts),
            ),
          );
        }

        final attempts = snapshot.data!;

        return ListView.builder(
          shrinkWrap:
              true, // Important for ListView inside SingleChildScrollView
          physics:
              const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
          itemCount: attempts.length,
          itemBuilder: (context, index) {
            final attempt = attempts[index];

            return QuizAttemptCard(
              quizTitle: attempt.quizTitle,
              score: attempt.score,
              totalQuestions: attempt.totalQuestions,
              attemptedAt: attempt.attemptedAt,
              onTap: () {
                // Navigate to quiz details if needed
              },
            );
          },
        );
      },
    );
  }

  // O'ZGARISH: Rolni lokalizatsiya qilingan matnga o'girish uchun yordamchi funksiya
  String? _getRoleName(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.xodim:
        return l10n.roleXodim;
      case UserRole.ekspert:
        return l10n.roleEkspert;
      case UserRole.admin:
        return l10n.roleAdmin;
    }
  }

  // --- ADDED: Helper to get localized level name ---
  String _getLocalizedLevelName(String level, AppLocalizations l10n) {
    switch (level) {
      case 'Boshlang\'ich':
        return l10n.levelBeginner;
      case 'O\'rta':
        return l10n.levelIntermediate;
      case 'Yuqori':
        return l10n.levelAdvanced;
      case 'Ekspert':
        return l10n.levelExpert;
      default:
        return level;
    }
  }

  // --- NEW: Build Streak Badge ---
  Widget _buildStreakBadge(
      BuildContext context, AppUser appUser, AppLocalizations l10n) {
    if (appUser.currentStreak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            '${appUser.currentStreak} ${l10n.days}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- ADDED: Build User Stats Widget ---
  Widget _buildUserStats(
    BuildContext context,
    AppUser appUser,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    int currentXP = appUser.xp;

    // Determine Target Level based on current level
    // Logic: Look at current level, decide what's next and what's needed.
    String nextLevelName = '';
    int xpTarget = 0;
    int quizzesTarget = 0;
    int simsTarget = 0;
    bool isMaxLevel = false;

    // We use the raw strings from Rules or the User's current level
    if (appUser.level == GamificationRules.levelNewbie) {
      nextLevelName = GamificationRules.levelSpecialist;
      xpTarget = GamificationRules.xpThresholdSpecialist;
    } else if (appUser.level == GamificationRules.levelSpecialist) {
      nextLevelName = GamificationRules.levelExpert;
      xpTarget = GamificationRules.xpThresholdExpert;
      quizzesTarget = GamificationRules.reqQuizzesForExpert;
    } else if (appUser.level == GamificationRules.levelExpert) {
      nextLevelName = GamificationRules.levelMaster;
      xpTarget = GamificationRules.xpThresholdMaster;
      simsTarget = GamificationRules.reqSimsForMaster;
      // Streak requirement for Master
      // User requested "Master: 2000 XP + must have currentStreak >= 7"
    } else if (appUser.level == GamificationRules.levelMaster) {
      isMaxLevel = true;
      xpTarget = GamificationRules.xpThresholdMaster; // Just filter
    } else {
      // Fallback
      nextLevelName = GamificationRules.levelSpecialist;
      xpTarget = GamificationRules.xpThresholdSpecialist;
    }

    // Calculate Progress for XP
    double progress = 0.0;

    // If calculating progress from 0 to Target
    // Simple logic: XP / Target.
    // If we want relative progress (e.g. from 200 to 800), we need previous threshold.
    // For now simple 0-based progress is easier to understand for users "You have 500/800".
    if (!isMaxLevel) {
      progress = (currentXP / xpTarget).clamp(0.0, 1.0);
    } else {
      progress = 1.0;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedLevelName(appUser.level, l10n),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isMaxLevel)
                        Text(
                          '${l10n.nextLevel}: ${_getLocalizedLevelName(nextLevelName, l10n)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          l10n.levelExpert, // This is just a placeholder logic from old file
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // --- NEW: Streak Badge ---
                _buildStreakBadge(context, appUser, l10n),
              ],
            ),
            const SizedBox(height: 16),

            // --- UPDATED: XP Progress with Animation ---
            Text(
              'XP: $currentXP / $xpTarget',
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 12,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(value * 100).toInt()}%',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            // Requirements Checklist
            if (!isMaxLevel) ...[
              // XP Requirement
              _buildRequirementRow(context,
                  icon: Icons.star,
                  label: '$currentXP / $xpTarget XP',
                  isMet: currentXP >= xpTarget),
              // Quiz Requirement (if exists)
              if (quizzesTarget > 0)
                _buildRequirementRow(context,
                    icon: Icons.quiz,
                    label:
                        '${l10n.quizzes}: ${appUser.quizzesPassed} / $quizzesTarget',
                    isMet: appUser.quizzesPassed >= quizzesTarget),

              // Aced Quizzes Requirement (Expert level)
              if (appUser.level == GamificationRules.levelSpecialist)
                _buildRequirementRow(context,
                    icon: Icons.workspace_premium,
                    label:
                        'Aced Quizzes: ${appUser.totalQuizzesAced} / ${GamificationRules.reqQuizzesAcedForExpert}',
                    isMet: appUser.totalQuizzesAced >=
                        GamificationRules.reqQuizzesAcedForExpert),

              // Streak Requirement (Master level)
              if (appUser.level == GamificationRules.levelExpert)
                _buildRequirementRow(context,
                    icon: Icons.local_fire_department,
                    label:
                        'Streak: ${appUser.currentStreak} / ${GamificationRules.reqStreakForMaster} ${l10n.days}',
                    isMet: appUser.currentStreak >=
                        GamificationRules.reqStreakForMaster),

              // Sims Requirement (if exists)
              if (simsTarget > 0)
                _buildRequirementRow(context,
                    icon: Icons.science,
                    label:
                        '${l10n.simulations}: ${appUser.simulationsCompleted} / $simsTarget',
                    isMet: appUser.simulationsCompleted >= simsTarget),
            ] else
              Text(
                l10n.levelExpert, // Max Message
                style: TextStyle(color: colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(BuildContext context,
      {required IconData icon, required String label, required bool isMet}) {
    final color = isMet ? Colors.green : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(isMet ? Icons.check_circle : Icons.circle_outlined,
              size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: isMet ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
                  decoration:
                      isMet ? TextDecoration.none : TextDecoration.none)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final authNotifier = context.watch<AuthNotifier>();
    final firebaseUser = authNotifier.currentUser; // Firebase Auth User
    final appUser =
        authNotifier.appUser; // Your custom User model from Firestore

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 8),
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage:
                        (appUser?.profilePictureUrl?.isNotEmpty == true
                            ? NetworkImage(appUser!.profilePictureUrl!)
                            : (firebaseUser?.photoURL?.isNotEmpty == true
                                ? NetworkImage(firebaseUser!.photoURL!)
                                : null)) as ImageProvider<Object>?,
                    child: (appUser?.profilePictureUrl?.isEmpty ?? true) &&
                            (firebaseUser?.photoURL?.isEmpty ?? true)
                        ? Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    appUser?.name ??
                        firebaseUser?.displayName ??
                        firebaseUser?.email ??
                        l10n.guestUser,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),
                  if (firebaseUser?.email != null &&
                      (appUser?.name != firebaseUser!.email))
                    Text(
                      firebaseUser.email ?? l10n.noEmailProvided,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  Text(
                    // O'ZGARISH: Rol nomini yordamchi funksiya orqali olish
                    '${l10n.roleLabel} ${appUser != null ? _getRoleName(appUser.role, l10n) : l10n.loading}',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // --- ADDED: User Stats Section ---
            if (appUser != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildUserStats(context, appUser, l10n),
              ),
            // --- END ADDED ---
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // --- Leaderboard Option ---
                  _buildProfileOptionCard(
                    context: context,
                    icon: Icons.leaderboard_outlined,
                    title: l10n.leaderboardTitle,
                    enabled: appUser != null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    context: context,
                    icon: Icons.manage_accounts_outlined,
                    title: l10n.editProfileButtonText,
                    enabled: appUser != null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );
                    },
                    subtitle: appUser != null
                        ? l10n.updateYourInformation
                        : l10n.loginToEditProfile,
                  ),
                  _buildProfileOptionCard(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: l10n.settingsTitle, // Assuming you have this key
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    context: context,
                    icon: Icons.color_lens_outlined,
                    title: l10n.themeOptionsTitle, // Assuming you have this key
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeOptionsScreen(),
                        ),
                      );
                    },
                  ),

                  // --- ADDED ADMIN PANEL BUTTON LOGIC ---
                  if (appUser != null && appUser.role == UserRole.admin) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildProfileOptionCard(
                      context: context,
                      icon: Icons.admin_panel_settings_outlined,
                      title: l10n.adminPanelTitle,
                      subtitle:
                          l10n.manageNewsSubtitle, // Re-using a good subtitle
                      enabled: true, // Removed redundant appUser != null check
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPanelScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                  // --- END ADDED ---

                  // --- NEW: Quiz History Section ---
                  if (appUser != null) ...[
                    const Divider(
                      height: 30,
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.myQuizHistory,
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizHistoryScreen(),
                              ),
                            );
                          },
                          child: Text(l10n.seeAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    _buildQuizHistoryList(context, appUser.id, l10n),
                  ],

                  // --- End of Quiz History Section ---
                  if (appUser != null) ...[
                    const Divider(
                      height: 30,
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                    ),
                    _buildProfileOptionCard(
                      context: context,
                      icon: Icons.logout_rounded,
                      title:
                          l10n.logoutButtonText, // Assuming you have this key
                      onTap: () async {
                        final confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text(l10n.logoutConfirmTitle), // Assuming
                              content: Text(
                                l10n.logoutConfirmMessage,
                              ), // Assuming
                              actions: <Widget>[
                                TextButton(
                                  child: Text(l10n.cancelButton), // Assuming
                                  onPressed: () => Navigator.of(
                                    dialogContext,
                                  ).pop(false),
                                ),
                                TextButton(
                                  child: Text(
                                    l10n.logoutButton,
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmLogout == true) {
                          if (!context.mounted) return;
                          await context.read<AuthNotifier>().signOut();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
