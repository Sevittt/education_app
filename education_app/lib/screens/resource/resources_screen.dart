// lib/screens/resource/resources_screen.dart

//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
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
    final TextTheme _textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!; // O'ZGARISH
    final resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resourcesScreenTitle), // O'ZGARISH
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
                style: _textTheme.bodyMedium,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchResources,
                  hintStyle: _textTheme.bodySmall,
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
                  }).toList(),
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
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Resource> resources = snapshot.data ?? [];

                  // Filter by search and resource type
                  List<Resource> filteredResources =
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

                        return matchesSearch && matchesType;
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
      ),
    );
  }
}
