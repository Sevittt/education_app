import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/constants/gamification_rules.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';
import 'package:sud_qollanma/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
import 'package:sud_qollanma/features/library/domain/entities/resource_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/search/presentation/screens/global_search_screen.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';
import 'package:sud_qollanma/widgets/quiz_attempt_card.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/my_courses_dashboard.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/home/presentation/widgets/rank_hero_card.dart';
import 'package:sud_qollanma/features/home/presentation/widgets/dashboard_stats_row.dart';
import 'package:sud_qollanma/features/home/presentation/widgets/auto_scrolling_news_section.dart';
import 'package:sud_qollanma/features/home/presentation/widgets/admin_stat_section.dart';

typedef OnTabSelected = void Function(int index);

class HomeDashboardScreen extends StatelessWidget {
  final OnTabSelected onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final l10n = AppLocalizations.of(context);
    if (urlString.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.urlCannotBeEmpty ?? 'URL cannot be empty')),
        );
      }
      return;
    }
    Uri? uri = Uri.tryParse(urlString);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.invalidUrlFormat(urlString) ?? 'Invalid URL: $urlString'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.couldNotLaunchUrl(urlString) ?? 'Could not launch $urlString'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorLaunchingUrl(e.toString()) ?? 'Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final authNotifier = Provider.of<AuthNotifier>(context);
    final AppUser? appUser = authNotifier.appUser;
    final String userName = appUser?.name ?? l10n.guestUser;
    final newsNotifier = Provider.of<NewsNotifier>(context, listen: false);

    // Adaptive accent: amber in dark, indigo in light
    final accentColor    = isDark ? AppColors.amber : AppColors.primary;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
        backgroundColor: accentColor,
        heroTag: 'ai_chat_fab',
        child: Icon(Icons.auto_awesome,
            color: isDark ? AppColors.scaffoldDark : Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 8),
                
                if (appUser != null) ...[
                  RankHeroCard(user: appUser),
                  DashboardStatsRow(user: appUser),
                  const SizedBox(height: 24),
                ] else ...[
                  // ── HEADER — indigo gradient (light) / deep navy (dark) for guests ────
                  Container(
                    decoration: BoxDecoration(
                      gradient: isDark ? null : AppColors.primaryGradient,
                      color: isDark ? AppColors.scaffoldDark : null,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcomeBack(userName),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.readyToLearnSomethingNew,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── CONTENT AREA ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        borderRadius: 14,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                                size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.search,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tizim holati (Visible to all)
                      const AdminStatSection(),
                      const SizedBox(height: 28),

                      // So'nggi yangiliklar
                      AutoScrollingNewsSection(
                        newsNotifier: newsNotifier,
                        isDesktop: isDesktop,
                        launchUrl: _launchUrl,
                      ),
                      const SizedBox(height: 32),

                      // My Courses replace Quick Access
                      if (appUser != null) ...[
                        const MyCoursesDashboard(),
                        const SizedBox(height: 28),
                        _buildRoleSpecificDashboard(appUser, l10n, theme, context),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildRoleSpecificDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    if (appUser.role == CourtRole.ict_specialist) {
      return _buildAdminDashboard(appUser, l10n, theme, context);
    } else if (appUser.role == CourtRole.judge) {
      return _buildEkspertDashboard(appUser, l10n, theme, context);
    } else {
      return _buildXodimDashboard(appUser, l10n, theme, context);
    }
  }

  Widget _buildXodimDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.dashboardXodimTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onTabSelected(3),
              child: Text(l10n.seeAllButton),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.quizzesTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizListScreen()),
                );
              },
              child: Text(l10n.seeAllButton),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<QuizAttempt>>(
          future: quizProvider.getUserAttempts(appUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(l10n.errorLoadingQuizzes));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return GlassCard(
                borderRadius: 14,
                child: Center(child: Text(l10n.noQuizAttempts)),
              );
            }

            final attempts = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attempts.length > 3 ? 3 : attempts.length,
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
        ),
      ],
    );
  }

  Widget _buildEkspertDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.dashboardEkspertTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onTabSelected(1),
              child: Text(l10n.seeAllButton),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<ResourceEntity>>(
          stream: libraryProvider.watchResourcesByAuthor(appUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(l10n.errorLoadingResources(snapshot.error.toString())),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return GlassCard(
                borderRadius: 14,
                child: Center(child: Text(l10n.noGuidesAuthored)),
              );
            }

            final resources = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resources.length > 3 ? 3 : resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        Builder(builder: (ctx) {
                          final dark = Theme.of(ctx).brightness == Brightness.dark;
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: dark ? AppColors.amberContainer : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.description,
                                color: dark ? AppColors.amber : AppColors.primary,
                                size: 20),
                          );
                        }),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                resource.type.name[0].toUpperCase() +
                                    resource.type.name.substring(1).toLowerCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    return const SizedBox.shrink(); // Moved to main dashboard
  }
}
