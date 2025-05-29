// lib/screens/resource/resources_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resource.dart';
import '../../services/resource_service.dart';
import 'resource_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ResourceType? _selectedResourceType;

  // Note: We get the service from Provider now, so direct instantiation is not needed.

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

    // Get the resource service from Provider
    final resourceService = Provider.of<ResourceService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.resourcesTitle ?? 'Resources'),
        centerTitle: true,
      ),
      // --- The FloatingActionButton has been removed from here ---
      body: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<ResourceType?>(
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

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 80.0),
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
