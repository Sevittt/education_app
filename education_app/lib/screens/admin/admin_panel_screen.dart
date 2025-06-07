// lib/screens/admin/admin_panel_screen.dart
import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'admin_news_management_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_resource_management_screen.dart';
import 'admin_quiz_management_screen.dart'; // <-- Import the new screen
// import '../placeholder_screen.dart'; // Keep if used for other placeholders

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  Widget _buildAdminOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    // ... (this method remains the same)
    final ThemeData theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildAdminOptionTile(
            context: context,
            icon: Icons.article_outlined,
            title: l10n.manageNewsTitle,
            subtitle: l10n.manageNewsSubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminNewsManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildAdminOptionTile(
            context: context,
            icon: Icons.library_books_outlined,
            title: l10n.manageResourcesTitle,
            subtitle: l10n.manageResourcesSubtitleNow,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminResourceManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildAdminOptionTile(
            // <-- ADD THIS NEW TILE
            context: context,
            icon: Icons.quiz_outlined,
            title: l10n.manageQuizzesTitle, // "Manage Quizzes"
            subtitle:
                l10n.manageQuizzesSubtitle, // Add to l10n: "Oversee all quizzes and their questions"
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminQuizManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildAdminOptionTile(
            context: context,
            icon: Icons.people_alt_outlined,
            title: l10n.manageUsersTitle,
            subtitle: l10n.manageUsersSubtitleNow,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUserListScreen(),
                ),
              );
            },
          ),
          // Add more admin options here as you build them
        ],
      ),
    );
  }
}

// Add/Update localization keys:
// "manageQuizzesSubtitle": "Oversee all quizzes and their questions"
// (You should already have "manageQuizzesTitle")
