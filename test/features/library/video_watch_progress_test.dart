import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_watch_progress.dart';

void main() {
  group('VideoWatchProgress.addRange', () {
    test('kesishgan va tutash oraliqlar birlashadi', () {
      final p = const VideoWatchProgress(durationSeconds: 100)
          .addRange(0, 10)
          .addRange(20, 30)
          .addRange(10, 20);
      expect(p.ranges, [const WatchedRange(0, 30)]);
      expect(p.watchedSeconds, 30);
    });

    test('alohida oraliqlar saralangan holda saqlanadi', () {
      final p = const VideoWatchProgress(durationSeconds: 100)
          .addRange(50, 60)
          .addRange(0, 10);
      expect(p.ranges, [const WatchedRange(0, 10), const WatchedRange(50, 60)]);
    });

    test('bo\'laklar soni rules chegarasidan oshmaydi', () {
      var p = const VideoWatchProgress(durationSeconds: 10000);
      for (var i = 0; i < VideoWatchProgress.maxRanges + 20; i++) {
        p = p.addRange(i * 10, i * 10 + 1);
      }
      expect(p.ranges.length, VideoWatchProgress.maxRanges);
    });

    test('toMap/fromMap qaytadan bir xil holat beradi', () {
      final p = const VideoWatchProgress(durationSeconds: 120, lastPositionSeconds: 45)
          .addRange(0, 45)
          .addRange(60, 70);
      final back = VideoWatchProgress.fromMap(p.toMap());
      expect(back.ranges, p.ranges);
      expect(back.durationSeconds, 120);
      expect(back.lastPositionSeconds, 45);
      expect(p.toMap()['completed'], isFalse);
    });
  });

  group('90% mezoni', () {
    test('89% yetmaydi, 90% yetadi', () {
      const base = VideoWatchProgress(durationSeconds: 100);
      expect(base.addRange(0, 89).isCompleted, isFalse);
      expect(base.addRange(0, 90).isCompleted, isTrue);
    });

    test('davomiyligi noma\'lum video yakunlangan hisoblanmaydi', () {
      expect(const VideoWatchProgress().addRange(0, 500).isCompleted, isFalse);
    });
  });

  group('resumePositionSeconds', () {
    test('o\'rtada to\'xtagan bo\'lsa shu joy taklif qilinadi', () {
      expect(
        const VideoWatchProgress(durationSeconds: 300, lastPositionSeconds: 125)
            .resumePositionSeconds,
        125,
      );
    });

    test('boshida yoki oxirida bo\'lsa taklif yo\'q', () {
      expect(
        const VideoWatchProgress(durationSeconds: 300, lastPositionSeconds: 5)
            .resumePositionSeconds,
        isNull,
      );
      expect(
        const VideoWatchProgress(durationSeconds: 300, lastPositionSeconds: 295)
            .resumePositionSeconds,
        isNull,
      );
    });
  });

  group('VideoWatchTracker', () {
    VideoWatchTracker playFrom(double from, double to, {double step = 0.5}) {
      final t = VideoWatchTracker(const VideoWatchProgress());
      for (var s = from; s <= to; s += step) {
        t.onPosition(s, isPlaying: true, durationSeconds: 100);
      }
      return t;
    }

    test('oddiy ijro ko\'rilgan qism sifatida hisoblanadi', () {
      final t = playFrom(0, 50);
      expect(t.progress.watchedSeconds, inInclusiveRange(49, 51));
      expect(t.progress.lastPositionSeconds, 50);
    });

    test('oldinga sakrash (seek) hisoblanmaydi', () {
      final t = VideoWatchTracker(const VideoWatchProgress());
      t.onPosition(0, isPlaying: true, durationSeconds: 100);
      t.onPosition(1, isPlaying: true, durationSeconds: 100);
      t.onPosition(95, isPlaying: true, durationSeconds: 100); // oxiriga sakrash
      t.onPosition(96, isPlaying: true, durationSeconds: 100);
      expect(t.progress.watchedSeconds, lessThanOrEqualTo(3));
      expect(t.progress.isCompleted, isFalse);
    });

    test('pauza paytidagi pozitsiya o\'zgarishi hisoblanmaydi', () {
      final t = VideoWatchTracker(const VideoWatchProgress());
      for (var s = 0.0; s <= 20; s += 1) {
        t.onPosition(s, isPlaying: false, durationSeconds: 100);
      }
      expect(t.progress.watchedSeconds, 0);
    });

    test('2x tezlikdagi ijro hisoblanadi', () {
      final t = playFrom(0, 40, step: 2);
      expect(t.progress.watchedSeconds, inInclusiveRange(39, 41));
    });

    test('mezonga faqat birinchi marta yetganda true qaytaradi', () {
      final t = VideoWatchTracker(const VideoWatchProgress());
      final hits = <double>[];
      for (var s = 0.0; s <= 100; s += 1) {
        if (t.onPosition(s, isPlaying: true, durationSeconds: 100)) hits.add(s);
      }
      expect(hits, hasLength(1));
      expect(hits.single, inInclusiveRange(89, 91));
    });

    test('avvalgi sessiyada ko\'rilgan qism saqlanib qoladi', () {
      final earlier = const VideoWatchProgress(durationSeconds: 100).addRange(0, 60);
      final t = VideoWatchTracker(earlier);
      var reached = false;
      for (var s = 60.0; s <= 92; s += 1) {
        reached = t.onPosition(s, isPlaying: true, durationSeconds: 100) || reached;
      }
      expect(reached, isTrue);
      expect(t.progress.isCompleted, isTrue);
    });
  });
}
