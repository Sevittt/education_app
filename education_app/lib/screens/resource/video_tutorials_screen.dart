import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/video_tutorial.dart';
import '../../services/video_tutorial_service.dart';
import '../../widgets/custom_network_image.dart';
import 'video_player_screen.dart';

class VideoTutorialsScreen extends StatefulWidget {
  const VideoTutorialsScreen({super.key});

  @override
  State<VideoTutorialsScreen> createState() => _VideoTutorialsScreenState();
}

class _VideoTutorialsScreenState extends State<VideoTutorialsScreen>
    with SingleTickerProviderStateMixin {
  final VideoTutorialService _service = VideoTutorialService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: VideoCategory.values.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageVideosTitle),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.allCategories),
            ...VideoCategory.values.map((category) {
              return Tab(text: category.getDisplayName(l10n));
            }),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideoList(null), // All videos
          ...VideoCategory.values.map((category) {
            return _buildVideoList(category);
          }),
        ],
      ),
    );
  }

  Widget _buildVideoList(VideoCategory? category) {
    Stream<List<VideoTutorial>> stream;
    if (category != null) {
      stream = _service.getVideosByCategory(category.name);
    } else {
      stream = _service.getAllVideos();
    }

    return StreamBuilder<List<VideoTutorial>>(
      stream: stream,
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        if (snapshot.hasError) {
          return Center(child: Text(l10n.systemsDirectoryError(snapshot.error.toString())));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final videos = snapshot.data ?? [];

        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.noVideosFound,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return _buildVideoCard(videos[index]);
          },
        );
      },
    );
  }

  Widget _buildVideoCard(VideoTutorial video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(video: video),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder (in a real app, use Image.network with video.thumbnailUrl)
            // Thumbnail using CustomNetworkImage for caching
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: Colors.black87,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: Container(
                        color: Colors.black87,
                        child: const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                      ),
                    ),
                    // Play Icon Overlay (always visible slightly for affordance)
                    if (video.thumbnailUrl.isNotEmpty)
                      Container(
                        color: Colors.black.withValues(alpha: 0.2), // Slight darken
                        child: const Center(
                          child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white70),
                        ),
                      ),
                    
                    // Duration Badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          video.category.getDisplayName(AppLocalizations.of(context)!),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM').format(video.createdAt.toDate()),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        video.authorName,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${video.views}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
