import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_module_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/lesson_tile.dart';

/// Premium modul expansion tile.
///
/// - Leading: CircleAvatar (modul indeks raqami yoki ✓ yashil)
/// - Darslar soni + umumiy vaqt ko'rsatiladi
/// - Smooth AnimatedCrossFade
class ModuleExpansionTile extends StatefulWidget {
  final CourseModuleEntity module;
  final bool initiallyExpanded;
  final bool Function(String lessonId) isLessonCompleted;
  final bool Function(String lessonId) isLessonLocked;
  final void Function(CourseLessonEntity lesson) onLessonTap;
  final int moduleIndex;

  const ModuleExpansionTile({
    super.key,
    required this.module,
    this.initiallyExpanded = false,
    required this.isLessonCompleted,
    required this.isLessonLocked,
    required this.onLessonTap,
    this.moduleIndex = 0,
  });

  @override
  State<ModuleExpansionTile> createState() => _ModuleExpansionTileState();
}

class _ModuleExpansionTileState extends State<ModuleExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _isExpanded ? 1 : 0,
    );
    _iconTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _iconCtrl.forward();
    } else {
      _iconCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedCount =
        widget.module.lessons.where((l) => widget.isLessonCompleted(l.id)).length;
    final totalCount = widget.module.lessons.length;
    final isModuleCompleted = completedCount == totalCount && totalCount > 0;
    final totalMinutes =
        widget.module.lessons.fold<int>(0, (sum, l) => sum + (l.estimatedMinutes ?? 0));

    final activeColor = isDark ? AppColors.amber : AppColors.primary;

    return Column(
      children: [
        // ─── Header ───────────────────────────────────────────────────
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Module index badge / checkmark
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isModuleCompleted
                      ? const _ModuleBadge(
                          key: ValueKey('check'),
                          color: AppColors.success,
                          child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        )
                      : _ModuleBadge(
                          key: ValueKey('num_${widget.moduleIndex}'),
                          color: activeColor.withValues(alpha: 0.15),
                          bordered: true,
                          borderColor: activeColor,
                          child: Text(
                            '${widget.moduleIndex + 1}',
                            style: TextStyle(
                              color: activeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 14),

                // Module title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.module.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$completedCount/$totalCount dars',
                            style: TextStyle(
                              color: isModuleCompleted
                                  ? AppColors.success
                                  : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$totalMinutes daq',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rotation arrow
                RotationTransition(
                  turns: _iconTurn,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Animated content ─────────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: List.generate(widget.module.lessons.length, (index) {
                final lesson = widget.module.lessons[index];
                return LessonTile(
                  lesson: lesson,
                  lessonIndex: index,
                  isCompleted: widget.isLessonCompleted(lesson.id),
                  isLocked: widget.isLessonLocked(lesson.id),
                  onTap: () => widget.onLessonTap(lesson),
                );
              }),
            ),
          ),
          crossFadeState:
              _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOutCubic,
        ),
      ],
    );
  }
}

// ─── ModuleBadge ─────────────────────────────────────────────────────────────

class _ModuleBadge extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool bordered;
  final Color? borderColor;

  const _ModuleBadge({
    super.key,
    required this.child,
    required this.color,
    this.bordered = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: bordered && borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      child: Center(child: child),
    );
  }
}
