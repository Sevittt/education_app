import 'package:flutter/material.dart';
import '../../domain/usecases/gamification_usecases.dart';

class GamificationProvider extends ChangeNotifier {
  final UpdateStreak _updateStreak;
  final AwardPoints _awardPoints;
  final CalculateQuizScore _calculateQuizScore;

  GamificationProvider({
    required UpdateStreak updateStreak,
    required AwardPoints awardPoints,
    required CalculateQuizScore calculateQuizScore,
  }) : _updateStreak = updateStreak,
       _awardPoints = awardPoints,
       _calculateQuizScore = calculateQuizScore;

  Future<void> updateStreak(String userId) async {
    await _updateStreak(userId);
    // Might notify listeners if streak data was local, but here it updates Firestore directly.
  }

  Future<void> awardPoints({
    required String userId,
    required int points,
    required String actionType,
    String? description,
  }) async {
    await _awardPoints(
      userId: userId,
      points: points,
      actionType: actionType,
      description: description,
    );
    notifyListeners();
  }

  Future<int> calculateQuizScore({required bool isCorrect, required int timeTakenSeconds}) async {
    return _calculateQuizScore(isCorrect: isCorrect, timeTakenSeconds: timeTakenSeconds);
  }
}
