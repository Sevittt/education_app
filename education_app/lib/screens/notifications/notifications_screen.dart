import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import '../../services/knowledge_base_service.dart';
import '../../services/video_tutorial_service.dart';
import '../../services/systems_service.dart';
import '../../services/faq_service.dart';
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
        appBar: AppBar(title: const Text('Xabarnomalar')),
        body: const Center(child: Text('Tizimga kirish kerak')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xabarnomalar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Hammasini o\'qilgan deb belgilash',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await _service.markAllAsRead(_userId!);
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Barcha xabarnomalar o\'qilgan deb belgilandi'),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _service.getUserNotifications(_userId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

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
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isRead = notification.isReadBy(_userId!);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isRead ? null : Colors.blue.shade50,
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
                      dateFormat.format(notification.sentAt.toDate()),
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
            'Xabarnomalar yo\'q',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
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
          SnackBar(content: Text('Xatolik: $e')),
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
    final service = KnowledgeBaseService();
    final article = await service.getArticleById(id);
    if (article != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
      );
    } else {
      throw 'Maqola topilmadi';
    }
  }

  Future<void> _navigateToVideo(String id) async {
    final service = VideoTutorialService();
    final video = await service.getVideoById(id);
    if (video != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
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
    // FAQ service doesn't have getById exposed directly usually, let's check.
    // Assuming it does or we can add it.
    // Actually FAQService has getAllFAQs and getFAQsByCategory.
    // I should check if it has getFAQById.
    // If not, I'll just show a message for now or implement it.
    // Let's assume for now we can't easily get single FAQ without implementing it.
    // I'll implement getFAQById in FAQService next if needed.
    // For now, let's try to find it in all FAQs (inefficient but works for small data)
    final service = FAQService();
    // Temporary solution: fetch all and find.
    // Better: implement getFAQById in FAQService.
    final faqs = await service.getAllFAQs().first; // Get first snapshot
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
                child: const Text('Yopish'),
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
