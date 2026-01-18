// lib/screens/home/home_dashboard_screen.dart
import 'package:sud_qollanma/features/home/presentation/screens/home_dashboard_screen.dart';
// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/core/constants/gamification_rules.dart'; 
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart'; // Added
import 'package:sud_qollanma/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
// import '../../models/users.dart'; // REMOVED
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';
// import '../../models/news.dart';
// import '../../services/news_service.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
// import '../../models/resource.dart'; // REMOVED
import 'package:sud_qollanma/features/library/domain/entities/resource_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/search/presentation/screens/global_search_screen.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';
import 'package:sud_qollanma/widgets/quiz_attempt_card.dart'; // --- ADDED ---
// --- END ADDED ---

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
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final authNotifier = Provider.of<AuthNotifier>(context);
    final AppUser? appUser = authNotifier.appUser;
    final String userName = appUser?.name ?? l10n.guestUser;

    // final newsService = Provider.of<NewsService>(context, listen: false);
    final newsNotifier = Provider.of<NewsNotifier>(context, listen: false);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Personalized Welcome Section ---
            Text(
              l10n.welcomeBack(userName),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.readyToLearnSomethingNew,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28.0),

            // --- Quick Access Section ---
            Text(
              l10n.quickAccessTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12.0),
            // --- NEW: Replaced ListView with a GridView ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 1.1, // Makes cards slightly taller
              children: [
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.account_balance_outlined, // More formal icon
                  title: l10n.resourcesTitle,
                  onTap: () => onTabSelected(1),
                ),
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.forum_outlined, // More formal icon
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
            // --- END NEW GRIDVIEW ---
            const SizedBox(height: 28.0),

            // --- NEW: Role-Specific Dashboard Section ---
            if (appUser != null) ...[
              // --- MODIFIED: Pass context ---
              _buildRoleSpecificDashboard(appUser, l10n, theme, context),
              const SizedBox(height: 28.0),
            ],
            // --- END NEW SECTION ---

            // --- Latest News Section (Using StreamBuilder) ---
            Text(
              l10n.latestNewsTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 210, // Increased height to better fit content
              child: StreamBuilder<List<NewsEntity>>(
                stream: newsNotifier.newsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        l10n.errorLoadingNews(snapshot.error.toString()),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(l10n.noNewsAvailable));
                  }

                  final newsList = snapshot.data!;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: newsList.length,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    itemBuilder: (context, index) {
                      final newsItem = newsList[index];
                      return SizedBox(
                        width: 280, // Adjusted width for better display
                        child: Card(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior:
                              Clip.antiAlias, // Ensures InkWell respects border
                          margin: const EdgeInsets.only(
                            right: 16.0,
                            bottom: 4.0,
                            top: 4.0,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              _launchUrl(context, newsItem.url);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- NEWS IMAGE ---
                                if (newsItem.imageUrl != null &&
                                    newsItem.imageUrl!.isNotEmpty)
                                  SizedBox(
                                    height: 100, // Fixed height for image
                                    width: double.infinity,
                                    child: CustomNetworkImage(
                                      imageUrl: newsItem.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                // --- NEWS CONTENT ---
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          newsItem.title,
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                height: 1.3,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${l10n.sourceLabel}: ${newsItem.source}',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (newsItem.publicationDate !=
                                                null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: Text(
                                                  MaterialLocalizations.of(
                                                    context,
                                                  ).formatShortDate(
                                                    newsItem.publicationDate!,
                                                  ),
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant,
                                                      ),
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
    );
  }

  // --- NEW: Helper widget to determine which role dashboard to show ---
  Widget _buildRoleSpecificDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context, // --- ADDED context ---
  ) {
    switch (appUser.role) {
      case UserRole.xodim:
        // --- MODIFIED: Pass context to the widget ---
        return _buildXodimDashboard(appUser, l10n, theme, context);
      case UserRole.ekspert:
        // --- MODIFIED: Pass context to the widget ---
        return _buildEkspertDashboard(appUser, l10n, theme, context);
      case UserRole.admin:
        // --- MODIFIED: Pass context to the widget ---
        return _buildAdminDashboard(appUser, l10n, theme, context);
    }
  }

  // --- MODIFIED: Xodim (Staff) Dashboard with real data ---
  Widget _buildXodimDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context, 
  ) {
    // Clean Architecture: Use QuizProvider instead of QuizService
    // We access the provider to call the usecase
    final quizProvider = Provider.of<QuizProvider>(context, listen: false); 
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardXodimTitle, // "My Activity"
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => onTabSelected(3), // Navigate to profile
              child: Text(l10n.seeAllButton), // "See All"
            ),
          ],
        ),
        const SizedBox(height: 4.0), // Reduced spacing
        // --- REPLACED StreamBuilder with FutureBuilder ---
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
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      l10n.noQuizAttempts, // "You haven't attempted any quizzes yet."
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            // --- Display the list of recent attempts ---
            final attempts = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // --- ADDED: Show max 3 attempts on dashboard ---
              itemCount: attempts.length > 3 ? 3 : attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return QuizAttemptCard(
                  attempt: attempt,
                  onTap: () {
                    // Navigate to quiz details or results if needed
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- MODIFIED: Ekspert (Expert) Dashboard with real data ---
  Widget _buildEkspertDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context, // --- ADDED context ---
  ) {
    // --- ADDED Service instances ---
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardEkspertTitle, // "My Contributions"
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => onTabSelected(1), // Navigate to Guides
              child: Text(l10n.seeAllButton), // "See All"
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        // --- REPLACED Card with a StreamBuilder ---
        StreamBuilder<List<ResourceEntity>>(
          stream: libraryProvider.watchResourcesByAuthor(appUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n.errorLoadingResources(snapshot.error.toString()),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      l10n.noGuidesAuthored, // "You have not authored any guides yet."
                      style: textTheme.bodyMedium,
                    ),
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
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: Icon(Icons.description, color: colorScheme.primary),
                    title: Text(
                      resource.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      resource.type.name.toUpperCase(),
                      style: textTheme.bodySmall,
                    ),
                    onTap: () {
                      // TODO: Navigate to resource detail
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- MODIFIED: Admin Dashboard with real data ---
  Widget _buildAdminDashboard(
    AppUser appUser,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context, 
  ) {
    // --- ADDED Service instances ---
    // Use AuthRepository for user stats
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardAdminTitle, // "System Overview"
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate directly to the Admin Panel
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
              child: Text(l10n.adminPanelTitle), // "Admin Panel"
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        // --- REPLACED Card with a Grid of StreamBuilders ---
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 1.0, // Make them square
          children: [
            // Total Users
            _buildStatCard(
              context: context,
              title: l10n.adminStatUsers, // "Users"
              icon: Icons.people_alt_outlined,
              stream: authRepository.getAllUsersStream().map(
                (list) => list.length,
              ), // Map list to its length
            ),
            // Total Guides
            _buildStatCard(
              context: context,
              title: l10n.adminStatGuides, // "Guides"
              icon: Icons.description_outlined,
              stream: libraryProvider.resourcesStream.map(
                (list) => list.length,
              ), // Map list to its length
            ),
            // Total Quizzes
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
  // --- END MODIFIED WIDGET ---

  // --- NEW: Helper for stat cards ---
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Stream<int> stream,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
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
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasError) {
                  return Icon(Icons.error_outline, color: colorScheme.error);
                }
                final count = snapshot.data ?? 0;
                return Text(
                  count.toString(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  // --- END NEW WIDGET ---

  // --- UPDATED Quick Access Card Widget ---
  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // More rounded
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 40,
                color: theme.brightness == Brightness.dark 
                    ? colorScheme.secondary  // Light blue/cyan in dark mode
                    : colorScheme.primary,   // Primary blue in light mode
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.left,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
