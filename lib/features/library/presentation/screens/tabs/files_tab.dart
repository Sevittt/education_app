import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/domain/entities/resource_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import '../resource_detail_screen.dart';

class FilesTab extends StatefulWidget {
  const FilesTab({super.key});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  final TextEditingController _searchController = TextEditingController();
  ResourceType? _selectedResourceType;
  bool _showOnlyBookmarked = false;

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
      case ResourceType.eSud:
        iconData = Icons.play_circle_outline;
        iconColor = Colors.red.shade700;
        break;
      case ResourceType.adolat:
        iconData = Icons.code_outlined;
        iconColor = Colors.green.shade700;
        break;
      case ResourceType.jibSud:
        iconData = Icons.assignment_outlined;
        iconColor = Colors.purple.shade700;
        break;
      case ResourceType.edoSud:
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
        color: iconColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(iconData, size: 28, color: iconColor),
    );
  }

  String _getResourceTypeName(ResourceType type, AppLocalizations l10n) {
    switch (type) {
      case ResourceType.eSud:
        return 'E-SUD';
      case ResourceType.adolat:
        return 'Adolat AT';
      case ResourceType.jibSud:
        return 'JIB.SUD.UZ';
      case ResourceType.edoSud:
        return 'EDO.SUD.UZ';
      case ResourceType.other:
        return l10n.resourceTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    
    // Clean Architecture: Use Consumer to listen to LibraryProvider
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        // Trigger load/watch if needed. 
        if (libraryProvider.resources.isEmpty && !libraryProvider.isLoading && libraryProvider.error == null) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               libraryProvider.watchResources(); 
             });
        }
        
        return RefreshIndicator(
          onRefresh: () async {
             await libraryProvider.loadResources(); 
          },
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: textTheme.bodyMedium,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.resourcesSearchHint,
                    hintStyle: textTheme.bodySmall,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<ResourceType?>(
                  decoration: InputDecoration(
                    labelText: l10n.resourcesFilterByType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  initialValue: _selectedResourceType,
                  hint: Text(l10n.resourcesAllTypes),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<ResourceType?>(
                      value: null,
                      child: Text(l10n.resourcesAllTypes),
                    ),
                    ...ResourceType.values.map((ResourceType type) {
                      return DropdownMenuItem<ResourceType?>(
                        value: type,
                        child: Text(_getResourceTypeName(type, l10n)),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(l10n.onlySaved),
                    const Spacer(),
                    Switch(
                      value: _showOnlyBookmarked,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyBookmarked = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (libraryProvider.isLoading && libraryProvider.resources.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (libraryProvider.error != null) {
                      return Center(child: Text(l10n.errorGeneric(libraryProvider.error!)));
                    }

                    // Filter resources
                    return FutureBuilder<List<String>>(
                      future: libraryProvider.getBookmarkedResourceIds(), 
                      builder: (context, bookmarkSnapshot) {
                        final bookmarkedIds = bookmarkSnapshot.data ?? [];
                        final resources = libraryProvider.resources;

                        List<ResourceEntity> filteredResources =
                            resources.where((resource) {
                              final matchesSearch =
                                  resource.title.toLowerCase().contains(
                                    _searchController.text.toLowerCase(),
                                  ) ||
                                  resource.description.toLowerCase().contains(
                                    _searchController.text.toLowerCase(),
                                  );

                              final matchesType =
                                  _selectedResourceType == null ||
                                  resource.type == _selectedResourceType;

                              final matchesBookmark = !_showOnlyBookmarked ||
                                  bookmarkedIds.contains(resource.id);

                              return matchesSearch && matchesType && matchesBookmark;
                            }).toList();

                        if (filteredResources.isEmpty) {
                          return Center(child: Text(l10n.resourcesNoResourcesFound));
                        }

                        // Group by type
                        final Map<ResourceType, List<ResourceEntity>> groupedResources = {};
                        for (final res in filteredResources) {
                          groupedResources.putIfAbsent(res.type, () => []).add(res);
                        }

                        // Build a flat list of Widgets (Headers and ListTiles)
                        final List<Widget> listItems = [];
                        
                        final sortedTypes = groupedResources.keys.toList()
                          ..sort((a, b) => a.index.compareTo(b.index));

                        for (final type in sortedTypes) {
                          listItems.add(
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
                              child: Row(
                                children: [
                                  _buildResourceTypeIconWidget(type, context),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getResourceTypeName(type, l10n),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          
                          for (final resource in groupedResources[type]!) {
                            listItems.add(
                              Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                                elevation: 0,
                                color: colorScheme.surfaceContainerHighest.withAlpha(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: colorScheme.outlineVariant.withAlpha(100)),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResourceDetailScreen(resource: resource),
                                      ),
                                    ).then((_) => setState(() {}));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                resource.title, 
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                resource.description, 
                                                maxLines: 2, 
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        return ListView.builder(
                          itemCount: listItems.length,
                          itemBuilder: (context, index) {
                            return listItems[index];
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
