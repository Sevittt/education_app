// lib/screens/home/home_dashboard_screen.dart
// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

// Removed: import '../../data/dummy_data.dart'; // No longer needed for dummyNews

import '../../models/auth_notifier.dart';
import '../../models/users.dart';
import '../../models/news.dart'; // Import the News model
import '../../services/news_service.dart'; // Import the NewsService

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
    final User? appUser = authNotifier.appUser;
    final String userName = appUser?.name ?? l10n.guestUser;

    final newsService = Provider.of<NewsService>(context, listen: false);

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
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                children: [
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.library_books_outlined,
                    title: l10n.resourcesTitle,
                    onTap: () => onTabSelected(1),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.people_outline,
                    title: l10n.communityTitle,
                    onTap: () => onTabSelected(2),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.person_outline,
                    title: l10n.profileTitle,
                    onTap: () => onTabSelected(3),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.quiz_outlined,
                    title: l10n.quizzesTitle,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Quizzes section selected (placeholder action)',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28.0),

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
              child: StreamBuilder<List<News>>(
                stream: newsService.getNewsStream(
                  limit: 5,
                ), // Fetch latest 5 news
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (newsItem.imageUrl != null &&
                                      newsItem.imageUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        newsItem.imageUrl!,
                                        height: 80, // Fixed height for image
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return SizedBox(
                                            height: 80,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  if (newsItem.imageUrl != null &&
                                      newsItem.imageUrl!.isNotEmpty)
                                    const SizedBox(height: 8),
                                  Expanded(
                                    // Allow title to take remaining space
                                    child: Text(
                                      newsItem.title,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                      maxLines:
                                          newsItem.imageUrl != null &&
                                                  newsItem.imageUrl!.isNotEmpty
                                              ? 2
                                              : 4, // Adjust maxLines based on image presence
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${l10n.sourceLabel}: ${newsItem.source}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (newsItem.publicationDate != null)
                                        Text(
                                          MaterialLocalizations.of(
                                            context,
                                          ).formatShortDate(
                                            newsItem.publicationDate!.toDate(),
                                          ),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return SizedBox(
      width: 110,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.only(right: 12.0, bottom: 4.0, top: 4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: colorScheme.primary),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Add new localization keys to your .arb files:
// "urlCannotBeEmpty": "URL cannot be empty",
// "errorLoadingNews": "Error loading news: {error}",
// "noNewsAvailable": "No news available at the moment."
// And ensure existing ones like "sourceLabel" are present.
