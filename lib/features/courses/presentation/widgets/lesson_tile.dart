import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/shared/widgets/animated_button.dart';

/// Animatsiyali dars kartasi.
///
/// - Har tip uchun rang kodlash
/// - Quiz darslarda `+XP` badge
/// - `AnimatedSwitcher` orqali icon o'zgarishi
/// - Tugallanganda `AnimatedCheckIcon`
class LessonTile extends StatelessWidget {
  final CourseLessonEntity lesson;
  final bool isCompleted;
  final bool isLocked;
  final int lessonIndex;
  final VoidCallback? onTap;

  const LessonTile({
    super.key,
    required this.lesson,
    this.isCompleted = false,
    this.isLocked = false,
    this.lessonIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final typeConfig = _getTypeConfig();
    final bgColor = isDark ? AppColors.surfaceElevated : AppColors.surfaceVariantLight;

    final textColor = isLocked
        ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)
        : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight);

    return AnimatedButton(
      onPressed: isLocked ? null : onTap,
      scaleFactor: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isCompleted
              ? Border.all(color: AppColors.success.withValues(alpha: 0.35), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            // ─── Animatsiyali icon ───────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Container(
                key: ValueKey(isCompleted ? 'done' : lesson.type.name),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.12)
                      : typeConfig.color.withValues(alpha: isDark ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppColors.success,
                      )
                    : Icon(
                        isLocked ? Icons.lock_outline_rounded : typeConfig.icon,
                        size: 20,
                        color: isLocked
                            ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)
                            : typeConfig.color,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // ─── Matn ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Vaqt
                      _MetaChip(
                        icon: Icons.access_time_rounded,
                        label: '${lesson.estimatedMinutes ?? 0} daq',
                        isDark: isDark,
                      ),
                      // Dars turi nomi
                      _MetaChip(
                        icon: typeConfig.icon,
                        label: typeConfig.label,
                        isDark: isDark,
                        color: typeConfig.color,
                      ),
                      // Majburiy badge
                      if (lesson.isRequired)
                        _RequiredBadge(isDark: isDark),
                      // Quiz XP badge
                      if (lesson.type == LessonType.quiz)
                        _XpBadge(xp: 15, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Trailing ────────────────────────────────────────────────
            const SizedBox(width: 8),
            _buildTrailing(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(bool isDark) {
    if (isCompleted) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 22,
        ),
      );
    } else if (isLocked) {
      return Icon(
        Icons.lock_rounded,
        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        size: 18,
      );
    } else {
      return Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.amber : AppColors.primary,
        size: 22,
      );
    }
  }

  _LessonTypeConfig _getTypeConfig() {
    switch (lesson.type) {
      case LessonType.video:
        return _LessonTypeConfig(
          icon: Icons.play_circle_filled_rounded,
          color: const Color(0xFF3B82F6),
          label: 'Video',
        );
      case LessonType.pdf:
        return _LessonTypeConfig(
          icon: Icons.picture_as_pdf_rounded,
          color: AppColors.error,
          label: 'PDF',
        );
      case LessonType.article:
        return _LessonTypeConfig(
          icon: Icons.article_rounded,
          color: AppColors.success,
          label: 'Maqola',
        );
      case LessonType.quiz:
        return _LessonTypeConfig(
          icon: Icons.quiz_rounded,
          color: AppColors.warning,
          label: 'Test',
        );
    }
  }
}

// ─── Helper models ────────────────────────────────────────────────────────────

class _LessonTypeConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _LessonTypeConfig({required this.icon, required this.color, required this.label});
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: c),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: c)),
      ],
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  final bool isDark;
  const _RequiredBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.amberContainer : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Majburiy',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.amber : AppColors.primary,
        ),
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int xp;
  final bool isDark;
  const _XpBadge({required this.xp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '+$xp XP',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
    );
  }
}
