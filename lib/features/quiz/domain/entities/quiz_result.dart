/// QuizScreen yopilganda qaytaradigan natija (eng yaxshi urinish).
/// Test topshirilmasdan chiqilsa QuizScreen null qaytaradi.
class QuizResult {
  final int correct;
  final int total;

  const QuizResult({required this.correct, required this.total});

  /// Butun foiz (pastga yaxlitlangan), quizScores uchun.
  int get percent => total > 0 ? (correct * 100) ~/ total : 0;

  /// [minPassPercent] chegarasidan o'tganmi. Savolsiz test o'tilgan hisoblanmaydi.
  bool passes(int minPassPercent) =>
      total > 0 && correct * 100 >= minPassPercent * total;

  /// Ikki natijadan foizi yuqorisini tanlaydi.
  QuizResult bestOf(QuizResult? other) {
    if (other == null) return this;
    return correct * other.total >= other.correct * total ? this : other;
  }
}
