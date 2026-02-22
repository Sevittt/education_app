import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import '../../services/systems_service.dart';
import '../../services/faq_service.dart';
import '../../features/library/presentation/providers/library_provider.dart';
import '../knowledge_base/article_detail_screen.dart';
import '../resource/video_player_screen.dart';
import '../systems/system_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.notificationsTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.loginRequired)),
      );
    }

    return StreamBuilder<List<AppNotification>>(
      stream: _service.getUserNotifications(_userId!),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final hasUnread = notifications.any((n) => !n.isReadBy(_userId!));

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.notificationsTitle),
            centerTitle: true,
            actions: [
              if (hasUnread)
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: AppLocalizations.of(context)!.markAllAsReadTooltip,
                  onPressed: () async {
                    final l10n = AppLocalizations.of(context)!;
                    final messenger = ScaffoldMessenger.of(context);
                    final result = await _service.markAllAsRead(_userId!);
                    if (!mounted) return;

                    if (result['success'] == true) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.allNotificationsReadMessage),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text(l10n.errorGeneric(result['error']))),
                      );
                    }
                  },
                ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        '${AppLocalizations.of(context)!.errorPrefix}${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index]);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isRead = notification.isReadBy(_userId!);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Use theme's card theme, but override color for unread
      color: isRead
          ? theme.cardTheme.color
          : colorScheme.primaryContainer.withValues(alpha: 0.1),
      elevation: isRead ? 1 : 2, // Slight elevation difference
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(notification.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                              color: isRead
                                  ? colorScheme.onSurface
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(notification.sentAt.toDate()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(NotificationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.update:
        iconData = Icons.update;
        color = Colors.blue;
        break;
      case NotificationType.newContent:
        iconData = Icons.fiber_new;
        color = Colors.green;
        break;
      case NotificationType.announcement:
        iconData = Icons.campaign;
        color = Colors.orange;
        break;
      case NotificationType.reminder:
        iconData = Icons.notifications_active;
        color = Colors.purple;
        break;
      case NotificationType.system:
        iconData = Icons.settings;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotifications,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (!notification.isReadBy(_userId!)) {
      await _service.markAsRead(notification.id, _userId!);
    }

    if (!notification.hasRelatedContent) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      switch (notification.relatedContentType) {
        case 'article':
          await _navigateToArticle(notification.relatedContentId!);
          break;
        case 'video':
          await _navigateToVideo(notification.relatedContentId!);
          break;
        case 'system':
          await _navigateToSystem(notification.relatedContentId!);
          break;
        case 'faq':
          await _navigateToFAQ(notification.relatedContentId!);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${AppLocalizations.of(context)!.errorPrefix}$e')),
        );
      }
    } finally {
      // Hide loading
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _navigateToArticle(String id) async {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    final article = await provider.getArticleById(id);
    if (article != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(articleEntity: article)),
      );
    } else {
      throw 'Maqola topilmadi';
    }
  }

  Future<void> _navigateToVideo(String id) async {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    final video = await provider.getVideoById(id);
    if (video != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(videoEntity: video)),
      );
    } else {
      throw 'Video topilmadi';
    }
  }

  Future<void> _navigateToSystem(String id) async {
    final service = SystemsService();
    final system = await service.getSystemById(id);
    if (system != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SystemDetailScreen(system: system)),
      );
    } else {
      throw 'Tizim topilmadi';
    }
  }

  Future<void> _navigateToFAQ(String id) async {
    final service = FAQService();
    final faqs = await service.getAllFAQs().first;
    try {
      final faq = faqs.firstWhere((f) => f.id == id);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(faq.question),
            content: SingleChildScrollView(child: Text(faq.answer)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.closeAction),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      throw 'Savol topilmadi';
    }
  }
}
