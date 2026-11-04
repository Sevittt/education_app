import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/config/gamification_rules.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_result.dart';

void main() {
  const pass = GamificationRules.quizPassPercent;

  group('QuizResult.passes', () {
    test('0% va 69% o\'tmaydi', () {
      expect(const QuizResult(correct: 0, total: 10).passes(pass), isFalse);
      expect(const QuizResult(correct: 69, total: 100).passes(pass), isFalse);
    });

    test('70% va 100% o\'tadi', () {
      expect(const QuizResult(correct: 7, total: 10).passes(pass), isTrue);
      expect(const QuizResult(correct: 10, total: 10).passes(pass), isTrue);
    });

    test('yaxlitlash chegarani oshirmaydi (2/3 = 66.7% < 70%)', () {
      expect(const QuizResult(correct: 2, total: 3).passes(pass), isFalse);
      expect(const QuizResult(correct: 2, total: 3).percent, 66);
    });

    test('dars minPassScore chegarasi ishlatiladi', () {
      expect(const QuizResult(correct: 8, total: 10).passes(90), isFalse);
      expect(const QuizResult(correct: 9, total: 10).passes(90), isTrue);
    });

    test('savolsiz test o\'tilgan hisoblanmaydi', () {
      expect(const QuizResult(correct: 0, total: 0).passes(0), isFalse);
    });
  });

  test('bestOf foizi yuqori natijani saqlaydi', () {
    const low = QuizResult(correct: 3, total: 10);
    const high = QuizResult(correct: 9, total: 10);
    expect(low.bestOf(high), same(high));
    expect(high.bestOf(low), same(high));
    expect(low.bestOf(null), same(low));
  });
}
