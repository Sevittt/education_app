import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';

/// Kurs qiyinlik darajasini ko'rsatuvchi badge widget.
/// Border va rang kodlash bilan.
class DifficultyBadge extends StatelessWidget {
  final CourseDifficulty difficulty;
  final bool compact;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getDifficultyConfig();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: config.borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: compact ? 10 : 12, color: config.textColor),
          const SizedBox(width: 4),
          Text(
            difficulty.displayName,
            style: TextStyle(
              color: config.textColor,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _DifficultyConfig _getDifficultyConfig() {
    switch (difficulty) {
      case CourseDifficulty.beginner:
        return _DifficultyConfig(
          bgColor: AppColors.success.withValues(alpha: 0.12),
          borderColor: AppColors.success.withValues(alpha: 0.5),
          textColor: AppColors.success,
          icon: Icons.arrow_upward_rounded,
        );
      case CourseDifficulty.intermediate:
        return _DifficultyConfig(
          bgColor: AppColors.warning.withValues(alpha: 0.12),
          borderColor: AppColors.warning.withValues(alpha: 0.5),
          textColor: AppColors.warning,
          icon: Icons.trending_up_rounded,
        );
      case CourseDifficulty.advanced:
        return _DifficultyConfig(
          bgColor: AppColors.error.withValues(alpha: 0.12),
          borderColor: AppColors.error.withValues(alpha: 0.5),
          textColor: AppColors.error,
          icon: Icons.local_fire_department_rounded,
        );
    }
  }
}

class _DifficultyConfig {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  const _DifficultyConfig({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });
}

/// Dars turi (video/pdf/quiz/article) sonini ko'rsatuvchi chip widget.
class TypeChip extends StatelessWidget {
  final LessonType type;
  final int count;
  final bool isDark;

  const TypeChip({
    super.key,
    required this.type,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: config.color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig() {
    switch (type) {
      case LessonType.video:
        return _TypeConfig(icon: Icons.play_circle_outline_rounded, color: const Color(0xFF3B82F6));
      case LessonType.pdf:
        return _TypeConfig(icon: Icons.picture_as_pdf_rounded, color: AppColors.error);
      case LessonType.quiz:
        return _TypeConfig(icon: Icons.quiz_rounded, color: AppColors.warning);
      case LessonType.article:
        return _TypeConfig(icon: Icons.article_rounded, color: AppColors.success);
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  const _TypeConfig({required this.icon, required this.color});
}

/// Kurs holati tugmasi: 3 holat — Boshlash / Davom / Tugallandi
enum CourseStatus { notStarted, inProgress, completed }

class CourseStatusButton extends StatelessWidget {
  final CourseStatus status;
  final double progress; // 0.0 — 1.0
  final VoidCallback onTap;

  const CourseStatusButton({
    super.key,
    required this.status,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case CourseStatus.notStarted:
        return _buildStartButton(isDark);
      case CourseStatus.inProgress:
        return _buildProgressButton(isDark);
      case CourseStatus.completed:
        return _buildCompletedBadge();
    }
  }

  Widget _buildStartButton(bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.amberGradient : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch_rounded, size: 14, color: isDark ? Colors.black : Colors.white),
            const SizedBox(width: 6),
            Text(
              'Boshlash',
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressButton(bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.amber : AppColors.primary,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, size: 14, color: isDark ? AppColors.amber : AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Davom ${(progress * 100).toInt()}%',
              style: TextStyle(
                color: isDark ? AppColors.amber : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
          SizedBox(width: 6),
          Text(
            'Tugallandi',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
