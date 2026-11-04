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
import '../../domain/entities/video_watch_progress.dart';
import '../../data/datasources/video_progress_remote_source.dart';
import '../providers/library_provider.dart';
import '../widgets/web_youtube_player.dart';

// Analytics UseCases
import '../../../analytics/domain/usecases/analytics_usecases.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoEntity videoEntity;

  /// Video oxirigacha ko'rilganda bir marta chaqiriladi (kurs darsini yakunlash uchun).
  final VoidCallback? onWatched;

  const VideoPlayerScreen({
    super.key,
    required this.videoEntity,
    this.onWatched,
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

  // ─── Ko'rish holati (90% mezoni va davom ettirish) ──────────────────────
  VideoWatchTracker _tracker = VideoWatchTracker(const VideoWatchProgress());
  VideoProgressRemoteSource? _progressSource;
  String? _uid;
  bool _progressLoaded = false;
  int _startAtSeconds = 0;
  int _shownPercent = -1;
  bool _wasPlaying = false;
  DateTime _lastSavedAt = DateTime.now();
  final _webPlayerKey = GlobalKey<WebYoutubePlayerState>();

  static const _saveInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _currentLikes = _initialLikes;
    _isNativeVideo = _videoUrl != null && _videoUrl!.isNotEmpty;
    _progressSource = context.read<VideoProgressRemoteSource>();
    _uid = FirebaseAuth.instance.currentUser?.uid;

    // Increment views via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LibraryProvider>().incrementVideoViews(_videoId);
    });

    _init();
  }

  /// Avval saqlangan holat o'qiladi, keyin pleyer o'sha joydan boshlanadi.
  Future<void> _init() async {
    await _loadProgress();
    if (!mounted) return;
    _startAtSeconds = _tracker.progress.resumePositionSeconds ?? 0;

    if (_isNativeVideo) {
      await _initNativePlayer();
    } else if (_youtubeId != null && _youtubeId!.isNotEmpty && !kIsWeb) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _youtubeId!,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          startAt: _startAtSeconds,
        ),
      )..addListener(_youtubeListener);
    }
    if (!mounted) return;
    setState(() => _progressLoaded = true);

    if (_tracker.progress.isCompleted) _notifyWatched();
    if (_startAtSeconds > 0) _showResumeNotice(_startAtSeconds);
  }

  Future<void> _loadProgress() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final progress = await _progressSource!
          .get(uid, _videoId)
          .timeout(const Duration(seconds: 3));
      _tracker = VideoWatchTracker(progress);
    } catch (e) {
      // Oflayn yoki sekin tarmoq: boshidan boshlanadi
      debugPrint('Video progress yuklanmadi: $e');
    }
  }

  void _saveProgress() {
    final uid = _uid;
    if (uid == null) return;
    _lastSavedAt = DateTime.now();
    _progressSource!.save(uid, _videoId, _tracker.progress).catchError((Object e) {
      debugPrint('Video progress saqlanmadi: $e');
    });
  }

  void _showResumeNotice(int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Oxirgi marta ${_formatSeconds(seconds)} da to\'xtagansiz — shu joydan davom etmoqda',
        ),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Boshidan',
          onPressed: () => _seekToSeconds(0),
        ),
      ),
    );
  }

  static String _formatSeconds(int total) {
    final h = total ~/ 3600, m = (total % 3600) ~/ 60, s = total % 60;
    final mm = m.toString().padLeft(h > 0 ? 2 : 1, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  Future<void> _initNativePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl!));
    await _videoPlayerController!.initialize();

    if (!mounted) return;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      startAt: _startAtSeconds > 0 ? Duration(seconds: _startAtSeconds) : null,
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
    if (!_isPlayerReady) return;
    final value = _youtubeController!.value;
    _onPosition(
      value.position.inMilliseconds / 1000,
      value.isPlaying,
      _youtubeController!.metadata.duration.inSeconds,
    );
  }

  void _nativeVideoListener() {
    final value = _videoPlayerController?.value;
    if (value == null || !value.isInitialized) return;
    _onPosition(
      value.position.inMilliseconds / 1000,
      value.isPlaying,
      value.duration.inSeconds,
    );
  }

  /// Barcha pleyerlardan keladigan pozitsiya: ko'rilgan qismni hisoblaydi,
  /// vaqti-vaqti bilan saqlaydi va 90% ga yetganda darsni yakunlaydi.
  void _onPosition(double seconds, bool isPlaying, int durationSeconds) {
    if (!_progressLoaded) return;
    final reached = _tracker.onPosition(
      seconds,
      isPlaying: isPlaying,
      durationSeconds: durationSeconds,
    );

    final pausedNow = _wasPlaying && !isPlaying;
    _wasPlaying = isPlaying;
    if (reached ||
        pausedNow ||
        (isPlaying && DateTime.now().difference(_lastSavedAt) > _saveInterval)) {
      _saveProgress();
    }
    if (reached) _awardPointsForWatching(durationSeconds);

    final percent = (_tracker.progress.watchedRatio * 100).floor();
    if (percent != _shownPercent && mounted && widget.onWatched != null) {
      setState(() => _shownPercent = percent);
    }
  }

  bool _pointsAwarded = false;
  bool _watchedNotified = false;

  void _notifyWatched() {
    if (_watchedNotified) return;
    _watchedNotified = true;
    widget.onWatched?.call();
  }

  Future<void> _awardPointsForWatching(int durationSeconds) async {
    _notifyWatched();
    if (_pointsAwarded) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _pointsAwarded = true;
    
    // Clean Architecture: Use TrackVideoWatched UseCase
    // This UseCase handles logging to xAPI and triggering Gamification logic internally via LogXApiStatement
    // Hujjat ID'si: server XP berishdan oldin video_tutorials da mavjudligini tekshiradi
    await context.read<TrackVideoWatched>().call(
      videoId: _videoId,
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
    // Chiqishda oxirgi joy saqlanadi — keyingi safar shu yerdan davom etadi
    if (_progressLoaded) _saveProgress();
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
    const loadingPlayer = AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(child: CircularProgressIndicator()),
    );

    // Web: ilova ichidagi iframe pleyer — ko'rilgan qism shu yerda ham kuzatiladi
    if (kIsWeb && !_isNativeVideo && (_youtubeId?.isNotEmpty ?? false)) {
      return _buildMainScaffold(
        _progressLoaded
            ? WebYoutubePlayer(
                key: _webPlayerKey,
                youtubeId: _youtubeId!,
                startSeconds: _startAtSeconds,
                onPosition: _onPosition,
              )
            : loadingPlayer,
      );
    }

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
      playerComponent = loadingPlayer;
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
          // Kurs darsi: qancha ko'rilgani va yakunlash mezoni
          if (widget.onWatched != null && _progressLoaded)
            _WatchedProgressBar(ratio: _tracker.progress.watchedRatio),
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
    _tracker.resetSample(); // sakrash ko'rilgan qism hisoblanmaydi
    if (_isNativeVideo && _chewieController != null) {
      _chewieController!.seekTo(duration);
    } else if (!_isNativeVideo && _youtubeController != null) {
      _youtubeController!.seekTo(duration);
    } else {
      _webPlayerKey.currentState?.seekTo(seconds);
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

/// Videoning qancha qismi haqiqatan ko'rilgani (kurs darsi uchun).
class _WatchedProgressBar extends StatelessWidget {
  final double ratio;

  const _WatchedProgressBar({required this.ratio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (ratio * 100).floor();
    final requiredPercent = (VideoWatchProgress.completionRatio * 100).round();
    final done = ratio >= VideoWatchProgress.completionRatio;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: done ? Colors.green.shade600 : theme.colorScheme.primary,
          ),
          const SizedBox(height: 6),
          Text(
            done
                ? 'Ko\'rildi: $percent% — dars yakunlandi'
                : 'Ko\'rildi: $percent% · yakunlash uchun $requiredPercent% kerak '
                    '(oldinga o\'tkazilgan qism hisoblanmaydi)',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
