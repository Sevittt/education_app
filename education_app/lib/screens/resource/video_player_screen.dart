import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/video_tutorial.dart';
import '../../services/video_tutorial_service.dart';
import '../../services/gamification_service.dart';
import '../../services/xapi_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';
import '../../config/gamification_rules.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoTutorial video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final VideoTutorialService _service = VideoTutorialService();
  bool _isPlayerReady = false;
  bool _hasLiked = false;
  late int _currentLikes;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.video.likes;
    _service.incrementViews(widget.video.id);

    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
    
    // Check if video finished
    if (_isPlayerReady && _controller.value.playerState == PlayerState.ended) {
      _awardPointsForWatching();
    }
  }

  bool _pointsAwarded = false;

  Future<void> _awardPointsForWatching() async {
    if (_pointsAwarded) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _pointsAwarded = true;
    
    // xAPI Tracking (Now triggers GamificationEngine automatically)
    await XApiService().trackVideoWatched(
      videoId: widget.video.youtubeId,
      title: widget.video.title,
      duration: _controller.metadata.duration, 
    );

    if (mounted) {
       final l10n = AppLocalizations.of(context)!;
       // We use the constant from Rules to show correct message
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(l10n.pointsEarned(GamificationRules.xpVideoComplete))),
       );
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    if (_hasLiked) {
      await _service.decrementLikes(widget.video.id);
      setState(() {
        _hasLiked = false;
        _currentLikes--;
      });
    } else {
      await _service.incrementLikes(widget.video.id);
      setState(() {
        _hasLiked = true;
        _currentLikes++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).primaryColor,
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.video.title),
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoInfo(),
                      const Divider(height: 32),
                      Text(
                        l10n.videoDescriptionTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.video.description,
                        style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      _buildTags(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.video.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.videoViews(widget.video.views),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy').format(widget.video.createdAt.toDate()),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  AppLocalizations.of(context)!.videoAuthorSubtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: _handleLike,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _hasLiked 
                      ? Theme.of(context).primaryColor.withAlpha(26) 
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 20,
                      color: _hasLiked ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_currentLikes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _hasLiked ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (widget.video.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.video.tags.map((tag) {
        return Chip(
          label: Text('#$tag'),
          backgroundColor: Colors.grey.shade100,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
