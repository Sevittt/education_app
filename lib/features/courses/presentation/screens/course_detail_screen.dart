import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/config/gamification_rules.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_module_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/user_course_progress_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/courses/presentation/screens/certificate_screen.dart';
import 'package:sud_qollanma/features/courses/presentation/screens/lesson_viewer_screen.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_visuals.dart';
import 'package:sud_qollanma/features/library/data/datasources/video_progress_remote_source.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_watch_progress.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz_result.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';
import 'package:sud_qollanma/shared/widgets/xp_toast_overlay.dart';

/// Kurs tafsiloti (Figma "03 · Kurs tafsiloti"): progress, modullar, qulf sababi
/// va pastdagi yagona asosiy tugma.
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
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        final courseIndex = provider.courses.indexWhere((c) => c.id == widget.courseId);
        if (courseIndex == -1) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final course = provider.courses[courseIndex];
        final progress = provider.getUserProgress(course.id);
        final lessons = course.allLessons;
        final next = lessons.where((l) => !(progress?.isLessonCompleted(l.id) ?? false)).firstOrNull;
        final activeModule = next == null ? -1 : course.modules.indexWhere((m) => m.lessons.any((l) => l.id == next.id));

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s8),
                  child: Row(children: [
                    CircleIconButton(Icons.arrow_back_rounded,
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onPressed: () => Navigator.maybePop(context)),
                  ]),
                ),
                Expanded(
                  child: SelectionArea(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s24),
                      children: [
                        _CourseHeader(course: course),
                        const SizedBox(height: AppSpace.s20),
                        if (progress != null) ...[
                          _ProgressCard(course: course, progress: progress),
                          const SizedBox(height: AppSpace.s20),
                        ],
                        SectionHeader(l10n.dsCurriculum),
                        const SizedBox(height: AppSpace.s12),
                        for (var i = 0; i < course.modules.length; i++) ...[
                          _ModuleCard(
                            key: ValueKey(course.modules[i].id),
                            module: course.modules[i],
                            index: i,
                            initiallyExpanded: i == (activeModule < 0 ? 0 : activeModule),
                            progress: progress,
                            currentLessonId: next?.id,
                            lessonNumber: (l) => _lessonNumber(course, l),
                            lockReason: (l) => _lockReason(l, course, progress, l10n),
                            onLessonTap: (l) => _navigateToLesson(context, l, course.id, provider),
                          ),
                          const SizedBox(height: AppSpace.s12),
                        ],
                      ],
                    ),
                  ),
                ),
                StickyActionBar(children: [_buildAction(course, progress, next, provider, l10n, t, text)]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAction(CourseEntity course, UserCourseProgressEntity? progress, CourseLessonEntity? next,
      CourseProvider provider, AppLocalizations l10n, AppTokens t, TextTheme text) {
    if (progress?.isCompleted ?? false) {
      if (course.hasCertificate) {
        return FilledButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => CertificateScreen(course: course, progress: progress!))),
          icon: const Icon(Icons.workspace_premium_outlined),
          label: Text(l10n.dsViewCertificate),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: t.successContainer, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified_rounded, color: t.successSolid),
          const SizedBox(width: AppSpace.s8),
          Text(l10n.dsCourseCompleted, style: text.titleSmall?.copyWith(color: t.successSolid)),
        ]),
      );
    }

    final notStarted = progress == null;
    return FilledButton.icon(
      onPressed: _isNavigating
          ? null
          : () async {
              if (notStarted) await provider.startCourse(course.id);
              final updated = provider.getUserProgress(course.id);
              final target = course.allLessons
                      .where((l) => updated == null || !updated.isLessonCompleted(l.id))
                      .firstOrNull ??
                  course.allLessons.firstOrNull;
              if (target != null && mounted) {
                _navigateToLesson(context, target, course.id, provider);
              }
            },
      icon: Icon(notStarted ? Icons.rocket_launch_outlined : Icons.play_arrow_rounded),
      label: Text(notStarted || next == null
          ? l10n.dsStartCourse
          : l10n.dsContinueLesson(_lessonNumber(course, next))),
    );
  }

  /// "2.3" — modul va dars tartib raqami.
  String _lessonNumber(CourseEntity course, CourseLessonEntity lesson) {
    for (var m = 0; m < course.modules.length; m++) {
      final i = course.modules[m].lessons.indexWhere((l) => l.id == lesson.id);
      if (i >= 0) return '${m + 1}.${i + 1}';
    }
    return '';
  }

  /// Qulflangan dars uchun sabab (qulflanmagan boʻlsa null) — [_isLessonLocked] qoidalari bilan.
  String? _lockReason(CourseLessonEntity lesson, CourseEntity course, UserCourseProgressEntity? progress,
      AppLocalizations l10n) {
    if (!_isLessonLocked(lesson.id, course, progress)) return null;
    if (progress == null) return l10n.dsLessonLockedStart;
    final all = course.allLessons;
    final index = all.indexWhere((l) => l.id == lesson.id);
    for (var i = index - 1; i >= 0; i--) {
      if (all[i].isRequired) return l10n.dsLessonLockedFinish(_lessonNumber(course, all[i]));
    }
    return l10n.dsLessonLockedStart;
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

      // Qoida 6: Quiz gating — quiz dars faqat `minPassScore` (yoki
      // GamificationRules.quizPassPercent) dan o'tilganda tugallangan deb belgilanadi,
      // shuning uchun tugallangan quiz o'tilgan hisoblanadi
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
    int? quizScore;

    if (lesson.type == LessonType.quiz) {
      // Quiz — faqat o'tish chegarasidan o'tgan natija darsni yakunlaydi
      final result = await Navigator.push<QuizResult>(
        context,
        MaterialPageRoute(builder: (_) => QuizScreen(quizId: lesson.refId, minPassPercent: lesson.minPassScore)),
      );
      if (result == null || !context.mounted) return; // Test topshirilmadi

      final minScore = lesson.minPassScore ?? GamificationRules.quizPassPercent;
      if (!result.passes(minScore)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dsQuizNotPassed(result.percent, minScore)),
          ),
        );
        return;
      }
      didComplete = true;
      quizScore = result.percent;
    } else {
      // Video, Article, PDF — faqat aniq yakunlash amali true qaytaradi;
      // orqaga qaytish (null) yakunlash emas
      didComplete = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => LessonViewerScreen(lesson: lesson),
        ),
      ) ?? false;
    }

    if (!didComplete || !context.mounted) return;

    await provider.markLessonComplete(
      courseId,
      lesson.id,
      lesson.type.name,
      score: quizScore,
    );

    if (!context.mounted) return;

    // KVI og'irlik tizimi: dars xpReward ini to'g'ridan-to'g'ri ishlat
    XpToastOverlay.show(
      context,
      xpAmount: lesson.xpReward,
      message: AppLocalizations.of(context)!.dsLessonDoneToast(lesson.title),
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

// ─── Kurs haqida ──────────────────────────────────────────────────────────────

class _CourseHeader extends StatelessWidget {
  final CourseEntity course;

  const _CourseHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    Widget meta(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: t.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: text.labelMedium?.copyWith(color: t.textSecondary)),
        ]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, runSpacing: 6, children: [
        StatusBadge(difficultyLabel(l10n, course.difficulty)),
        if (course.hasCertificate)
          StatusBadge(l10n.dsCertificate, tone: BadgeTone.gold, icon: Icons.workspace_premium_outlined),
      ]),
      const SizedBox(height: AppSpace.s12),
      Text(course.title, style: text.displayMedium),
      if (course.description.isNotEmpty) ...[
        const SizedBox(height: AppSpace.s12),
        Text(course.description, style: text.bodyMedium?.copyWith(color: t.textSecondary)),
      ],
      const SizedBox(height: AppSpace.s12),
      Wrap(spacing: 14, runSpacing: 4, children: [
        meta(Icons.layers_outlined, l10n.dsModules(course.modules.length)),
        meta(Icons.play_arrow_rounded, l10n.dsLessons(course.totalLessonsCount)),
        meta(Icons.schedule_rounded, formatDuration(l10n, course.estimatedMinutes)),
      ]),
    ]);
  }
}

