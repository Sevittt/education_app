class GamificationRules {
  // --- XP Constants ---
  // Tier 1: Passive (Knowledge)
  static const int xpArticleView = 5;
  static const int xpArticleScroll = 5;
  static const int xpVideoComplete = 10;
  
  // Tier 2: Active (Verification)
  static const int xpQuizBase = 10;
  static const int xpQuizPass = 20;
  static const int xpQuizPerfect = 50; // Bonus for 100% score
  static const int xpSpeedBonus = 5; // Updated to 5 per BMI_LM.txt
  static const int xpLoginStreak = 5; // Per day (Duolingo style)

  // Tier 3: Practical (Simulation)
  static const int xpSimInteraction = 50;
  static const int xpSimComplete = 100;

  // --- Level Thresholds ---
  static const int xpThresholdIntermediate = 100;
  static const int xpThresholdAdvanced = 500;
  static const int xpThresholdSpecialist = 1000;
  static const int xpThresholdExpert = 2000;
  static const int xpThresholdMaster = 5000;

  // --- Content Requirements (Gatekeepers) ---
  static const int reqQuizzesPassedForExpert = 5;
  static const int reqQuizzesAcedForExpert = 3;
  static const int reqStreakForMaster = 7;
  static const int reqSimsForMaster = 3;

  // --- Level Names ---
  static const String levelBeginner = 'levelBeginner';
  static const String levelIntermediate = 'levelIntermediate';
  static const String levelAdvanced = 'levelAdvanced';
  static const String levelSpecialist = 'levelSpecialist';
  static const String levelExpert = 'levelExpert';
  static const String levelMaster = 'levelMaster';

  /// Determines the level based on XP and Competency Counters (Gatekeeper Logic)
  static String calculateLevel({
    required int xp,
    required int quizzesPassed,
    required int quizzesAced,
    required int currentStreak,
    required int simulationsCompleted,
  }) {
    // 1. Check for Master
    if (xp >= xpThresholdMaster) {
      if (simulationsCompleted >= reqSimsForMaster && currentStreak >= reqStreakForMaster) {
        return levelMaster;
      } else {
        return levelExpert; // Capped at Expert if gatekeepers not met
      }
    }

    // 2. Check for Expert
    if (xp >= xpThresholdExpert) {
      if (quizzesPassed >= reqQuizzesPassedForExpert && quizzesAced >= reqQuizzesAcedForExpert) {
        return levelExpert;
      } else {
        return levelSpecialist; // Capped at Specialist if gatekeepers not met
      }
    }

    // 3. Check for Specialist
    if (xp >= xpThresholdSpecialist) {
      return levelSpecialist;
    }

    // 4. Check for Advanced
    if (xp >= xpThresholdAdvanced) {
      return levelAdvanced;
    }

    // 5. Check for Intermediate
    if (xp >= xpThresholdIntermediate) {
      return levelIntermediate;
    }

    // 6. Default
    return levelBeginner;
  }
}
