// lib/screens/profile/profile_screen.dart

import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // For date formatting

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
import 'package:sud_qollanma/shared/widgets/glass_card.dart'; // Added GlassCard
import 'package:sud_qollanma/core/constants/app_colors.dart'; // Added AppColors

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
    // final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? Colors.white : Colors.white38,
              size: 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: enabled ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: enabled ? Colors.white70 : Colors.white38,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null && enabled)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white70,
              ),
          ],
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
      future: context.read<QuizProvider>().fetchRecentUserAttempts(userId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return Center(child: Text('${l10n.errorPrefix}: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(l10n.noQuizAttempts, style: const TextStyle(color: Colors.white70)),
            ),
          );
        }

        final attempts = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: attempts.length,
          itemBuilder: (context, index) {
            final attempt = attempts[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: QuizAttemptCard(
                    attempt: attempt,
                    onTap: () {
                      // Navigate to quiz details if needed
                    },
                  ),
                ),
              ),
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
  Widget _buildStreakBadge(BuildContext context, AppUser appUser, AppLocalizations l10n) {
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
             color: Colors.black.withValues(alpha: 0.2), // Darker shadow for glass
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
    final textTheme = theme.textTheme;

    int currentXP = appUser.xp;
    
    // Determine Target Level based on current level
    String nextLevelName = '';
    int xpTarget = 0;
    int quizzesTarget = 0;
    int simsTarget = 0;
    bool isMaxLevel = false;

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
    } else if (appUser.level == GamificationRules.levelMaster) {
      isMaxLevel = true;
      xpTarget = GamificationRules.xpThresholdMaster;
    } else {
      nextLevelName = GamificationRules.levelSpecialist;
      xpTarget = GamificationRules.xpThresholdSpecialist;
    }

    double progress = 0.0;
    if (!isMaxLevel) {
        progress = (currentXP / xpTarget).clamp(0.0, 1.0);
    } else {
        progress = 1.0;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedLevelName(appUser.level, l10n),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                  ),
                  if (!isMaxLevel)
                    Text(
                      '${l10n.nextLevel}: ${_getLocalizedLevelName(nextLevelName, l10n)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    )
                  else
                    Text(
                      l10n.levelExpert, 
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
              _buildStreakBadge(context, appUser, l10n),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'XP: $currentXP / $xpTarget',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
                    backgroundColor: Colors.white24, // Semi-transparent white
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // distinct white fill
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
                          color: Colors.white,
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
           
           if (!isMaxLevel) ...[
               _buildRequirementRow(
                   context, 
                   icon: Icons.star, 
                   label: '$currentXP / $xpTarget XP', 
                   isMet: currentXP >= xpTarget
               ),
                if (quizzesTarget > 0)
                  _buildRequirementRow(
                      context, 
                      icon: Icons.quiz, 
                      label: '${l10n.quizzes}: ${appUser.quizzesPassed} / $quizzesTarget', 
                      isMet: appUser.quizzesPassed >= quizzesTarget
                  ),
                
                if (appUser.level == GamificationRules.levelSpecialist)
                  _buildRequirementRow(
                      context, 
                      icon: Icons.workspace_premium, 
                      label: 'Aced Quizzes: ${appUser.totalQuizzesAced} / ${GamificationRules.reqQuizzesAcedForExpert}', 
                      isMet: appUser.totalQuizzesAced >= GamificationRules.reqQuizzesAcedForExpert
                  ),

                if (appUser.level == GamificationRules.levelExpert)
                  _buildRequirementRow(
                      context, 
                      icon: Icons.local_fire_department, 
                      label: 'Streak: ${appUser.currentStreak} / ${GamificationRules.reqStreakForMaster} ${l10n.days}', 
                      isMet: appUser.currentStreak >= GamificationRules.reqStreakForMaster
                  ),

                if (simsTarget > 0)
                  _buildRequirementRow(
                      context, 
                      icon: Icons.science, 
                      label: '${l10n.simulations}: ${appUser.simulationsCompleted} / $simsTarget', 
                      isMet: appUser.simulationsCompleted >= simsTarget
                  ),
           ] else 
               const Text(
                 'Max Level Reached!', // Use localized if available
                 style: TextStyle(color: Colors.white),
               ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(BuildContext context, {required IconData icon, required String label, required bool isMet}) {
      final color = isMet ? Colors.lightGreenAccent : Colors.white38; // Lighter green for dark bg
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
            children: [
                Icon(isMet ? Icons.check_circle : Icons.circle_outlined, size: 16, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(
                    color: isMet ? Colors.white : Colors.white60,
                    fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
                )),
            ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final authNotifier = context.watch<AuthNotifier>();
    final firebaseUser = authNotifier.currentUser; 
    final appUser = authNotifier.appUser; 

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind app bar if any
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGlassGradient : AppColors.primaryGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 20),
              // --- Header Profile Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white24,
                        backgroundImage:
                            (appUser?.profilePictureUrl?.isNotEmpty == true
                                    ? NetworkImage(appUser!.profilePictureUrl!)
                                    : (firebaseUser?.profilePictureUrl?.isNotEmpty == true
                                        ? NetworkImage(firebaseUser!.profilePictureUrl!)
                                        : null))
                                as ImageProvider<Object>?,
                        child:
                            (appUser?.profilePictureUrl?.isEmpty ?? true) &&
                                    (firebaseUser?.profilePictureUrl?.isEmpty ?? true)
                                ? const Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        appUser?.name ??
                            firebaseUser?.name ??
                            firebaseUser?.email ??
                            l10n.guestUser,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      if (firebaseUser?.email != null &&
                          (appUser?.name != firebaseUser!.email))
                        Text(
                          firebaseUser.email ?? l10n.noEmailProvided,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      Text(
                        '${l10n.roleLabel} ${appUser != null ? _getRoleName(appUser.role, l10n) : l10n.loading}',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // --- User Stats Section ---
              if (appUser != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildUserStats(context, appUser, l10n),
                ),
              
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
                      subtitle:
                          appUser != null
                              ? l10n.updateYourInformation
                              : l10n.loginToEditProfile,
                    ),
                    _buildProfileOptionCard(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: l10n.settingsTitle,
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
                      title: l10n.themeOptionsTitle, 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ThemeOptionsScreen(),
                          ),
                        );
                      },
                    ),

                    // --- ADMIN PANEL BUTTON ---
                    if (appUser != null && appUser.role == UserRole.admin) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.white24),
                      ),
                      _buildProfileOptionCard(
                        context: context,
                        icon: Icons.admin_panel_settings_outlined,
                        title: l10n.adminPanelTitle,
                        subtitle: l10n.manageNewsSubtitle,
                        enabled: true,
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

                    // --- Quiz History Section ---
                    if (appUser != null) ...[
                       const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Colors.white24),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            l10n.myQuizHistory,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
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
                            child: Text(l10n.seeAll, style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      _buildQuizHistoryList(context, appUser.id, l10n),
                    ],

                    // --- Logout Section ---
                    if (appUser != null) ...[
                       const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Colors.white24),
                      ),
                      _buildProfileOptionCard(
                        context: context,
                        icon: Icons.logout_rounded,
                        title: l10n.logoutButtonText,
                        onTap: () async {
                          final confirmLogout = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text(l10n.logoutConfirmTitle), 
                                content: Text(l10n.logoutConfirmMessage), 
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(l10n.cancelButton), 
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      l10n.logoutButton,
                                      style: TextStyle(color: theme.colorScheme.error),
                                    ),
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
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
      ),
    );
  }
}
