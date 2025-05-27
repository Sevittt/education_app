// lib/screens/resources_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resource.dart';
import '../../services/resource_service.dart';
import 'resource_detail_screen.dart';
import 'create_resource_screen.dart'; // For navigation
import '../../models/auth_notifier.dart'; // To get the user role
import '../../models/users.dart'; // To use UserRole enum
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ResourceType? _selectedResourceType; // For the DropdownButtonFormField

  // Instantiate your service (it's stateless, so direct instantiation is fine here)
  final ResourceService _resourceService = ResourceService();

  // Note: _applyFiltersAndSearch and _filteredResources will be handled by StreamBuilder
  // based on snapshots from Firestore and the local filter/search states.

  @override
  void initState() {
    super.initState();
    // Listener for search text changes to re-trigger the StreamBuilder's filtering logic
    _searchController.addListener(() {
      setState(
        () {},
      ); // This will cause build to run again, re-evaluating filters
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Updated helper function to build a more styled resource type icon presentation
  Widget _buildResourceTypeIconWidget(ResourceType type, BuildContext context) {
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

    // Get the AuthNotifier to access the user's role
    final authNotifier = Provider.of<AuthNotifier>(context);
    // Get the actual role from the logged-in user's appUser profile
    final UserRole? userRole = authNotifier.appUser?.role;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.resourcesTitle ?? 'Resources'),
        centerTitle: true, // As per your other screens
      ),
      floatingActionButton:
          (userRole == UserRole.teacher || userRole == UserRole.admin)
              ? FloatingActionButton.extended(
                onPressed: () async {
                  // Navigate to CreateResourceScreen and wait for a result
                  final newResource = await Navigator.of(
                    context,
                  ).push<Resource?>(
                    MaterialPageRoute(
                      builder: (context) => const CreateResourceScreen(),
                    ),
                  );
                  // If a new resource was created and returned, add it
                  if (newResource != null) {
                    try {
                      await _resourceService.addResource(newResource);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.resourceAddedSuccess ??
                                  'Resource added successfully!',
                            ),
                          ),
                        );
                      }
                      // No setState needed here, StreamBuilder will update the list
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.resourceAddedError != null
                                  ? '${l10n!.resourceAddedError}: ${e.toString()}'
                                  : 'Error adding resource: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n?.resourcesCreateButton ?? 'Create'),
              )
              : null, // No FAB for students or other roles
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n?.resourcesSearchHint ?? 'Search resources...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),

          // --- Filter Dropdown ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0.0,
            ),
            child: DropdownButtonFormField<ResourceType?>(
              decoration: InputDecoration(
                labelText: l10n?.resourcesFilterByType ?? 'Filter by Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
              ),
              value: _selectedResourceType,
              hint: Text(l10n?.resourcesAllTypes ?? 'All Types'),
              isExpanded: true,
              items: [
                DropdownMenuItem<ResourceType?>(
                  value: null, // Represents "All Types"
                  child: Text(l10n?.resourcesAllTypes ?? 'All Types'),
                ),
                ...ResourceType.values.map((ResourceType type) {
                  return DropdownMenuItem<ResourceType>(
                    value: type,
                    child: Text(
                      // Simple capitalization for enum names
                      type.name[0].toUpperCase() + type.name.substring(1),
                    ),
                  );
                }),
              ],
              onChanged: (ResourceType? newValue) {
                setState(() {
                  _selectedResourceType = newValue;
                  // The StreamBuilder's filtering logic will use this value
                });
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // --- Resource List ---
          Expanded(
            child: StreamBuilder<List<Resource>>(
              stream: _resourceService.getResources(), // Fetch live data
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      l10n?.errorPrefix ?? 'Error: ${snapshot.error}',
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      l10n?.resourcesNoResourcesFound ?? 'No resources found.',
                    ),
                  );
                }

                // Apply search and filter to the data from Firestore
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
                        if (_searchController.text.isNotEmpty ||
                            _selectedResourceType != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              l10n?.resourcesTryAdjusting ??
                                  'Try adjusting your search or filter.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    12.0,
                    8.0,
                    12.0,
                    80.0,
                  ), // Space for FAB
                  itemCount: resourcesToShow.length,
                  itemBuilder: (context, index) {
                    final resource = resourcesToShow[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ResourceDetailScreen(resource: resource),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(height: 8.0),
                                    Text(
                                      resource.description,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.75),
                                      ),
                                      maxLines: 2,
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
    );
  }
}
