import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Web uchun ilova ichidagi YouTube pleyer (youtube_player_flutter web'da ishlamaydi).
/// Pozitsiya o'zgarishini [onPosition] orqali beradi — ko'rilgan qismni kuzatish uchun.
class WebYoutubePlayer extends StatefulWidget {
  final String youtubeId;
  final int startSeconds;
  final void Function(double seconds, bool isPlaying, int durationSeconds) onPosition;

  const WebYoutubePlayer({
    super.key,
    required this.youtubeId,
    required this.onPosition,
    this.startSeconds = 0,
  });

  @override
  State<WebYoutubePlayer> createState() => WebYoutubePlayerState();
}

class WebYoutubePlayerState extends State<WebYoutubePlayer> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubeVideoState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeId,
      autoPlay: true,
      startSeconds: widget.startSeconds > 0 ? widget.startSeconds.toDouble() : null,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
    _stateSub = _controller.videoStateStream.listen((state) {
      final value = _controller.value;
      widget.onPosition(
        state.position.inMilliseconds / 1000,
        value.playerState == PlayerState.playing,
        value.metaData.duration.inSeconds,
      );
    });
  }

  Future<void> seekTo(int seconds) =>
      _controller.seekTo(seconds: seconds.toDouble(), allowSeekAhead: true);

  Future<void> pause() => _controller.pauseVideo();

  @override
  void dispose() {
    _stateSub?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller, aspectRatio: 16 / 9);
  }
}
