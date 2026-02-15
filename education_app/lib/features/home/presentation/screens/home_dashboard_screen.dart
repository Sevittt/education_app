// lib/screens/home/home_dashboard_screen.dart
import 'package:sud_qollanma/features/home/presentation/screens/home_dashboard_screen.dart';
// import 'package:education_app/l10n/app_localizations.dart';
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
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';
import 'package:sud_qollanma/widgets/quiz_attempt_card.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart'; // Added GlassCard
import 'package:sud_qollanma/core/constants/app_colors.dart'; // Added AppColors

typedef OnTabSelected = void Function(int index);

class HomeDashboardScreen extends StatelessWidget {
  final OnTabSelected onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final l10n = AppLocalizations.of(context);
    if (urlString.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.urlCannotBeEmpty ?? 'URL cannot be empty'),
          ),
        );
      }
      return;
    }
    Uri? uri = Uri.tryParse(urlString);

    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.invalidUrlFormat(urlString) ??
                  'Invalid URL format: $urlString',
            ),
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
              content: Text(
                l10n?.couldNotLaunchUrl(urlString) ??
                    'Could not launch $urlString',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.errorLaunchingUrl(e.toString()) ??
                  'Error launching URL: $e',
            ),
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
        backgroundColor: AppColors.primary,
        heroTag: 'ai_chat_fab',
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGlassGradient : AppColors.primaryGradient,
        ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Personalized Welcome Section ---
              Text(
                l10n.welcomeBack(userName),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Always white on gradient
                ),
              ),
              Text(
                l10n.readyToLearnSomethingNew,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16.0),

              // --- Global Search Bar ---
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 16,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 12),
                    Text(
                      '${l10n.search}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🔍',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Quick Access Section ---
              Text(
                l10n.quickAccessTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 1.1, 
                children: [
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.account_balance_outlined,
                    title: l10n.resourcesTitle,
                    onTap: () => onTabSelected(1),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.forum_outlined,
                    title: l10n.communityTitle,
                    onTap: () => onTabSelected(2),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.quiz_outlined,
                    title: l10n.quizzesTitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.person_outline,
                    title: l10n.profileTitle,
                    onTap: () => onTabSelected(3),
                  ),
                ],
              ),
             
              const SizedBox(height: 28.0),

              // --- Role-Specific Dashboard Section ---
              if (appUser != null) ...[
                _buildRoleSpecificDashboard(appUser, l10n, theme, context),
                const SizedBox(height: 28.0),
              ],

              // --- Latest News Section ---
              Text(
                l10n.latestNewsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 220, 
                child: StreamBuilder<List<NewsEntity>>(
                  stream: newsNotifier.newsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          l10n.errorLoadingNews(snapshot.error.toString()),
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noNewsAvailable,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final newsList = snapshot.data!;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: newsList.length,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      itemBuilder: (context, index) {
                        final newsItem = newsList[index];
                        return SizedBox(
                          width: 280,
                          child: GlassCard(
                            margin: const EdgeInsets.only(right: 16.0, bottom: 4.0, top: 4.0),
                            padding: EdgeInsets.zero, // Custom padding handled inside
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.0), // Match GlassCard default
                              onTap: () {
                                _launchUrl(context, newsItem.url);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- NEWS IMAGE ---
                                  if (newsItem.imageUrl != null && newsItem.imageUrl!.isNotEmpty)
                                    SizedBox(
                                      height: 110,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: CustomNetworkImage(
                                          imageUrl: newsItem.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  // --- NEWS CONTENT ---
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            newsItem.title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${l10n.sourceLabel}: ${newsItem.source}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (newsItem.publicationDate != null)
                                                Text(
                                                  MaterialLocalizations.of(context).formatShortDate(
                                                    newsItem.publicationDate!,
                                                  ),
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildRoleSpecificDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    switch (appUser.role) {
      case UserRole.xodim:
        return _buildXodimDashboard(appUser, l10n, theme, context);
      case UserRole.ekspert:
        return _buildEkspertDashboard(appUser, l10n, theme, context);
      case UserRole.admin:
        return _buildAdminDashboard(appUser, l10n, theme, context);
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
            Text(
              l10n.dashboardXodimTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => onTabSelected(3),
              child: Text(l10n.seeAllButton, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        
        FutureBuilder<List<QuizAttempt>>(
          future: quizProvider.getUserAttempts(appUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(child: Text(l10n.errorLoadingQuizzes, style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return GlassCard(
                child: Center(
                  child: Text(
                    l10n.noQuizAttempts,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              );
            }

            final attempts = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attempts.length > 3 ? 3 : attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                // Note: QuizAttemptCard might need refactoring too, or wrap it in GlassCard
                // For now, let's wrap it in GlassCard to containerize it.
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                         child: QuizAttemptCard(
                          attempt: attempt,
                          onTap: () {},
                      ),
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
            Text(
              l10n.dashboardEkspertTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => onTabSelected(1),
              child: Text(l10n.seeAllButton, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        StreamBuilder<List<ResourceEntity>>(
          stream: libraryProvider.watchResourcesByAuthor(appUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n.errorLoadingResources(snapshot.error.toString()),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return GlassCard(
                child: Center(
                  child: Text(
                    l10n.noGuidesAuthored,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
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
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                resource.type.name.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
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
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardAdminTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
              child: Text(l10n.adminPanelTitle, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 1.0,
          children: [
            _buildStatCard(
              context: context,
              title: l10n.adminStatUsers,
              icon: Icons.people_alt_outlined,
              stream: authRepository.getAllUsersStream().map((list) => list.length),
            ),
            _buildStatCard(
              context: context,
              title: l10n.adminStatGuides,
              icon: Icons.description_outlined,
              stream: libraryProvider.resourcesStream.map((list) => list.length),
            ),
            _buildStatCard(
              context: context,
              title: l10n.adminStatQuizzes,
              icon: Icons.quiz_outlined,
              stream: quizProvider.quizzesStream.map((list) => list.length),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Stream<int> stream,
  }) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                );
              }
              if (snapshot.hasError) {
                return const Icon(Icons.error_outline, color: AppColors.error);
              }
              final count = snapshot.data ?? 0;
              return Text(
                count.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Centered align looks better in grid
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white, // White icons on glass gradient
          ),
          const SizedBox(height: 12), // Added spacing
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
