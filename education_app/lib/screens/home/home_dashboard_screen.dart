// lib/screens/home/home_dashboard_screen.dart

// ... other imports ...
import 'package:education_app/data/dummy_data.dart';
// import 'package:education_app/screens/resource/resource_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization

typedef OnTabSelected = void Function(int index);

class HomeDashboardScreen extends StatelessWidget {
  final OnTabSelected onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  // Updated _launchUrl method
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final l10n = AppLocalizations.of(context); // Get l10n instance

    if (urlString.isEmpty) return;

    Uri? uri = Uri.tryParse(urlString);

    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Use the extension method for safety, or ensure l10n is not null
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
    // ... (existing build method) ...

    // Inside your ListView.builder for news items:
    // final newsItem = dummyNews[index]; //
    // onTap: () {
    //   _launchUrl(context, newsItem.url); // Pass context here
    // },
    // ...
    // Rest of the HomeDashboardScreen build method and _buildQuickAccessCard
    // Make sure to adapt the onTap for news items:
    // onTap: () {
    //  _launchUrl(context, newsItem.url);
    // },
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    // Using the dummyUser for personalization

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Personalized Welcome Section ---
            // ... (Welcome section code from your file) ...
            const SizedBox(height: 28.0),

            // --- Quick Access Section ---
            Text(
              'Quick Access',
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
                    title: 'Resources',
                    onTap: () => onTabSelected(1),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.people_outline,
                    title: 'Community',
                    onTap: () => onTabSelected(2),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => onTabSelected(3),
                  ),
                  _buildQuickAccessCard(
                    context: context,
                    icon: Icons.home_outlined,
                    title: 'Overview',
                    onTap: () => onTabSelected(0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28.0),

            // --- Latest News Section ---
            Text(
              'Latest News',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dummyNews.length, //
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                itemBuilder: (context, index) {
                  final newsItem = dummyNews[index]; //
                  return SizedBox(
                    width: 260,
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
                          _launchUrl(context, newsItem.url); // MODIFIED HERE
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 20,
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      newsItem.title,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                'Source: ${newsItem.source}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                Icon(icon, size: 36, color: colorScheme.primary),
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
