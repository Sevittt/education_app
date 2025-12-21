import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/video_tutorial.dart';
import '../../services/video_tutorial_service.dart';
import 'admin_add_edit_video_screen.dart';

class AdminVideoManagementScreen extends StatefulWidget {
  const AdminVideoManagementScreen({super.key});

  @override
  State<AdminVideoManagementScreen> createState() => _AdminVideoManagementScreenState();
}

class _AdminVideoManagementScreenState extends State<AdminVideoManagementScreen> {
  final VideoTutorialService _service = VideoTutorialService();

  Future<void> _deleteVideo(VideoTutorial video) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteVideoMessage(video.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _service.deleteVideo(video.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.videoDeletedSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageVideosTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<VideoTutorial>>(
        stream: _service.getAllVideos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.errorPrefix}${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return Center(child: Text(l10n.noVideosFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Image.network(
                    video.thumbnailUrl,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.video_library, size: 40),
                  ),
                  title: Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(video.category.getDisplayName(l10n)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAddEditVideoScreen(video: video),
                            ),
                          );
                        },
                        tooltip: l10n.editResourceTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteVideo(video),
                        tooltip: l10n.deleteResourceTooltip,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddEditVideoScreen(),
            ),
          );
        },
        tooltip: l10n.add,
      ),
    );
  }
}
