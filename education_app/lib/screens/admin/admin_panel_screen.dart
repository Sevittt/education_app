import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'admin_news_management_screen.dart';
import 'admin_resource_management_screen.dart';
import 'admin_quiz_management_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_article_management_screen.dart';
import 'admin_video_management_screen.dart';
import 'admin_system_management_screen.dart';
import 'admin_faq_management_screen.dart';
import 'admin_notification_management_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPanelTitle),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildAdminCard(
            context,
            icon: Icons.newspaper,
            title: l10n.manageNewsTitle,
            subtitle: l10n.manageNewsSubtitle,
            color: Colors.blue.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminNewsManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.library_books,
            title: 'Maqolalar',
            subtitle: 'Bilimlar bazasini boshqarish',
            color: Colors.green.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminArticleManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.video_library,
            title: 'Videolar',
            subtitle: 'Video darsliklarni boshqarish',
            color: Colors.red.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminVideoManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.computer,
            title: 'Tizimlar',
            subtitle: 'Sud tizimlarini boshqarish',
            color: Colors.indigo.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSystemManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.question_answer,
            title: 'Savol-Javob',
            subtitle: 'FAQ larni boshqarish',
            color: Colors.amber.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminFAQManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.notifications,
            title: 'Xabarnomalar',
            subtitle: 'Xabarnoma yuborish',
            color: Colors.teal.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminNotificationManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.quiz,
            title: l10n.manageQuizzesTitle,
            subtitle: l10n.manageQuizzesSubtitle,
            color: Colors.orange.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminQuizManagementScreen(),
                ),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.people,
            title: l10n.manageUsersTitle,
            subtitle: l10n.manageUsersSubtitleNow,
            color: Colors.purple.shade100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAppUserListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}