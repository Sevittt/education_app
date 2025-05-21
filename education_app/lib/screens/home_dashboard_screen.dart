// lib/screens/home_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/dummy_data.dart'; // Import dummyUser and dummyNews
import '../models/news.dart'; // News model is used by dummyNews
import '../models/users.dart'; // User model is used by dummyUser

// Define a typedef for the callback function
typedef OnTabSelected = void Function(int index);

class HomeDashboardScreen extends StatelessWidget {
  final OnTabSelected onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link: $url')),
        );
      }
      print('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final User currentUser =
        dummyUser2; // Using the dummyUser for personalization

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Personalized Welcome Section ---
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      colorScheme
                          .surfaceContainerHighest, // A subtle background
                  backgroundImage:
                      currentUser.profilePictureUrl != null &&
                              currentUser.profilePictureUrl!.startsWith(
                                'assets/',
                              )
                          ? AssetImage(currentUser.profilePictureUrl!)
                          : null, // NetworkImage can be added here if URL is not an asset
                  child:
                      currentUser.profilePictureUrl == null ||
                              !currentUser.profilePictureUrl!.startsWith(
                                'assets/',
                              )
                          ? Icon(
                            Icons.person,
                            size: 28,
                            color: colorScheme.onSurfaceVariant,
                          )
                          : null,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  // Use Expanded to prevent overflow if name is long
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        currentUser.name, // Display user's name
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle long names
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              height: 130, // Slightly adjusted height
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                ), // Add some vertical padding for card shadow
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
                    icon: Icons.home_outlined, // Consistent outlined icon
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
              height: 190, // Increased height for news cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dummyNews.length,
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                ), // Add some vertical padding for card shadow
                itemBuilder: (context, index) {
                  final newsItem = dummyNews[index];
                  return SizedBox(
                    width: 260, // Slightly adjusted width
                    child: Card(
                      // Using CardTheme from main.dart for elevation, shape, margin
                      // elevation: 3.0,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(12.0),
                      // ),
                      // margin: const EdgeInsets.only(right: 16.0, bottom: 4.0, top: 4.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Match CardTheme shape
                        onTap: () {
                          _launchUrl(newsItem.url, context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                // Row for icon and title
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
                                        height:
                                            1.3, // Line height for better readability
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(), // Pushes source to the bottom
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
      width: 110, // Adjusted width
      child: Card(
        // Using CardTheme from main.dart
        // elevation: 2.0,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(12.0),
        // ),
        // margin: const EdgeInsets.only(right: 12.0, bottom: 4.0, top: 4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0), // Match CardTheme shape
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ), // Adjusted padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: colorScheme.primary,
                ), // Slightly smaller icon
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    // Using labelLarge for a slightly bolder look
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
