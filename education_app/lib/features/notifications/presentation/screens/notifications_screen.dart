import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

import '../../domain/entities/notification_entity.dart';
import '../providers/notification_notifier.dart';

import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/systems/presentation/providers/systems_notifier.dart';
import 'package:sud_qollanma/features/faq/presentation/providers/faq_notifier.dart';

import 'package:sud_qollanma/features/library/presentation/screens/article_detail_screen.dart';
import 'package:sud_qollanma/features/library/presentation/screens/video_player_screen.dart';
import 'package:sud_qollanma/features/systems/presentation/screens/system_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.notificationsTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.loginRequired)),
      );
    }

    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) {
        return StreamBuilder<List<NotificationEntity>>(
          stream: notifier.getUserNotifications(_userId!),
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
                        await notifier.markAllAsRead(_userId!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.allNotificationsReadMessage),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              body: Builder(
                builder: (context) {
                  if (snapshot.hasError) {
                    return Center(child: Text('${AppLocalizations.of(context)!.errorPrefix}${snapshot.error}'));
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
                      return _buildNotificationCard(notifications[index], notifier);
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification, NotificationNotifier notifier) {
    final isRead = notification.isReadBy(_userId!);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isRead ? null : Colors.blue.shade50,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, notifier),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(notification.sentAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
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
        color: color.withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotifications,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(NotificationEntity notification, NotificationNotifier notifier) async {
    if (!notification.isReadBy(_userId!)) {
      await notifier.markAsRead(notification.id, _userId!);
    }

    if (!notification.hasRelatedContent) return;

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
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorPrefix}$e')),
        );
      }
    } finally {
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
        MaterialPageRoute(builder: (_) => ArticleDetailScreen(articleEntity: article)),
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
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoEntity: video)),
      );
    } else {
      throw 'Video topilmadi';
    }
  }

  Future<void> _navigateToSystem(String id) async {
    final notifier = Provider.of<SystemsNotifier>(context, listen: false);
    final system = await notifier.getSystemById(id);
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
    final notifier = Provider.of<FaqNotifier>(context, listen: false);
    final faq = await notifier.getFaqById(id);
    if (faq != null && mounted) {
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
    } else {
      throw 'Savol topilmadi';
    }
  }
}
