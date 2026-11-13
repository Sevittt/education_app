import 'package:sud_qollanma/config/gamification_rules.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

/// Daraja identifikatori (levelBeginner…levelMaster) uchun tarjima qilingan nom.
String levelName(AppLocalizations l10n, String levelId) => switch (levelId) {
      GamificationRules.levelIntermediate => l10n.levelIntermediate,
      GamificationRules.levelAdvanced => l10n.levelAdvanced,
      GamificationRules.levelSpecialist => l10n.levelSpecialist,
      GamificationRules.levelExpert => l10n.levelExpert,
      GamificationRules.levelMaster => l10n.dsLevelMaster,
      _ => l10n.levelBeginner,
    };

/// XP boʻyicha keyingi daraja (eng yuqorisida null).
String? nextLevelId(int xp) {
  if (xp < GamificationRules.xpThresholdIntermediate) return GamificationRules.levelIntermediate;
  if (xp < GamificationRules.xpThresholdAdvanced) return GamificationRules.levelAdvanced;
  if (xp < GamificationRules.xpThresholdSpecialist) return GamificationRules.levelSpecialist;
  if (xp < GamificationRules.xpThresholdExpert) return GamificationRules.levelExpert;
  if (xp < GamificationRules.xpThresholdMaster) return GamificationRules.levelMaster;
  return null;
}
