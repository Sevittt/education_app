/// Videoning haqiqatan ko'rilgan qismi va oxirgi to'xtagan joyi.
/// Oldinga o'tkazib yuborilgan (seek) qism ko'rilgan hisoblanmaydi.
/// Firestore: users/{uid}/video_progress/{videoId}
class VideoWatchProgress {
  /// Dars yakunlanishi uchun ko'rilishi kerak bo'lgan ulush.
  static const double completionRatio = 0.9;

  /// firestore.rules dagi watchedRanges cheklovi.
  static const int maxRanges = 100;

  final int durationSeconds;
  final int lastPositionSeconds;

  /// Saralangan, bir-biriga tegmaydigan [start, end) oraliqlar (soniya).
  final List<WatchedRange> ranges;

  const VideoWatchProgress({
    this.durationSeconds = 0,
    this.lastPositionSeconds = 0,
    this.ranges = const [],
  });

  int get watchedSeconds => ranges.fold(0, (sum, r) => sum + r.length);

  double get watchedRatio {
    if (durationSeconds <= 0) return 0;
    return (watchedSeconds / durationSeconds).clamp(0.0, 1.0);
  }

  bool get isCompleted =>
      durationSeconds > 0 && watchedSeconds >= durationSeconds * completionRatio;

  /// Davom ettirish taklif qilinadigan joy: boshida yoki oxirida bo'lsa null.
  int? get resumePositionSeconds {
    if (durationSeconds <= 0) return null;
    if (lastPositionSeconds < 10) return null;
    if (lastPositionSeconds > durationSeconds - 10) return null;
    return lastPositionSeconds;
  }

  VideoWatchProgress copyWith({int? durationSeconds, int? lastPositionSeconds}) {
    return VideoWatchProgress(
      durationSeconds: durationSeconds ?? this.durationSeconds,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      ranges: ranges,
    );
  }

  /// [start, end) oraliqni qo'shadi va kesishgan/tutash oraliqlarni birlashtiradi.
  VideoWatchProgress addRange(int start, int end) {
    if (end <= start) return this;
    final merged = <WatchedRange>[];
    var current = WatchedRange(start, end);
    var inserted = false;
    for (final r in ranges) {
      if (r.end < current.start) {
        merged.add(r);
      } else if (r.start > current.end) {
        if (!inserted) {
          merged.add(current);
          inserted = true;
        }
        merged.add(r);
      } else {
        current = WatchedRange(
          r.start < current.start ? r.start : current.start,
          r.end > current.end ? r.end : current.end,
        );
      }
    }
    if (!inserted) merged.add(current);

    // Juda ko'p bo'lak bo'lsa eng kichik oraliqlarni tashlaymiz (rules cheklovi)
    while (merged.length > maxRanges) {
      var smallest = 0;
      for (var i = 1; i < merged.length; i++) {
        if (merged[i].length < merged[smallest].length) smallest = i;
      }
      merged.removeAt(smallest);
    }

    return VideoWatchProgress(
      durationSeconds: durationSeconds,
      lastPositionSeconds: lastPositionSeconds,
      ranges: List.unmodifiable(merged),
    );
  }

  factory VideoWatchProgress.fromMap(Map<String, dynamic> data) {
    final raw = data['watchedRanges'] as List? ?? const [];
    var progress = VideoWatchProgress(
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      lastPositionSeconds: (data['lastPositionSeconds'] as num?)?.toInt() ?? 0,
    );
    for (final r in raw) {
      if (r is Map) {
        final s = (r['start'] as num?)?.toInt();
        final e = (r['end'] as num?)?.toInt();
        if (s != null && e != null) progress = progress.addRange(s, e);
      }
    }
    return progress;
  }

  Map<String, dynamic> toMap() {
    return {
      'durationSeconds': durationSeconds,
      'lastPositionSeconds': lastPositionSeconds,
      'watchedRanges': [
        for (final r in ranges) {'start': r.start, 'end': r.end},
      ],
      'completed': isCompleted,
    };
  }
}

class WatchedRange {
  final int start;
  final int end;

  const WatchedRange(this.start, this.end);

  int get length => end - start;

  @override
  bool operator ==(Object other) =>
      other is WatchedRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '[$start, $end)';
}

/// Pleyer pozitsiyalaridan ko'rilgan oraliqlarni yig'adi.
/// Ikki namuna orasidagi kichik o'sish (oddiy ijro, 2x tezlik ham) ko'rilgan
/// hisoblanadi; katta sakrash yoki orqaga qaytish — seek, hisoblanmaydi.
class VideoWatchTracker {
  static const double maxStepSeconds = 3;

  VideoWatchProgress _progress;
  double? _lastSample;

  VideoWatchTracker(this._progress);

  VideoWatchProgress get progress => _progress;

  /// Har pozitsiya o'zgarishida chaqiriladi.
  /// Ko'rish mezoniga shu namunada birinchi marta yetilsa true qaytaradi.
  bool onPosition(double seconds, {required bool isPlaying, int? durationSeconds}) {
    final wasCompleted = _progress.isCompleted;
    if (durationSeconds != null && durationSeconds > 0 &&
        durationSeconds != _progress.durationSeconds) {
      _progress = _progress.copyWith(durationSeconds: durationSeconds);
    }

    final last = _lastSample;
    _lastSample = seconds;
    if (isPlaying && last != null) {
      final step = seconds - last;
      if (step > 0 && step <= maxStepSeconds) {
        _progress = _progress.addRange(last.floor(), seconds.ceil());
      }
    }

    _progress = _progress.copyWith(lastPositionSeconds: seconds.floor());
    return !wasCompleted && _progress.isCompleted;
  }

  /// Seek'dan keyin oldingi namuna bilan bog'lamaslik uchun.
  void resetSample() => _lastSample = null;
}
