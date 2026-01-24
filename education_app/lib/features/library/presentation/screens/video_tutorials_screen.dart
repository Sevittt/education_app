import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:sud_qollanma/features/library/presentation/screens/video_player_screen.dart';

/// Refactored Video Tutorials Screen using LibraryProvider.
class VideoTutorialsScreen extends StatefulWidget {
  const VideoTutorialsScreen({super.key});

  @override
  State<VideoTutorialsScreen> createState() => _VideoTutorialsScreenState();
}

class _VideoTutorialsScreenState extends State<VideoTutorialsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['all', 'beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    // Fetch videos on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().watchVideos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryDisplayName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'all':
        return l10n.allCategories;
      case 'beginner':
        return l10n.rankBeginner;
      case 'intermediate':
        return l10n.rankIntermediate;
      case 'advanced':
        return l10n.rankAdvanced;
      default:
        return category;
    }
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
          tabs: _categories.map((category) {
            return Tab(text: _getCategoryDisplayName(category, l10n));
          }).toList(),
        ),
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.videos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.videos.isEmpty) {
            return Center(child: Text(l10n.systemsDirectoryError(provider.error!)));
          }

          return TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              return _buildVideoList(provider.videos, category, l10n);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildVideoList(List<VideoEntity> allVideos, String category, AppLocalizations l10n) {
    final videos = category == 'all'
        ? allVideos
        : allVideos.where((v) => v.category == category).toList();

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
        return _buildVideoCard(videos[index], l10n);
      },
    );
  }

  Widget _buildVideoCard(VideoEntity video, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Increment views
          context.read<LibraryProvider>().incrementVideoViews(video.id);
          // Navigate to player (using legacy model for now)
          // In a full refactor, VideoPlayerScreen would also use VideoEntity
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoEntity: video,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
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
                    if (video.thumbnailUrl.isNotEmpty)
                      Container(
                        color: Colors.black.withValues(alpha: 0.2),
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
                          _getCategoryDisplayName(video.category, l10n),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd MMM').format(video.createdAt),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
