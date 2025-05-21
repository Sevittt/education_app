// lib/screens/resources_screen.dart

import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/resource.dart';
import 'resource_detail_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Resource> _filteredResources = [];
  ResourceType? _selectedResourceType;

  @override
  void initState() {
    super.initState();
    _applyFiltersAndSearch();
    _searchController.addListener(_applyFiltersAndSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFiltersAndSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFiltersAndSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResources =
          dummyResources.where((resource) {
            final typeMatches =
                _selectedResourceType == null ||
                resource.type == _selectedResourceType;
            final searchMatches =
                query.isEmpty ||
                resource.title.toLowerCase().contains(query) ||
                resource.description.toLowerCase().contains(query) ||
                resource.author.toLowerCase().contains(query);
            return typeMatches && searchMatches;
          }).toList();
    });
  }

  // Updated helper function to build a more styled resource type icon presentation
  Widget _buildResourceTypeIconWidget(ResourceType type, BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    IconData iconData;
    Color iconColor = colorScheme.primary; // Default icon color

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
        color: iconColor.withOpacity(
          0.1,
        ), // Subtle background color for the icon
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

    return Column(
      children: [
        // --- Search Bar ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search resources...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  24.0,
                ), // More rounded search bar
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                0.5,
              ), // Use a theme color
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
          ),
        ),

        // --- Filter Dropdown ---
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 0.0,
          ), // Reduced vertical padding
          child: DropdownButtonFormField<ResourceType?>(
            decoration: InputDecoration(
              labelText: 'Filter by Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  12.0,
                ), // Consistent rounding
              ),
              filled: true,
              fillColor: colorScheme.surface, // Use theme surface color
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
            ),
            value: _selectedResourceType,
            hint: const Text('All Types'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<ResourceType?>(
                value: null,
                child: Text('All Types'),
              ),
              ...ResourceType.values.map((ResourceType type) {
                return DropdownMenuItem<ResourceType>(
                  value: type,
                  child: Text(
                    type
                        .toString()
                        .split('.')
                        .last
                        .replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (match) =>
                              ' ${match.group(1)}', // Add space before capitals
                        )
                        .trim(),
                  ),
                );
              }),
            ],
            onChanged: (ResourceType? newValue) {
              setState(() {
                _selectedResourceType = newValue;
                _applyFiltersAndSearch();
              });
            },
          ),
        ),
        const SizedBox(height: 16.0), // Spacing after dropdown
        // --- Resource List ---
        Expanded(
          child:
              _filteredResources.isEmpty
                  ? Center(
                    child: Column(
                      // For icon and text
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 60,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No resources found.',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty ||
                            _selectedResourceType != null)
                          Text(
                            'Try adjusting your search or filter.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ), // Padding for the list
                    itemCount: _filteredResources.length,
                    itemBuilder: (context, index) {
                      final resource = _filteredResources[index];
                      return Card(
                        // Using CardTheme from main.dart for base styling
                        // margin is already in CardTheme, but can override if needed:
                        // margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ), // From CardTheme
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
                                      const SizedBox(height: 8.0),
                                      Text(
                                        resource.description,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.75),
                                        ),
                                        maxLines:
                                            2, // Show a snippet of the description
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // const SizedBox(width: 8), // Optional: if you want space before an arrow
                                // Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
