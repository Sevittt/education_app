import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/user_course_progress_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/courses/presentation/screens/certificate_screen.dart';
import 'package:sud_qollanma/features/courses/presentation/screens/lesson_viewer_screen.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/difficulty_badge.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/module_expansion_tile.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:sud_qollanma/shared/widgets/animated_button.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';
import 'package:sud_qollanma/shared/widgets/xp_toast_overlay.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CourseProvider>().startCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        final courseIndex = provider.courses.indexWhere((c) => c.id == widget.courseId);
        if (courseIndex == -1) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final course = provider.courses[courseIndex];
        final progress = provider.getUserProgress(course.id);

        return Scaffold(
          backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
          body: SelectionArea(
            child: CustomScrollView(
              slivers: [
                // ─── Hero SliverAppBar ────────────────────────────────────
                _buildSliverAppBar(course, isDark),

                // ─── Sticky Progress Header ───────────────────────────────
                if (progress != null)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyProgressDelegate(
                      progress: progress,
                      totalLessons: course.requiredLessonsCount,
                      isDark: isDark,
                    ),
                  ),

                // ─── Kontent ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCourseHeader(course, isDark),
                        const SizedBox(height: 20),

                        // Boshlash / Davom tugmasi
                        _buildActionButton(course, progress, isDark, provider),
                        const SizedBox(height: 28),

                        // Kurs haqida
                        _buildAboutSection(course, isDark),
                        const SizedBox(height: 28),

                        // Modullar sarlavhasi
                        Text(
                          'Darslar rejasi',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${course.totalLessonsCount} ta dars · ${course.modules.length} ta modul',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Modullar
                        ...List.generate(course.modules.length, (i) {
                          final module = course.modules[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: ModuleExpansionTile(
                                module: module,
                                moduleIndex: i,
                                initiallyExpanded: i == 0,
                                isLessonCompleted: (id) => progress?.isLessonCompleted(id) ?? false,
                                isLessonLocked: (id) => _isLessonLocked(id, course, progress),
                                onLessonTap: (lesson) =>
                                    _navigateToLesson(context, lesson, course.id, provider),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── SliverAppBar (Hero thumbnail) ────────────────────────────────────────

  Widget _buildSliverAppBar(CourseEntity course, bool isDark) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero animatsiya thumbnail uchun
            Hero(
              tag: 'course_thumb_${course.id}',
              child: (course.thumbnailUrl?.isNotEmpty ?? false)
                  ? CustomNetworkImage(
                      imageUrl: course.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorWidget: _buildThumbPlaceholder(isDark),
                    )
                  : _buildThumbPlaceholder(isDark),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    isDark
                        ? AppColors.scaffoldDark
                        : AppColors.backgroundLight.withValues(alpha: 0.95),
                  ],
                  stops: const [0, 0.4, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: 80,
          color: isDark
              ? AppColors.amber.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // ─── Kurs sarlavhasi ──────────────────────────────────────────────────────

  Widget _buildCourseHeader(CourseEntity course, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meta row
        Row(
          children: [
            DifficultyBadge(difficulty: course.difficulty),
            const SizedBox(width: 10),
            _MetaChip(icon: Icons.timer_outlined, label: '${course.estimatedMinutes} daq', isDark: isDark),
            const SizedBox(width: 10),
            _MetaChip(icon: Icons.layers_rounded, label: '${course.modules.length} modul', isDark: isDark),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          course.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  // ─── Harakatlar tugmasi ────────────────────────────────────────────────────

  Widget _buildActionButton(
    CourseEntity course,
    UserCourseProgressEntity? progress,
    bool isDark,
    CourseProvider provider,
  ) {
    final isNotStarted = progress == null;
    final isCompleted = progress?.isCompleted ?? false;

    if (isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Text(
              'Kurs muvaffaqiyatli tugallandi!',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedButton(
      onPressed: _isNavigating ? null : () async {
        if (isNotStarted) {
          await provider.startCourse(course.id);
        }
        final updatedProgress = provider.getUserProgress(course.id);
        
        CourseLessonEntity? targetLesson;
        for (final l in course.allLessons) {
           if (updatedProgress == null || !updatedProgress.isLessonCompleted(l.id)) {
             targetLesson = l;
             break;
           }
        }
        if (targetLesson == null && course.allLessons.isNotEmpty) {
           targetLesson = course.allLessons.first;
        }

        if (targetLesson != null && mounted) {
           _navigateToLesson(context, targetLesson, course.id, provider);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.amberGradient : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNotStarted ? Icons.rocket_launch_rounded : Icons.play_arrow_rounded,
                color: isDark ? Colors.black : Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                isNotStarted ? 'Kursni boshlash' : 'Davom etish',
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Kurs tavsifi ────────────────────────────────────────────────────────

  Widget _buildAboutSection(CourseEntity course, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kurs haqida',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          course.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ─── Lesson locked logic ──────────────────────────────────────────────────

  /// ─── Release Conditions v2 (course-core.md LMS standarti) ──────────────
  ///
  /// Bloklash qoidalari:
  /// 1. `isRequired: false` darslar HECH QACHON bloklanmaydi
  /// 2. 1-dars har doim ochiq
  /// 3. Kurs boshlanmagan bo'lsa, faqat 1-dars ochiq
  /// 4. Tugallangan dars qulflangan emas
  /// 5. Modul darajasi: oldingi modul to'liq tugallanmasa,
  ///    keyingi modulning birinchi majburiy darsi bloklanadi
  /// 6. Quiz gating: `minPassScore` belgilangan quiz tugallanmasa,
  ///    undan keyingi dars bloklanadi
  bool _isLessonLocked(
    String lessonId,
    CourseEntity course,
    UserCourseProgressEntity? progress,
  ) {
    final allLessons = course.allLessons;
    final index = allLessons.indexWhere((l) => l.id == lessonId);
    if (index < 0) return false;

    final lesson = allLessons[index];

    // Qoida 1: Ixtiyoriy darslar bloklanmaydi
    if (!lesson.isRequired) return false;

    // Qoida 2: 1-dars har doim ochiq
    if (index == 0) return false;

    // Qoida 3: Progress dokumenti yo'q bo'lsa (kurs boshlanmagan), faqat 1-dars ochiq
    if (progress == null) return true;

    // Qoida 4: Tugallangan dars qulflangan emas
    if (progress.isLessonCompleted(lessonId)) return false;

    // Qoida 5 & 6: Oldingi majburiy darsni tekshirish
    for (int i = index - 1; i >= 0; i--) {
      final prev = allLessons[i];
      if (!prev.isRequired) continue; // Ixtiyoriy darslarni o'tkazib yuboramiz

      // Oldingi majburiy dars tugallanmagan → bloklash
      if (!progress.isLessonCompleted(prev.id)) return true;

      // Qoida 6: Quiz gating — oldingi quiz `minPassScore` dan o'tmaganmi?
      // (Bu yerda ball ma'lumoti UserCourseProgress dan olinadi
      //  — kelajakda quizScores: Map<lessonId, score> kengaytirish mumkin)
      // Hozircha: quiz tugallangan bo'lsa, o'tgan deb hisoblaymiz
      break; // Birinchi topilgan majburiy oldingi dars tekshirildi
    }

    return false;
  }

  // ─── Navigation ──────────────────────────────────────────────────────────

  Future<void> _navigateToLesson(
    BuildContext context,
    CourseLessonEntity lesson,
    String courseId,
    CourseProvider provider,
  ) async {
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });

    try {
    // Progress dokumenti yo'q bo'lsa kursni boshlash
    final progress = provider.getUserProgress(courseId);
    if (progress == null) {
      await provider.startCourse(courseId);
    }

    if (!context.mounted) return;

    bool didComplete = false;

    if (lesson.type == LessonType.quiz) {
      // Quiz — to'g'ridan-to'g'ri QuizScreen ga yuborish
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizScreen(quizId: lesson.refId)),
      );
      didComplete = true;
    } else {
      // Video, Article, PDF — LessonViewerScreen
      didComplete = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => LessonViewerScreen(lesson: lesson),
        ),
      ) ?? true; // Avtomatik tarzda yakunlangan deb olish (tugmani kutmasdan)
    }

    if (!didComplete || !context.mounted) return;

    await provider.markLessonComplete(courseId, lesson.id, lesson.type.name);

    if (!context.mounted) return;

    // KVI og'irlik tizimi: dars xpReward ini to'g'ridan-to'g'ri ishlat
    XpToastOverlay.show(
      context,
      xpAmount: lesson.xpReward,
      message: '${lesson.title} bajarildi!',
    );

    // Kurs to'liq tugallanganmi?
    final updatedProgress = provider.getUserProgress(courseId);
    final courseIdx = provider.courses.indexWhere((c) => c.id == courseId);
    if (updatedProgress?.isCompleted == true &&
        courseIdx != -1 &&
        provider.courses[courseIdx].hasCertificate &&
        context.mounted) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CertificateScreen(
            course: provider.courses[courseIdx],
            progress: updatedProgress!,
          ),
        ),
      );
    }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }
}

// ─── Sticky Progress Delegate ─────────────────────────────────────────────────

class _StickyProgressDelegate extends SliverPersistentHeaderDelegate {
  final UserCourseProgressEntity progress;
  final int totalLessons;
  final bool isDark;

  _StickyProgressDelegate({
    required this.progress,
    required this.totalLessons,
    required this.isDark,
  });

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final percent = progress.percentComplete;
    final isCompleted = progress.isCompleted;
    final activeColor = isCompleted ? AppColors.success : (isDark ? AppColors.amber : AppColors.primary);

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded,
                    size: 16,
                    color: activeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCompleted ? 'Tugallandi' : 'Jarayon',
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            Row(
                children: [
                  Text(
                    '${progress.completedLessonIds.length} / $totalLessons dars',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            key: ValueKey(percent),
            tween: Tween(begin: 0, end: percent),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (ctx, val, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyProgressDelegate oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.totalLessons != totalLessons ||
      oldDelegate.isDark != isDark;
}

// ─── MetaChip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MetaChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.amber : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
