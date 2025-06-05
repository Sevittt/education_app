// lib/screens/resource/resource_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/resource.dart';
import '../../models/auth_notifier.dart';
import '../../models/users.dart';
import '../../models/quiz.dart'; // Import the Quiz model
import '../../services/resource_service.dart';
import '../../services/quiz_service.dart'; // Import the QuizService
import 'edit_resource_screen.dart';
import 'quiz/quiz_screen.dart'; // Import the QuizScreen

// Convert to StatefulWidget
class ResourceDetailScreen extends StatefulWidget {
  final Resource resource;

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
      final quizService = Provider.of<QuizService>(context, listen: false);
      // Using widget.resource.id to get the ID of the current resource
      _associatedQuizzes = await quizService.getQuizzesForResource(
        widget.resource.id,
      );
    } catch (e) {
      // Handle error, maybe show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.errorLoadingQuizzes ??
                  'Error loading quizzes: $e',
            ),
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
    AppLocalizations? l10n,
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

  Future<void> _confirmDelete(
    BuildContext context,
    ResourceService resourceService,
    AppLocalizations? l10n,
  ) async {
    // ... (Keep your existing _confirmDelete method here)
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n?.deleteResourceConfirmTitle ?? 'Confirm Deletion'),
          content: Text(
            l10n?.deleteResourceConfirmMessage ??
                'Are you sure you want to delete this resource? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n?.cancelButtonText ?? 'Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l10n?.deleteButtonText ?? 'Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Optional: Set a deleting flag if you have one
      // setState(() => _isDeleting = true);
      try {
        await resourceService.deleteResource(
          widget.resource.id,
        ); // Use widget.resource.id
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (l10n?.resourceDeletedSuccess ??
                        'Resource deleted successfully!')
                    .toString(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.resourceDeletedError(e.toString()) ??
                    'Error deleting resource: ${e.toString()}',
              ),
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
    // ... (Keep your existing _getIconForResourceType method here)
    switch (type) {
      case ResourceType.article:
        return Icons.article_outlined;
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.code:
        return Icons.code;
      case ResourceType.lessonPlan:
        return Icons.assignment_outlined;
      case ResourceType.tutorial:
        return Icons.school_outlined;
      case ResourceType.other:
        return Icons.topic_outlined;
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
    final l10n = AppLocalizations.of(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final UserRole? userRole = authNotifier.appUser?.role;
    final ResourceService resourceService = Provider.of<ResourceService>(
      context,
      listen: false,
    ); // Get from Provider

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.title), // Use widget.resource
        actions: [
          if (userRole == UserRole.teacher || userRole == UserRole.admin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n?.editButtonTooltip ?? 'Edit Resource',
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
              tooltip: l10n?.deleteButtonTooltip ?? 'Delete Resource',
              onPressed: () {
                _confirmDelete(context, resourceService, l10n);
              },
            ),
          ],
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
                  '${l10n?.resourceTypeLabel ?? 'Type'}: ${widget.resource.type.name[0].toUpperCase()}${widget.resource.type.name.substring(1)}', // Use widget.resource
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              '${l10n?.authorLabel ?? 'Author'}: ${widget.resource.author}', // Use widget.resource
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              '${l10n?.dateAddedLabel ?? 'Added'}: ${MaterialLocalizations.of(context).formatMediumDate(widget.resource.createdAt)}', // Use widget.resource
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
                  widget.resource.url!, // Use widget.resource
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
              l10n?.descriptionLabel ?? 'Description',
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
              l10n?.relatedQuizzesTitle ?? 'Related Quizzes',
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
                  l10n?.noQuizzesAvailable ??
                      'No quizzes available for this resource yet.',
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

// Ensure your AppLocalizations extensions are updated if new l10n keys are used.
// Example for new keys (add to your existing extension or create one if needed):
extension AppLocalizationsQuizMessages on AppLocalizations? {
  String get errorLoadingQuizzes =>
      this?.errorLoadingQuizzes ?? 'Error loading quizzes';
  String get relatedQuizzesTitle =>
      this?.relatedQuizzesTitle ?? 'Related Quizzes';
  String get noQuizzesAvailable =>
      this?.noQuizzesAvailable ?? 'No quizzes available for this resource yet.';
  // Add other new keys like invalidUrlFormat, couldNotLaunchUrl, errorLaunchingUrl if not already defined
  // from previous steps for the _launchResourceUrl method.
}