class _ProgressCard extends StatelessWidget {
  final CourseEntity course;
  final UserCourseProgressEntity progress;

  const _ProgressCard({required this.course, required this.progress});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final done = course.allLessons.where((l) => progress.isLessonCompleted(l.id)).length;
    final percent = progress.percentComplete;

    return AppCard(
      child: Column(children: [
        Row(children: [
          ProgressRing(
            value: percent,
            color: progress.isCompleted ? t.successSolid : t.brandPrimary,
            child: Text('${(percent * 100).round()}%', style: text.titleSmall),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.dsYourProgress, style: text.titleSmall),
              Text(l10n.dsLessonsDone(done, course.totalLessonsCount),
                  style: text.bodySmall?.copyWith(color: t.textSecondary)),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.bolt_rounded, size: 14, color: t.goldSolid),
                const SizedBox(width: 4),
                Text(l10n.dsXpEarned(progress.earnedXp), style: text.labelMedium?.copyWith(color: t.goldInk)),
              ]),
            ]),
          ),
        ]),
        if (course.hasCertificate && !progress.isCompleted) ...[
          const SizedBox(height: 14),
          Divider(color: t.borderDefault),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.workspace_premium_outlined, size: 20, color: t.goldSolid),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l10n.dsCertificateCondition, style: text.bodySmall?.copyWith(color: t.textSecondary)),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ─── Modul va darslar ─────────────────────────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  final CourseModuleEntity module;
  final int index;
  final bool initiallyExpanded;
  final UserCourseProgressEntity? progress;
  final String? currentLessonId;
  final String Function(CourseLessonEntity) lessonNumber;
  final String? Function(CourseLessonEntity) lockReason;
  final ValueChanged<CourseLessonEntity> onLessonTap;

  const _ModuleCard({
    super.key,
    required this.module,
    required this.index,
    required this.initiallyExpanded,
    required this.progress,
    required this.currentLessonId,
    required this.lessonNumber,
    required this.lockReason,
    required this.onLessonTap,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final lessons = widget.module.lessons;
    final done = lessons.where((l) => widget.progress?.isLessonCompleted(l.id) ?? false).length;
    final allDone = lessons.isNotEmpty && done == lessons.length;
    final locked = lessons.isNotEmpty && lessons.every((l) => widget.lockReason(l) != null);
    final active = !allDone && !locked;

    final String meta;
    final Color metaColor;
    if (allDone) {
      meta = '${l10n.dsModuleProgress(done, lessons.length)} · ${l10n.dsCompleted.toLowerCase()}';
      metaColor = t.successSolid;
    } else if (locked) {
      meta = l10n.dsModuleLockedUntil(widget.index);
      metaColor = t.textTertiary;
    } else {
      meta = l10n.dsModuleProgress(done, lessons.length);
      metaColor = t.textSecondary;
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s16),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: allDone ? t.successContainer : active ? t.brandPrimary : t.bgSubtle,
                ),
                child: allDone
                    ? Icon(Icons.check_rounded, size: 16, color: t.successSolid)
                    : active
                        ? Text('${widget.index + 1}', style: text.titleSmall?.copyWith(color: t.textOnBrand))
                        : Icon(Icons.lock_outline_rounded, size: 16, color: t.textTertiary),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.dsModuleLabel(widget.index + 1),
                      style: text.labelSmall?.copyWith(color: locked ? t.textTertiary : t.textSecondary)),
                  Text(widget.module.title,
                      style: text.titleSmall?.copyWith(color: locked ? t.textTertiary : t.textPrimary)),
                  Text(meta, style: text.bodySmall?.copyWith(color: metaColor)),
                ]),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: t.textTertiary),
              ),
            ]),
          ),
        ),
        if (_expanded && lessons.isNotEmpty) ...[
          Divider(height: 1, color: t.borderDefault),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
            child: Column(children: [
              for (final lesson in lessons)
                _LessonRow(
                  lesson: lesson,
                  number: widget.lessonNumber(lesson),
                  completed: widget.progress?.isLessonCompleted(lesson.id) ?? false,
                  current: lesson.id == widget.currentLessonId,
                  lockReason: widget.lockReason(lesson),
                  onTap: () => widget.onLessonTap(lesson),
                ),
            ]),
          ),
        ],
      ]),
    );
  }
}

