class GamificationRules {
  // --- XP Constants ---
  // Tier 1: Passive (Knowledge)
  static const int xpArticleView = 5;
  static const int xpVideoComplete = 10;
  
  // Tier 2: Active (Verification)
  static const int xpQuizPass = 20;
  static const int xpQuizPerfect = 10; // Bonus for 100% score

  // Tier 3: Practical (Simulation)
  static const int xpSimInteraction = 50;
  static const int xpSimComplete = 100;

  // --- Level Thresholds ---
  static const int xpThresholdSpecialist = 200;
  static const int xpThresholdExpert = 800;
  static const int xpThresholdMaster = 2000;

  // --- Content Requirements (Gatekeepers) ---
  static const int reqQuizzesForExpert = 5;
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
    required int simulationsCompleted,
  }) {
    // 1. Check for Master
    if (xp >= xpThresholdMaster) {
      if (simulationsCompleted >= reqSimsForMaster) {
        return levelMaster;
      } else {
        return levelExpert; // Capped at Expert if Sims not done
      }
    }

    // 2. Check for Expert
    if (xp >= xpThresholdExpert) {
      if (quizzesPassed >= reqQuizzesForExpert) {
        return levelExpert;
      } else {
        return levelSpecialist; // Capped at Specialist if Quizzes not done
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
