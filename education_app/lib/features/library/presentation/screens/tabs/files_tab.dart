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

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
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
        // Ideally this should be done in initState, but for now we check here.
        // Actually, let's assume parent/initState calls it, or we call it if empty.
        if (libraryProvider.resources.isEmpty && !libraryProvider.isLoading && libraryProvider.error == null) {
             // Avoid loop: scheduling binding or check usage
             WidgetsBinding.instance.addPostFrameCallback((_) {
               libraryProvider.watchResources(); // subscribe to stream
             });
        }
        
        return RefreshIndicator(
          onRefresh: () async {
             // Refresh logic if using Future, but watch is stream.
             // Maybe explicitly reload
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
                        child: Text(type.toString().split('.').last),
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
                      future: libraryProvider.getBookmarkedResourceIds(), // Use provider method
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

                        return ListView.builder(
                          itemCount: filteredResources.length,
                          itemBuilder: (context, index) {
                            final resource = filteredResources[index];
                            return ListTile(
                              leading: _buildResourceTypeIconWidget(
                                resource.type,
                                context,
                              ),
                              title: Text(resource.title),
                              subtitle: Text(resource.description),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ResourceDetailScreen(resource: resource),
                                  ),
                                ).then((_) => setState(() {}));
                              },
                            );
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