/// Figma "Dars qatori": Tugallangan / Jarayonda / Ochiq / Qulflangan.
class _LessonRow extends StatelessWidget {
  final CourseLessonEntity lesson;
  final String number;
  final bool completed;
  final bool current;
  final String? lockReason;
  final VoidCallback onTap;

  const _LessonRow({
    required this.lesson,
    required this.number,
    required this.completed,
    required this.current,
    required this.lockReason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locked = lockReason != null;
    final active = current && !locked;

    final (Color circle, IconData icon, Color iconColor) = completed
        ? (t.successContainer, Icons.check_rounded, t.successSolid)
        : locked
            ? (t.bgSubtle, Icons.lock_outline_rounded, t.textTertiary)
            : active
                ? (t.brandPrimary, Icons.play_arrow_rounded, t.textOnBrand)
                : (t.bgSubtle, lessonTypeIcon(lesson.type), t.textSecondary);

    final meta = [
      lessonTypeLabel(l10n, lesson.type),
      if (lesson.estimatedMinutes != null) l10n.dsMinutes(lesson.estimatedMinutes!),
      if (!lesson.isRequired) l10n.dsOptional,
    ].join(' · ');

    return InkWell(
      onTap: locked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: AppSpace.s12),
        child: Row(children: [
          IconTile(icon, background: circle, foreground: iconColor, circle: true),
          const SizedBox(width: AppSpace.s12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$number ${lesson.title}',
                  style: text.titleSmall?.copyWith(color: locked ? t.textTertiary : t.textPrimary)),
              const SizedBox(height: 2),
              if (active && lesson.type == LessonType.video)
                _VideoWatchLine(videoId: lesson.refId, fallback: meta)
              else
                Text(locked ? lockReason! : meta,
                    style: text.bodySmall?.copyWith(color: locked ? t.textTertiary : t.textSecondary)),
            ]),
          ),
          const SizedBox(width: AppSpace.s8),
          if (completed && lesson.xpReward > 0)
            Text('+${lesson.xpReward} XP', style: text.labelMedium?.copyWith(color: t.successSolid))
          else if (!locked)
            Icon(Icons.chevron_right_rounded, color: active ? t.brandPrimary : t.textTertiary),
        ]),
      ),
    );
  }
}

/// Joriy video dars uchun koʻrilgan qism: progress va "12:40 / 18:05".
class _VideoWatchLine extends StatefulWidget {
  final String videoId;
  final String fallback;

  const _VideoWatchLine({required this.videoId, required this.fallback});

  @override
  State<_VideoWatchLine> createState() => _VideoWatchLineState();
}

class _VideoWatchLineState extends State<_VideoWatchLine> {
  Future<VideoWatchProgress>? _future;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _future = VideoProgressRemoteSource().get(uid, widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return FutureBuilder<VideoWatchProgress>(
      future: _future,
      builder: (context, snap) {
        final p = snap.data;
        if (p == null || p.durationSeconds <= 0 || p.lastPositionSeconds <= 0) {
          return Text(widget.fallback, style: text.bodySmall?.copyWith(color: t.textSecondary));
        }
        return Row(children: [
          Expanded(child: ProgressLine(value: p.watchedRatio)),
          const SizedBox(width: AppSpace.s8),
          Text('${formatClock(p.lastPositionSeconds)} / ${formatClock(p.durationSeconds)}',
              style: text.labelMedium?.copyWith(color: t.brandPrimary)),
        ]);
      },
    );
  }
}
