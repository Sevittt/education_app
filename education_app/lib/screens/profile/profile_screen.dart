// lib/screens/profile/profile_screen.dart

import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../models/auth_notifier.dart';
import '../../models/quiz_attempt.dart';
import '../../services/quiz_service.dart';
import 'settings_screen.dart';
import 'theme_options_screen.dart';
import 'profile_edit_screen.dart'; // Add this import

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
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color:
                        enabled
                            ? colorScheme.onSurfaceVariant
                            : Colors.grey.shade500,
                  ),
                )
                : null,
        trailing:
            onTap != null && enabled
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
    // It's better to get QuizService here if it's only used by this widget
    final quizService = Provider.of<QuizService>(context, listen: false);

    return StreamBuilder<List<QuizAttempt>>(
      stream: quizService.getAttemptsForUser(userId),
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
            final formattedDate = DateFormat.yMMMd(
              l10n.localeName,
            ).add_jm().format(attempt.attemptedAt.toDate());

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: CircleAvatar(child: Text('${attempt.score}')),
                title: Text(attempt.quizTitle),
                subtitle: Text(formattedDate),
                trailing: Text('${attempt.score}/${attempt.totalQuestions}'),
              ),
            );
          },
        );
      },
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
                        appUser?.profilePictureUrl != null &&
                                appUser!.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(appUser.profilePictureUrl!)
                            : (firebaseUser?.photoURL != null &&
                                        firebaseUser!.photoURL!.isNotEmpty
                                    ? NetworkImage(firebaseUser.photoURL!)
                                    : const AssetImage(
                                      'assets/images/my_pic.jpg',
                                    ))
                                as ImageProvider<Object>?,
                    child:
                        (appUser?.profilePictureUrl == null ||
                                    appUser!.profilePictureUrl!.isEmpty) &&
                                (firebaseUser?.photoURL == null ||
                                    firebaseUser!.photoURL!.isEmpty)
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
                      firebaseUser.email!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  Text(
                    '${l10n.role}: ${appUser?.role.name ?? l10n.loading}',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
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

                  // --- NEW: Quiz History Section ---
                  if (appUser != null) ...[
                    const Divider(
                      height: 30,
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                    ),
                    Text(
                      l10n.myQuizHistory,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
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
                                  onPressed:
                                      () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                ),
                                TextButton(
                                  child: Text(
                                    l10n.logoutButton,
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  onPressed:
                                      () =>
                                          Navigator.of(dialogContext).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmLogout == true) {
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
