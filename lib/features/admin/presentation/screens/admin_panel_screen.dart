import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'admin_news_management_screen.dart';
import 'admin_resource_management_screen.dart';
import 'admin_quiz_management_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_article_management_screen.dart';
import 'admin_video_management_screen.dart';
import 'admin_system_management_screen.dart';
import 'package:sud_qollanma/features/faq/presentation/screens/admin_faq_management_screen.dart';
import 'package:sud_qollanma/features/notifications/presentation/screens/admin_notification_management_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_course_management_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _AdminItem(
        icon: Icons.insights_rounded,
        title: l10n.analyticsTitle,
        subtitle: l10n.analyticsSubtitle,
        destination: const AdminAnalyticsScreen(),
      ),
      _AdminItem(
        icon: Icons.school_rounded,
        title: 'Kurslar boshqaruvi',
        subtitle: 'Kurs yaratish, tahrirlash va nashr qilish',
        destination: const AdminCourseManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.newspaper_rounded,
        title: l10n.manageNewsTitle,
        subtitle: l10n.manageNewsSubtitle,
        destination: const AdminNewsManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.library_books_rounded,
        title: l10n.manageArticlesTitle,
        subtitle: l10n.manageArticlesSubtitle,
        destination: const AdminArticleManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.video_library_rounded,
        title: l10n.manageVideosTitle,
        subtitle: l10n.manageVideosSubtitle,
        destination: const AdminVideoManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.computer_rounded,
        title: l10n.manageSystemsTitle,
        subtitle: l10n.manageSystemsSubtitle,
        destination: const AdminSystemManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.question_answer_rounded,
        title: l10n.manageFaqTitle,
        subtitle: l10n.manageFaqSubtitle,
        destination: const AdminFAQManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.notifications_rounded,
        title: l10n.manageNotificationsTitle,
        subtitle: l10n.manageNotificationsSubtitle,
        destination: const AdminNotificationManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.quiz_rounded,
        title: l10n.manageQuizzesTitle,
        subtitle: l10n.manageQuizzesSubtitle,
        destination: const AdminQuizManagementScreen(),
      ),
      _AdminItem(
        icon: Icons.people_rounded,
        title: l10n.manageUsersTitle,
        subtitle: l10n.manageUsersSubtitleNow,
        destination: const AdminAppUserListScreen(),
      ),
      _AdminItem(
        icon: Icons.folder_shared_rounded,
        title: l10n.manageResourcesTitle,
        subtitle: l10n.manageResourcesSubtitle,
        destination: const AdminResourceManagementScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _AdminCard(item: items[index], isDark: isDark),
      ),
    );
  }
}

class _AdminItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _AdminItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}

class _AdminCard extends StatelessWidget {
  final _AdminItem item;
  final bool isDark;

  const _AdminCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor    = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor  = isDark ? AppColors.borderDark : AppColors.borderLight;
    final iconBg       = isDark ? AppColors.amberContainer : AppColors.primaryContainer;
    final iconColor    = isDark ? AppColors.amber : AppColors.primary;
    final titleColor   = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subtitleColor= isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final splash       = isDark
        ? AppColors.amber.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.destination),
          ),
          borderRadius: BorderRadius.circular(16),
          splashColor: splash,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 24, color: iconColor),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
