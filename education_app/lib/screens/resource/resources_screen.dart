// lib/screens/resource/resources_screen.dart

import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'resource_detail_screen.dart';
import '../../models/resource.dart';
import '../../services/resource_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ResourceType? _selectedResourceType;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // The onRefresh callback for RefreshIndicator
  Future<void> _handleRefresh() async {
    // For Firestore streams, the stream is already live.
    // This callback mainly provides visual feedback.
    // You could add a slight delay to make the indicator visible for a moment.
    await Future.delayed(const Duration(milliseconds: 500)); // Optional delay

    // If you had a way to force re-fetch or clear a cache in your service, you'd call it here.
    // For now, just ensuring the UI can rebuild if needed.
    if (mounted) {
      setState(() {
        // This setState call might not be strictly necessary if the StreamBuilder
        // is the only thing updating from data changes, but it doesn't hurt
        // if you want to ensure any other part of the screen dependent on state refreshes.
      });
    }
  }

  Widget _buildResourceTypeIconWidget(ResourceType type, BuildContext context) {
    // ... (your existing _buildResourceTypeIconWidget code)
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    IconData iconData;
    Color iconColor = colorScheme.primary;

    switch (type) {
      case ResourceType.article:
        iconData = Icons.article_outlined;
        iconColor = Colors.orange.shade700;
        break;
      case ResourceType.video:
        iconData = Icons.play_circle_outline;
        iconColor = Colors.red.shade700;
        break;
      case ResourceType.code:
        iconData = Icons.code_outlined;
        iconColor = Colors.green.shade700;
        break;
      case ResourceType.lessonPlan:
        iconData = Icons.assignment_outlined;
        iconColor = Colors.purple.shade700;
        break;
      case ResourceType.tutorial:
        iconData = Icons.school_outlined;
        iconColor = Colors.blue.shade700;
        break;
      case ResourceType.other:
        iconData = Icons.help_outline;
        iconColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(iconData, size: 28, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.resourcesTitle ?? 'Resources'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        // Wrap the Column with RefreshIndicator
        onRefresh: _handleRefresh, // Assign the callback
        color: Theme.of(context).colorScheme.primary, // Indicator color
        backgroundColor:
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest, // Background of indicator
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                // ... (your existing TextField code for search)
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n?.resourcesSearchHint ?? 'Search resources...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                    0.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<ResourceType?>(
                // ... (your existing DropdownButtonFormField code for filter)
                decoration: InputDecoration(
                  labelText: l10n?.resourcesFilterByType ?? 'Filter by Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                value: _selectedResourceType,
                hint: Text(l10n?.resourcesAllTypes ?? 'All Types'),
                isExpanded: true,
                items: [
                  DropdownMenuItem<ResourceType?>(
                    value: null,
                    child: Text(l10n?.resourcesAllTypes ?? 'All Types'),
                  ),
                  ...ResourceType.values.map((ResourceType type) {
                    return DropdownMenuItem<ResourceType>(
                      value: type,
                      child: Text(
                        type.name[0].toUpperCase() + type.name.substring(1),
                      ),
                    );
                  }),
                ],
                onChanged: (ResourceType? newValue) {
                  setState(() {
                    _selectedResourceType = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Resource>>(
                stream: resourceService.getResources(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData &&
                      !snapshot.hasError) {
                    // Show loading indicator only on initial load or if explicitly refreshing without data
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print(
                      "ResourcesScreen StreamBuilder caught an error: ${snapshot.error}",
                    );
                    print("Type of error: ${snapshot.error.runtimeType}");
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n?.errorLoadingData ??
                              'An error occurred. Please try again later.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }
                  // If snapshot has data, even during ConnectionState.waiting (which happens during stream updates),
                  // we can still show the data. Or if connection is done and there's no data.
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If there's no data even after loading (and no error), show no resources found.
                    // This covers the case where the stream is active but returns an empty list.
                    return Center(
                      child: Text(
                        l10n?.resourcesNoResourcesFound ??
                            'No resources found.',
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }

                  final query = _searchController.text.toLowerCase();
                  List<Resource> resourcesToShow = snapshot.data!;

                  if (_selectedResourceType != null) {
                    resourcesToShow =
                        resourcesToShow
                            .where(
                              (resource) =>
                                  resource.type == _selectedResourceType,
                            )
                            .toList();
                  }
                  if (query.isNotEmpty) {
                    resourcesToShow =
                        resourcesToShow.where((resource) {
                          return resource.title.toLowerCase().contains(query) ||
                              resource.description.toLowerCase().contains(
                                query,
                              ) ||
                              resource.author.toLowerCase().contains(query);
                        }).toList();
                  }

                  if (resourcesToShow.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 60,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.resourcesNoResourcesMatch ??
                                'No resources match your criteria.',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // The ListView needs to be the scrollable child that RefreshIndicator can detect.
                  // If the Column itself isn't scrollable when the list is short,
                  // the RefreshIndicator might not trigger easily unless the ListView is long enough
                  // or the Column is wrapped in a SingleChildScrollView (but StreamBuilder gives a list).
                  // In this case, ListView.builder is directly scrollable.
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 80.0),
                    itemCount: resourcesToShow.length,
                    itemBuilder: (context, index) {
                      final resource = resourcesToShow[index];
                      return Card(
                        // ... (your existing Card and InkWell code for displaying a resource item) ...
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ResourceDetailScreen(
                                      resource: resource,
                                    ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildResourceTypeIconWidget(
                                  resource.type,
                                  context,
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resource.title,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'By: ${resource.author}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
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
          ],
        ),
      ),
    );
  }
}
