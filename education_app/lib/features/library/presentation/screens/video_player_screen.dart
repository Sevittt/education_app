import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../config/gamification_rules.dart';
import '../../domain/entities/video_entity.dart';
import '../providers/library_provider.dart';

// Analytics UseCases
import '../../../analytics/domain/usecases/analytics_usecases.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoEntity videoEntity;

  const VideoPlayerScreen({
    super.key,
    required this.videoEntity,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasLiked = false;
  late int _currentLikes;

  // Helper getters to abstract video data source
  String get _videoId => widget.videoEntity.id;
  String get _videoTitle => widget.videoEntity.title;
  String get _videoDescription => widget.videoEntity.description;
  String get _youtubeId => widget.videoEntity.youtubeId;
  String get _thumbnailUrl => widget.videoEntity.thumbnailUrl;
  String get _authorName => widget.videoEntity.authorName;
  int get _views => widget.videoEntity.views;
  int get _initialLikes => widget.videoEntity.likes;
  DateTime get _createdAt => widget.videoEntity.createdAt;
  List<String> get _tags => widget.videoEntity.tags;

  @override
  void initState() {
    super.initState();
    _currentLikes = _initialLikes;
    
    // Increment views via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LibraryProvider>().incrementVideoViews(_videoId);
    });

    _controller = YoutubePlayerController(
      initialVideoId: _youtubeId,
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
    
    // Clean Architecture: Use TrackVideoWatched UseCase
    // This UseCase handles logging to xAPI and triggering Gamification logic internally via LogXApiStatement
    await context.read<TrackVideoWatched>().call(
      videoId: _youtubeId,
      title: _videoTitle,
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

  Future<void> _launchYoutubeVideo(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _handleLike() async {
    if (_hasLiked) {
      await context.read<LibraryProvider>().decrementVideoLikes(_videoId);
      setState(() {
        _hasLiked = false;
        _currentLikes--;
      });
    } else {
      await context.read<LibraryProvider>().incrementVideoLikes(_videoId);
      setState(() {
        _hasLiked = true;
        _currentLikes++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      // Fallback for Web: Show thumbnail and button to open in new tab
      return Scaffold(
        appBar: AppBar(title: Text(_videoTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display Thumbnail
              if (_thumbnailUrl.isNotEmpty)
                Container(
                  width: 320,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(_thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                l10n.openInYoutube,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                   _launchYoutubeVideo(_youtubeId);
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.watchOnYoutube),
              ),
            ],
          ),
        ),
      );
    }
    
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
            title: Text(_videoTitle),
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
                        _videoDescription,
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
          _videoTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.videoViews(_views),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy').format(_createdAt),
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
                  _authorName,
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
    if (_tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags.map((tag) {
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
