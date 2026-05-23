import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/user_course_progress_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/difficulty_badge.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';

/// Premium animatsiyali kurs kartasi.
///
/// - Staggered slide-fade kirish animatsiyasi (index asosida kechikish)
/// - `TweenAnimationBuilder` animatsiyali progress bar
/// - `Hero` widget image uchun (list → detail)
/// - `TypeChip` qatori (video/pdf/quiz soni)
/// - `CourseStatusButton` holati bilan
class AnimatedCourseCard extends StatefulWidget {
  final CourseEntity course;
  final UserCourseProgressEntity? progress;
  final VoidCallback onTap;
  final int index; // stagger kechikish uchun

  const AnimatedCourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.progress,
    this.index = 0,
  });

  @override
  State<AnimatedCourseCard> createState() => _AnimatedCourseCardState();
}

class _AnimatedCourseCardState extends State<AnimatedCourseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: har bir karta index*80ms kechikish bilan paydo bo'ladi
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool hasStarted = widget.progress != null && !widget.progress!.isNotStarted;
    final bool isCompleted = widget.progress?.isCompleted ?? false;
    final double percent = widget.progress?.percentComplete ?? 0.0;

    final status = isCompleted
        ? CourseStatus.completed
        : (hasStarted ? CourseStatus.inProgress : CourseStatus.notStarted);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Thumbnail (sol) ─────────────────────────────────────
                  Hero(
                    tag: 'course_thumb_${widget.course.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: (widget.course.thumbnailUrl?.isNotEmpty ?? false)
                          ? CustomNetworkImage(
                              imageUrl: widget.course.thumbnailUrl!,
                              width: 120,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: _PlaceholderThumbnail(isDark: isDark),
                              errorWidget: _PlaceholderThumbnail(isDark: isDark),
                            )
                          : _PlaceholderThumbnail(isDark: isDark),
                    ),
                  ),

                  // ─── Kontent (o'ng) ──────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Difficulty + vaqt
                          Row(
                            children: [
                              DifficultyBadge(difficulty: widget.course.difficulty, compact: true),
                              const SizedBox(width: 8),
                              _InfoPill(
                                icon: Icons.timer_outlined,
                                label: '${widget.course.estimatedMinutes} daq',
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            widget.course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // TypeChips qatori
                          _buildTypeChips(isDark),
                          const SizedBox(height: 10),

                          // Progress yoki status tugmasi
                          if (hasStarted && !isCompleted)
                            _AnimatedProgressBar(percent: percent, isDark: isDark)
                          else
                            CourseStatusButton(
                              status: status,
                              progress: percent,
                              onTap: widget.onTap,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChips(bool isDark) {
    final types = <Widget>[];
    if (widget.course.videoCount > 0) {
      types.add(TypeChip(type: LessonType.video, count: widget.course.videoCount, isDark: isDark));
      types.add(const SizedBox(width: 6));
    }
    if (widget.course.pdfCount > 0) {
      types.add(TypeChip(type: LessonType.pdf, count: widget.course.pdfCount, isDark: isDark));
      types.add(const SizedBox(width: 6));
    }
    if (widget.course.quizCount > 0) {
      types.add(TypeChip(type: LessonType.quiz, count: widget.course.quizCount, isDark: isDark));
    }
    if (types.isEmpty) return const SizedBox.shrink();
    return Row(children: types);
  }
}

// ─── AnimatedProgressBar ─────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  final double percent;
  final bool isDark;

  const _AnimatedProgressBar({required this.percent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: percent),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '▶ Davom etilmoqda',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.amber : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.amber : AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Placeholder thumbnail ────────────────────────────────────────────────────

class _PlaceholderThumbnail extends StatelessWidget {
  final bool isDark;

  const _PlaceholderThumbnail({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 120,
      color: isDark ? AppColors.surfaceElevated : AppColors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: 36,
          color: isDark ? AppColors.amber : AppColors.primary,
        ),
      ),
    );
  }
}

// ─── InfoPill (vaqt va boshqa meta) ─────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoPill({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
