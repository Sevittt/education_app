// lib/screens/resource/resource_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/features/library/domain/entities/resource_entity.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart'; // Clean Arch Entity
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart'; // Clean Arch Provider
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
// import '../../services/resource_service.dart'; // REMOVED
// import '../../services/quiz_service.dart'; // REMOVED
import 'edit_resource_screen.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_screen.dart';

// Convert to StatefulWidget
class ResourceDetailScreen extends StatefulWidget {
  final ResourceEntity resource;

  const ResourceDetailScreen({super.key, required this.resource});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  List<Quiz> _associatedQuizzes = [];
  bool _isLoadingQuizzes = true;
  // Keep _isDeleting if you implement a specific loading state for delete as previously discussed
  // bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchAssociatedQuizzes();
  }

  Future<void> _fetchAssociatedQuizzes() async {
    setState(() {
      _isLoadingQuizzes = true;
    });
    try {
      // Clean Architecture: Use QuizProvider
      _associatedQuizzes = await context.read<QuizProvider>().fetchQuizzesForResource(widget.resource.id);
    } catch (e) {
      // Handle error, maybe show a SnackBar
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingQuizzes), // Use l10n key
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQuizzes = false;
        });
      }
    }
  }

  Future<void> _launchResourceUrl(
    BuildContext context,
    String? urlString,
    AppLocalizations l10n,
  ) async {
    // ... (Keep your existing _launchResourceUrl method here)
    if (urlString == null || urlString.isEmpty) {
      return;
    }
    Uri? uri = Uri.tryParse(urlString);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invalidUrlFormat(urlString)),
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
              content: Text(l10n.couldNotLaunchUrl(urlString)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLaunchingUrl(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    // ... (Keep your existing _confirmDelete method here)
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteResourceConfirmTitle),
          content: Text(l10n.deleteResourceConfirmMessage),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancelButtonText),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n.deleteButtonText),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      // Optional: Set a deleting flag if you have one
      // setState(() => _isDeleting = true);
      try {
        await context.read<LibraryProvider>().deleteResource(
          widget.resource.id,
        ); // Use widget.resource.id
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.resourceDeletedSuccess(widget.resource.title)),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.resourceDeletedError(e.toString())),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        // if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  IconData _getIconForResourceType(ResourceType type) {
    switch (type) {
      case ResourceType.eSud:
        return Icons.computer_outlined;
      case ResourceType.adolat:
        return Icons.gavel_outlined;
      case ResourceType.jibSud:
        return Icons.folder_copy_outlined;
      case ResourceType.edoSud:
        return Icons.cloud_upload_outlined;
      case ResourceType.other:
        return Icons.help_outline;
    }
  }

  Widget _buildQuizListItem(Quiz quiz) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          Icons.quiz_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(quiz.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          quiz.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(quizId: quiz.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final UserRole? userRole = authNotifier.appUser?.role;
    // ResourceService removed. Use context.read<LibraryProvider>() where needed.

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.title), // Use widget.resource
        actions: [
          if (userRole == UserRole.ekspert || userRole == UserRole.admin) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editButtonTooltip,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => EditResourceScreen(
                          resourceToEdit:
                              widget.resource, // This is the correct parameter
                          // Remove the redundant 'resource' parameter
                        ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: l10n.deleteButtonTooltip,
              onPressed: () {
                _confirmDelete(context, l10n);
              },
            ),
          ],
          // --- BOOKMARK BUTTON ---
          FutureBuilder<bool>(
            future: context.read<LibraryProvider>().isResourceBookmarked(widget.resource.id),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
                ),
                tooltip: isBookmarked ? l10n.bookmarkRemoveTooltip : l10n.bookmarkSaveTooltip,
                onPressed: () async {
                  await context.read<LibraryProvider>().toggleResourceBookmark(widget.resource.id);
                  setState(() {}); // UI ni yangilash
                },
              );
            },
          ),
          // --- END BOOKMARK BUTTON ---
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.resource.title, // Use widget.resource
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  _getIconForResourceType(
                    widget.resource.type,
                  ), // Use widget.resource
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.resourceTypeLabel}: ${widget.resource.type.name[0].toUpperCase()}${widget.resource.type.name.substring(1)}', // Use widget.resource
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              '${l10n.authorLabel}: ${widget.resource.author}', // Use widget.resource
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              '${l10n.dateAddedLabel}: ${MaterialLocalizations.of(context).formatMediumDate(widget.resource.createdAt)}', // Use widget.resource
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (widget.resource.url != null &&
                widget.resource.url!.isNotEmpty) ...[
              // Use widget.resource
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  _launchResourceUrl(
                    context,
                    widget.resource.url,
                    l10n,
                  ); // Use widget.resource
                },
                child: Text(
                  widget.resource.url!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Text(
              l10n.descriptionLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.resource.description, // Use widget.resource
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24.0),

            // --- NEW Section for Related Quizzes ---
            Text(
              l10n.relatedQuizzesTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            if (_isLoadingQuizzes)
              const Center(child: CircularProgressIndicator())
            else if (_associatedQuizzes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  l10n.noQuizzesAvailable,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap:
                    true, // Important for ListView inside SingleChildScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
                itemCount: _associatedQuizzes.length,
                itemBuilder: (context, index) {
                  final quiz = _associatedQuizzes[index];
                  return _buildQuizListItem(quiz);
                },
              ),
            const SizedBox(height: 24.0), // Add some padding at the bottom
          ],
        ),
      ),
    );
  }
}
