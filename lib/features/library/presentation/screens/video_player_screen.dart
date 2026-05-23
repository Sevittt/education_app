import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  bool _isPlayerReady = false;
  bool _hasLiked = false;
  bool _isNativeVideo = false;
  late int _currentLikes;

  // Helper getters to abstract video data source
  String get _videoId => widget.videoEntity.id;
  String get _videoTitle => widget.videoEntity.title;
  String get _videoDescription => widget.videoEntity.description;
  String? get _youtubeId => widget.videoEntity.youtubeId;
  String? get _videoUrl => widget.videoEntity.videoUrl;
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

    if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      _isNativeVideo = true;
      _initNativePlayer();
    } else if (_youtubeId != null && _youtubeId!.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      )..addListener(_youtubeListener);
    }
  }

  Future<void> _initNativePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl!));
    await _videoPlayerController!.initialize();
    
    if (!mounted) return;
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );
    
    _videoPlayerController!.addListener(_nativeVideoListener);
    
    setState(() {
      _isPlayerReady = true;
    });
  }

  void _youtubeListener() {
    if (_isPlayerReady && mounted && !_youtubeController!.value.isFullScreen) {
      setState(() {});
    }
    
    // Check if video finished
    if (_isPlayerReady && _youtubeController!.value.playerState == PlayerState.ended) {
      _awardPointsForWatching(_youtubeController!.metadata.duration.inSeconds);
    }
  }

  void _nativeVideoListener() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      if (_videoPlayerController!.value.position == _videoPlayerController!.value.duration) {
         _awardPointsForWatching(_videoPlayerController!.value.duration.inSeconds);
      }
    }
  }

  bool _pointsAwarded = false;

  Future<void> _awardPointsForWatching(int durationSeconds) async {
    if (_pointsAwarded) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _pointsAwarded = true;
    
    // Clean Architecture: Use TrackVideoWatched UseCase
    // This UseCase handles logging to xAPI and triggering Gamification logic internally via LogXApiStatement
    await context.read<TrackVideoWatched>().call(
      videoId: _isNativeVideo ? _videoUrl! : _youtubeId!,
      title: _videoTitle,
      duration: Duration(seconds: durationSeconds), 
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
    _youtubeController?.pause();
    _videoPlayerController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _launchVideoUrl() async {
    final urlString = _isNativeVideo ? _videoUrl! : 'https://www.youtube.com/watch?v=$_youtubeId';
    final url = Uri.parse(urlString);
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
    if (kIsWeb && !_isNativeVideo) {
      // Fallback for Web YouTube videos: Show thumbnail and button to open in new tab
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
                   _launchVideoUrl();
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.watchOnYoutube),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isNativeVideo && _youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).primaryColor,
          onReady: () {
            _isPlayerReady = true;
          },
        ),
        builder: (context, player) {
          return _buildMainScaffold(player);
        },
      );
    }
    
    Widget playerComponent;
    if (_isNativeVideo && _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      playerComponent = AspectRatio(
        aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      playerComponent = const AspectRatio(
        aspectRatio: 16/9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildMainScaffold(playerComponent);
  }

  Widget _buildMainScaffold(Widget player) {
    final l10n = AppLocalizations.of(context)!;
    final timeCodes = widget.videoEntity.timeCodes;
    return Scaffold(
      appBar: AppBar(
        title: Text(_videoTitle),
      ),
      body: Column(
        children: [
          player,
          // ─── Chapter markers (time codes) ─────────────────────────────
          if (timeCodes.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: timeCodes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final tc = timeCodes[i];
                  return InkWell(
                    onTap: () => _seekToSeconds(tc.seconds),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tc.formatted,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tc.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
                  _buildDescriptionWithTimecodes(_videoDescription),
                  const SizedBox(height: 24),
                  _buildTags(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _seekToSeconds(int seconds) {
    final duration = Duration(seconds: seconds);
    if (_isNativeVideo && _chewieController != null) {
      _chewieController!.seekTo(duration);
    } else if (!_isNativeVideo && _youtubeController != null) {
      _youtubeController!.seekTo(duration);
    }
  }

  Widget _buildDescriptionWithTimecodes(String text) {
    final RegExp timecodeRegExp = RegExp(r'\b(?:[0-9]{1,2}:)?[0-5][0-9]:[0-5][0-9]\b');
    final matches = timecodeRegExp.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: TextStyle(color: Colors.grey.shade700, height: 1.5));
    }

    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      final timeString = match.group(0)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: InkWell(
            onTap: () => _seekToTimecode(timeString),
            child: Text(
              timeString,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        children: spans,
      ),
    );
  }

  void _seekToTimecode(String timeString) {
    final parts = timeString.split(':').reversed.toList();
    int seconds = 0;
    if (parts.isNotEmpty) seconds += int.parse(parts[0]);
    if (parts.length > 1) seconds += int.parse(parts[1]) * 60;
    if (parts.length > 2) seconds += int.parse(parts[2]) * 3600;

    final duration = Duration(seconds: seconds);

    if (_isNativeVideo && _chewieController != null) {
      _chewieController!.seekTo(duration);
    } else if (!_isNativeVideo && _youtubeController != null) {
      _youtubeController!.seekTo(duration);
    }
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
