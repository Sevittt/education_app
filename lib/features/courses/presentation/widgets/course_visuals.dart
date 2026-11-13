import 'package:flutter/material.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

/// Kurs ikonkasi: rasm oʻrniga mavzu boʻyicha ikonka (tez yuklanadi, bir xil koʻrinadi).
IconData courseIcon(CourseEntity course) {
  final t = course.title.toLowerCase();
  if (t.contains('xavfsiz') || t.contains('security')) return Icons.shield_outlined;
  if (t.contains('arxiv')) return Icons.inventory_2_outlined;
  if (t.contains('imzo') || t.contains('bayonnoma')) return Icons.edit_outlined;
  if (t.contains('murojaat') || t.contains('xat')) return Icons.mail_outline_rounded;
  if (t.contains('ijro') || t.contains('hujjat')) return Icons.description_outlined;
  if (t.contains('it ') || t.contains('kompyuter') || t.contains('edo')) return Icons.computer_outlined;
  if (t.contains('protsessual') || t.contains('qonun')) return Icons.menu_book_outlined;
  return Icons.balance_outlined;
}

IconData lessonTypeIcon(LessonType type) => switch (type) {
      LessonType.video => Icons.smart_display_outlined,
      LessonType.article => Icons.article_outlined,
      LessonType.pdf => Icons.picture_as_pdf_outlined,
      LessonType.quiz => Icons.checklist_rounded,
    };

String lessonTypeLabel(AppLocalizations l10n, LessonType type) => switch (type) {
      LessonType.video => l10n.dsLessonTypeVideo,
      LessonType.article => l10n.dsLessonTypeArticle,
      LessonType.pdf => l10n.dsLessonTypePdf,
      LessonType.quiz => l10n.dsLessonTypeQuiz,
    };

String difficultyLabel(AppLocalizations l10n, CourseDifficulty d) => switch (d) {
      CourseDifficulty.beginner => l10n.courseFilterBeginner,
      CourseDifficulty.intermediate => l10n.courseFilterIntermediate,
      CourseDifficulty.advanced => l10n.courseFilterAdvanced,
    };

/// "3 soat 20 daq", "45 daq".
String formatDuration(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.dsMinutes(m);
  if (m == 0) return l10n.dsHours(h);
  return '${l10n.dsHours(h)} ${l10n.dsMinutes(m)}';
}

/// "12:40"
String formatClock(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Kurs boʻyicha jami mumkin boʻlgan XP.
int courseXp(CourseEntity course) =>
    course.allLessons.fold(0, (sum, l) => sum + l.xpReward);
