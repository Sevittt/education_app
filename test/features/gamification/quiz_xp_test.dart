import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/features/analytics/domain/entities/xapi_actor.dart';
import 'package:sud_qollanma/features/analytics/domain/entities/xapi_statement.dart';
import 'package:sud_qollanma/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:sud_qollanma/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:sud_qollanma/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/submit_quiz_attempt.dart';

class _Award {
  final String actionType;
  final String targetId;
  final String? courseId;
  final bool speedBonus;
  _Award(this.actionType, this.targetId, this.courseId, this.speedBonus);
}

class _FakeGamification extends Fake implements GamificationRepository {
  final awards = <_Award>[];

  @override
  Future<void> awardPoints({
    required String actionType,
    required String targetId,
    String? courseId,
    bool speedBonus = false,
  }) async {
    awards.add(_Award(actionType, targetId, courseId, speedBonus));
  }
}

class _FakeAnalytics extends Fake implements AnalyticsRepository {
  final statements = <XApiStatement>[];

  @override
  Future<void> recordStatement(XApiStatement statement) async {
    statements.add(statement);
  }
}

class _FakeQuizRepository extends Fake implements QuizRepository {
  @override
  Future<void> submitQuizAttempt(QuizAttempt attempt) async {}
}

const _user = XApiActor(name: 'Test', mbox: 'mailto:uid123@sudqollanma.uz');
const _guest = XApiActor(name: 'Guest', mbox: 'mailto:guest@sudqollanma.uz');

XApiStatement _quizStatement({
  required bool passed,
  required double score,
  String? duration,
  XApiActor actor = _user,
}) {
  return XApiStatement(
    actor: actor,
    verb: passed ? XApiVerbs.passed : XApiVerbs.failed,
    object: XApiObject(id: 'quiz1', definition: {
      'type': 'http://adlnet.gov/expapi/activities/assessment',
    }),
    result: XApiResult(
      success: passed,
      completion: true,
      duration: duration,
      score: {'raw': score, 'scaled': score / 100},
    ),
    timestamp: DateTime(2026, 10, 31),
  );
}

void main() {
  late _FakeGamification gamification;
  late _FakeAnalytics analytics;
  late LogXApiStatement log;

  setUp(() {
    gamification = _FakeGamification();
    analytics = _FakeAnalytics();
    log = LogXApiStatement(analytics, gamification);
  });

  group('LogXApiStatement — quiz XP', () {
    test("yiqilgan quiz XP bermaydi, lekin xAPI yoziladi", () async {
      await log(_quizStatement(passed: false, score: 50));
      expect(gamification.awards, isEmpty);
      expect(analytics.statements, hasLength(1));
    });

    test("o'tilgan quiz quiz_passed ni quiz ID bilan so'raydi", () async {
      await log(_quizStatement(passed: true, score: 80));
      expect(gamification.awards, hasLength(1));
      expect(gamification.awards.single.actionType, 'quiz_passed');
      expect(gamification.awards.single.targetId, 'quiz1');
      expect(gamification.awards.single.speedBonus, isFalse);
    });

    test('100% natija quiz_aced bo\'ladi', () async {
      await log(_quizStatement(passed: true, score: 100));
      expect(gamification.awards.single.actionType, 'quiz_aced');
    });

    test('5 soniyagacha speed bonus so\'raladi', () async {
      await log(_quizStatement(passed: true, score: 80, duration: 'PT4S'));
      expect(gamification.awards.single.speedBonus, isTrue);
    });

    test('mehmon uchun XP so\'ralmaydi', () async {
      await log(_quizStatement(passed: true, score: 100, actor: _guest));
      expect(gamification.awards, isEmpty);
    });

    test("result.success bo'lmasa verb hal qiladi", () async {
      await log(XApiStatement(
        actor: _user,
        verb: XApiVerbs.failed,
        object: XApiObject(id: 'quiz1', definition: {
          'type': 'http://adlnet.gov/expapi/activities/assessment',
        }),
        timestamp: DateTime(2026, 10, 31),
      ));
      expect(gamification.awards, isEmpty);
    });
  });

  group('SubmitQuizAttempt → XP chegarasi', () {
    Future<List<_Award>> submit(int score, int total) async {
      final submitQuiz = SubmitQuizAttempt(
        _FakeQuizRepository(),
        trackQuizCompleted: TrackQuizCompletedForTest(log),
      );
      await submitQuiz(QuizAttempt(
        id: 'a1',
        userId: 'uid123',
        quizId: 'quiz1',
        quizTitle: 'Quiz',
        score: score,
        totalQuestions: total,
        attemptedAt: DateTime(2026, 10, 31),
        timeTakenSeconds: 60,
      ));
      return gamification.awards;
    }

    test('0% — XP yo\'q', () async => expect(await submit(0, 10), isEmpty));
    test('69% — XP yo\'q', () async => expect(await submit(69, 100), isEmpty));
    test('70% — quiz_passed', () async {
      final awards = await submit(7, 10);
      expect(awards.single.actionType, 'quiz_passed');
    });
    test('100% — quiz_aced', () async {
      final awards = await submit(10, 10);
      expect(awards.single.actionType, 'quiz_aced');
    });
  });
}

/// TrackQuizCompleted FirebaseAuth'dan actor oladi; testda actor qo'lda beriladi.
class TrackQuizCompletedForTest extends TrackQuizCompleted {
  TrackQuizCompletedForTest(super.logStatement);

  @override
  Future<void> call({
    required String quizId,
    required String title,
    required double score,
    required bool passed,
    int? timeTakenSeconds,
  }) {
    return logStatement(XApiStatement(
      actor: _user,
      verb: passed ? XApiVerbs.passed : XApiVerbs.failed,
      object: XApiObject(id: quizId, definition: {
        'type': 'http://adlnet.gov/expapi/activities/assessment',
      }),
      result: XApiResult(
        success: passed,
        completion: true,
        duration: timeTakenSeconds != null ? 'PT${timeTakenSeconds}S' : null,
        score: {'raw': score, 'scaled': score / 100.0},
      ),
      timestamp: DateTime(2026, 10, 31),
    ));
  }
}
