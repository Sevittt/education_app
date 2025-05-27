// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User

import '../../models/auth_notifier.dart'; // Import AuthNotifier
// import '../data/dummy_data.dart'; // No longer primarily using dummyUser for display
import '../placeholder_screen.dart'; // For placeholder navigation
import 'settings_screen.dart';
import 'theme_options_screen.dart';
// import 'profile_edit_screen.dart'; // Edit functionality will be adjusted

class ProfileScreen extends StatelessWidget {
  // Can be StatelessWidget
  const ProfileScreen({super.key});

  // Helper method to build consistent profile option cards
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
      // Using CardTheme from main.dart for base styling
      clipBehavior:
          Clip.antiAlias, // Ensures InkWell splash respects card's rounded corners
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Get the AuthNotifier to access the current user and logout method
    // Using watch here so the UI rebuilds if currentUser changes (e.g., after logout from another part of app)
    final authNotifier = context.watch<AuthNotifier>();
    final User? currentUser = authNotifier.currentUser; // Get the Firebase User

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Profile Header Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color:
                    colorScheme
                        .surfaceContainerHighest, // Using a more distinct M3 surface color
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 8,
                  ), // Respect status bar
                  CircleAvatar(
                    radius: 55, // Slightly larger avatar
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage:
                        currentUser?.photoURL != null &&
                                currentUser!.photoURL!.isNotEmpty
                            ? NetworkImage(
                              currentUser.photoURL!,
                            ) // Assumes photoURL is a network URL
                            : (currentUser?.email != null &&
                                        currentUser!
                                            .email!
                                            .isNotEmpty // Fallback to asset if no photoURL
                                    ? const AssetImage(
                                      'assets/images/my_pic.jpg',
                                    ) // Your default asset
                                    : null)
                                as ImageProvider<Object>?,
                    child:
                        (currentUser?.photoURL == null ||
                                    currentUser!.photoURL!.isEmpty) &&
                                (currentUser?.email == null ||
                                    currentUser!.email!.isEmpty)
                            ? Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: colorScheme.onPrimaryContainer,
                            )
                            : null,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    // Display email as name for now, or a placeholder
                    currentUser?.displayName ??
                        currentUser?.email ??
                        'Guest User',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          colorScheme
                              .onSurface, // Changed for better contrast on surfaceVariant
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),
                  if (currentUser !=
                      null) // Only show email if different from display name or if display name is null
                    if (currentUser.displayName != null &&
                        currentUser.email != null &&
                        currentUser.displayName != currentUser.email)
                      Text(
                        currentUser.email!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  // Role display will require fetching from Firestore later
                  Text(
                    'Role: Member', // Placeholder
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0), // Space after header
            // --- Profile Options List ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildProfileOptionCard(
                    context: context,
                    icon: Icons.manage_accounts_outlined, // Changed icon
                    title: 'Edit Profile Details',
                    enabled: currentUser != null, // Enable only if logged in
                    onTap: () {
                      // TODO: Navigate to a ProfileEditScreen that works with Firebase data
                      // This would involve fetching/saving profile data (name, role, etc.) from Firestore.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const PlaceholderScreen(
                                title: 'Edit Profile',
                                message:
                                    'Full profile editing (name, custom details) linked to your Firebase account will be available after Firestore integration.',
                              ),
                        ),
                      );
                    },
                    subtitle:
                        currentUser != null
                            ? 'Update your information'
                            : 'Login to edit profile',
                  ),
                  _buildProfileOptionCard(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Account Settings',
                    enabled: currentUser != null,
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
                    title: 'Theme Options',
                    // This option can be available even if not logged in
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeOptionsScreen(),
                        ),
                      );
                    },
                  ),

                  // --- Logout Button (only if user is logged in) ---
                  if (currentUser != null) ...[
                    const Divider(
                      height: 20,
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                    ),
                    _buildProfileOptionCard(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      onTap: () async {
                        final confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                'Are you sure you want to sign out?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmLogout == true) {
                          // Use context.read for one-off actions in callbacks
                          await context.read<AuthNotifier>().signOut();
                          // AuthWrapper will handle navigation to LoginScreen
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24.0), // Bottom padding
          ],
        ),
      ),
    );
  }
}
