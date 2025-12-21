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
  static const int xpThresholdSpecialist = 200;
  static const int xpThresholdExpert = 800;
  static const int xpThresholdMaster = 2000;

  // --- Content Requirements (Gatekeepers) ---
  static const int reqQuizzesForExpert = 5;
  static const int reqQuizzesAcedForExpert = 3;
  static const int reqStreakForMaster = 7;
  static const int reqSimsForMaster = 3;

  // --- Level Names ---
  static const String levelNewbie = 'Boshlang\'ich'; // Newbie
  static const String levelSpecialist = 'Mutaxassis'; // Specialist
  static const String levelExpert = 'Ekspert'; // Expert
  static const String levelMaster = 'Ustoz'; // Master

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
        return levelExpert; // Capped at Expert
      }
    }

    // 2. Check for Expert
    if (xp >= xpThresholdExpert) {
      if (quizzesPassed >= reqQuizzesForExpert && quizzesAced >= reqQuizzesAcedForExpert) {
        return levelExpert;
      } else {
        return levelSpecialist; // Capped at Specialist
      }
    }

    // 3. Check for Specialist
    if (xp >= xpThresholdSpecialist) {
      return levelSpecialist; // No extra requirements for Specialist
    }

    // 4. Default
    return levelNewbie;
  }
}
