import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/services/drift_database_service.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/courses/data/seeds/dars_courses_seed.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_visuals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/library/data/datasources/video_progress_remote_source.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_watch_progress.dart';
import 'package:sud_qollanma/features/library/presentation/screens/video_player_screen.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

/// Dars kontent ekrani (Figma "04 · Dars — video").
/// [refId] + [sourceCollection] orqali Firestore'dan kontent yuklanadi.
/// `true` faqat aniq yakunlash amalida qaytariladi: maqola/PDF uchun tugma,
/// video uchun kamida 90% haqiqatan ko'rilganda. Orqaga qaytish null beradi.
class LessonViewerScreen extends StatefulWidget {
  final CourseLessonEntity lesson;

  const LessonViewerScreen({super.key, required this.lesson});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  static const Map<String, List<String>> _lessonChunkSuffixes = {
    'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_1': ['1', '2'],
    'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_3': ['3', '4', '5', '6'],
    'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_5': ['7', '8_1', '8_2', '8_3', '10', '11'],
    'dars_1_modul_bo_yicha_to_liq_amaliy_qo_llanma_7': [
      '9_1', '9_2', '9_3', '12', '13', '14',
      '15_1', '15_2', '15_3', '15_4', '15_5',
      '16', '17', '18', '19', '20',
    ],
    'dars_2_modul_bo_yicha_to_liq_amaliy_qo_llanma_1': ['1', '2', '3', '4', '5'],
    'dars_2_modul_bo_yicha_to_liq_amaliy_qo_llanma_3': ['6', '7', '8', '9', '10'],
    'dars_3_modul_bo_yicha_to_liq_amaliy_qo_llanma_1': [
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11',
    ],
    'dars_4_modul_bo_yicha_to_liq_amaliy_qo_llanma_1': [
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '10_1',
      '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21',
    ],
    'dars_5_modul_bo_yicha_to_liq_amaliy_qo_llanma_1': [
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
    ],
  };

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  VideoWatchProgress _videoProgress = const VideoWatchProgress();

  String get _resolvedRefId {
    final raw = widget.lesson.refId.trim();
    if (raw.isNotEmpty) return raw;
    for (final c in DarsCurriculumSeed.getOfficialCourses()) {
      for (final m in c.modules) {
        for (final l in m.lessons) {
          if (l.id == widget.lesson.id && l.refId.isNotEmpty) {
            return l.refId;
          }
        }
      }
    }
    return '';
  }

  String get _resolvedCollection {
    final raw = widget.lesson.sourceCollection.trim();
    if (raw.isNotEmpty) return raw;
    return widget.lesson.type == LessonType.video ? 'video_tutorials' : 'knowledge_base';
  }

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<Map<String, dynamic>?> _loadOfflineOrRagArticle(String refId) async {
    final basePrefix = refId.replaceFirst(RegExp(r'_\d+$'), '');
    final suffixes = _lessonChunkSuffixes[refId];
    final allowedIds = (suffixes != null && basePrefix.isNotEmpty)
        ? suffixes.map((s) => '${basePrefix}_$s').toSet()
        : null;
    try {
      final chunks = await DriftDatabaseService.instance.db.getAllRagChunks();
      final exact = chunks.where((c) => c.id == refId).firstOrNull;
      final related = allowedIds != null
          ? chunks.where((c) => allowedIds.contains(c.id)).toList()
          : chunks.where((c) => c.id == refId).toList();
      if (related.isNotEmpty) {
        final combined = related.map((c) {
          final body = c.content.trim();
          if (body.startsWith('#') || body.toLowerCase().startsWith(c.title.trim().toLowerCase())) {
            return body;
          }
          return '### ${c.title}\n\n$body';
        }).join('\n\n---\n\n');
        return {
          'title': widget.lesson.title.isNotEmpty
              ? widget.lesson.title
              : (exact?.title ?? related.first.title),
          'content': combined,
        };
      }
    } catch (_) {}
    return null;
  }

  Future<void> _loadContent() async {
    try {
      final refId = _resolvedRefId;
      final col = _resolvedCollection;
      Map<String, dynamic>? loadedData;

      if (refId.isNotEmpty) {
        try {
          final doc = await FirebaseFirestore.instance.collection(col).doc(refId).get();
          if (doc.exists && doc.data() != null) {
            loadedData = doc.data();
          }
        } catch (_) {}

        if (loadedData == null && widget.lesson.type == LessonType.article) {
          loadedData = await _loadOfflineOrRagArticle(refId);
        }
      }

      if (loadedData == null) {
        throw Exception('Kontent topilmadi');
      }

      if (!mounted) return;
      setState(() {
        _data = loadedData;
        _loading = false;
      });

      if (widget.lesson.type == LessonType.video && mounted) {
        _loadVideoProgress();
        WidgetsBinding.instance.addPostFrameCallback((_) => _openVideoDirectly());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  VideoEntity _videoFromData(Map<String, dynamic> data) => VideoEntity(
        id: _resolvedRefId,
        title: data['title'] as String? ?? widget.lesson.title,
        description: data['description'] as String? ?? '',
        youtubeId: data['youtubeId'] as String?,
        videoUrl: data['videoUrl'] as String?,
        durationSeconds: (data['duration'] as num?)?.toInt() ??
            (data['durationSeconds'] as num?)?.toInt() ??
            0,
        category: data['category'] as String? ?? 'beginner',
        systemId: data['systemId'] as String?,
        thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
        tags: List<String>.from(data['tags'] as List? ?? []),
        authorId: data['authorId'] as String? ?? '',
        authorName: data['authorName'] as String? ?? '',
        views: (data['views'] as num?)?.toInt() ?? 0,
        likes: (data['likes'] as num?)?.toInt() ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        order: (data['order'] as num?)?.toInt() ?? 0,
        timeCodes: (data['timeCodes'] as List?)
                ?.map((e) => VideoTimeCode.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Future<void> _openVideoDirectly() async {
    if (!mounted || _data == null) return;
    await _playVideo(_videoFromData(_data!));
  }

  /// Videoni ochadi; kamida 90% ko'rilgan bo'lsa darsni yakunlab chiqadi,
  /// aks holda foydalanuvchi shu ekranda qoladi va ko'rilgan ulushini ko'radi.
  Future<void> _playVideo(VideoEntity video) async {
    var watched = false;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoEntity: video,
          onWatched: () => watched = true,
        ),
      ),
    );
    if (!mounted) return;
    if (watched) {
      Navigator.pop(context, true);
    } else {
      await _loadVideoProgress();
    }
  }

  Future<void> _loadVideoProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final progress = await context
          .read<VideoProgressRemoteSource>()
          .get(uid, _resolvedRefId);
      if (mounted) setState(() => _videoProgress = progress);
    } catch (e) {
      debugPrint('Video progress yuklanmadi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s8),
            child: Row(children: [
              CircleIconButton(Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.pop(context)),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Column(children: [
                  Text(lessonTypeLabel(l10n, widget.lesson.type),
                      style: text.labelMedium?.copyWith(color: t.textTertiary)),
                  Text(widget.lesson.title,
                      style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ]),
              ),
              const SizedBox(width: 52),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(l10n, t, text)
                    : _buildContent(l10n),
          ),
        ]),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, AppTokens t, TextTheme text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          IconTile(Icons.wifi_off_rounded, size: 72, circle: true, background: t.dangerContainer, foreground: t.dangerSolid),
          const SizedBox(height: AppSpace.s20),
          Text(l10n.dsContentLoadFailed, style: text.titleLarge),
          const SizedBox(height: AppSpace.s8),
          Text(_error ?? '', textAlign: TextAlign.center, style: text.bodySmall?.copyWith(color: t.textSecondary)),
          const SizedBox(height: AppSpace.s24),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _loadContent();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.dsRetry),
          ),
        ]),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final data = _data!;
    switch (widget.lesson.type) {
      case LessonType.video:
        final video = _videoFromData(data);
        final completed = _videoProgress.isCompleted;
        final resumeAt = _videoProgress.resumePositionSeconds;
        return _LessonLayout(
          actions: [
            if (completed)
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(l10n.dsFinishLesson),
              )
            else
              FilledButton.icon(
                onPressed: () => _playVideo(video),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(resumeAt == null ? l10n.dsWatchVideo : l10n.dsContinueVideo(formatClock(resumeAt))),
              ),
          ],
          child: _VideoBody(
            lesson: widget.lesson,
            video: video,
            progress: _videoProgress,
            onPlay: () => _playVideo(video),
          ),
        );
      case LessonType.article:
        return _LessonLayout(
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(l10n.dsReadDone),
            ),
          ],
          child: _ArticleBody(
            lesson: widget.lesson,
            title: data['title'] as String? ?? widget.lesson.title,
            content: data['content'] as String? ?? data['text'] as String? ?? '',
          ),
        );
      case LessonType.pdf:
        final url = data['url'] as String? ?? data['pdfUrl'] as String?;
        return _LessonLayout(
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(l10n.dsFinishLesson),
            ),
          ],
          child: _PdfBody(
            lesson: widget.lesson,
            title: data['title'] as String? ?? widget.lesson.title,
            description: data['description'] as String? ?? '',
            url: url,
            onOpen: () => _openUrl(url!),
          ),
        );
      case LessonType.quiz:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── Umumiy tuzilma ───────────────────────────────────────────────────────────

class _LessonLayout extends StatelessWidget {
  final Widget child;
  final List<Widget> actions;

  const _LessonLayout({required this.child, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: SelectionArea(child: SingleChildScrollView(child: child))),
      StickyActionBar(children: actions),
    ]);
  }
}

class _LessonBadges extends StatelessWidget {
  final CourseLessonEntity lesson;
  final String typeLabel;
  final IconData icon;

  const _LessonBadges({required this.lesson, required this.typeLabel, required this.icon});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(spacing: 6, runSpacing: 6, children: [
      StatusBadge(
        [typeLabel, if (lesson.estimatedMinutes != null) l10n.dsMinutes(lesson.estimatedMinutes!)].join(' · '),
        tone: BadgeTone.neutral,
        icon: icon,
      ),
      if (lesson.isRequired) StatusBadge(l10n.dsMandatory, tone: BadgeTone.danger),
      if (lesson.xpReward > 0) StatusBadge('+${lesson.xpReward} XP', tone: BadgeTone.gold, icon: Icons.bolt_rounded),
    ]);
  }
}

// ─── Video ────────────────────────────────────────────────────────────────────

class _VideoBody extends StatelessWidget {
  final CourseLessonEntity lesson;
  final VideoEntity video;
  final VideoWatchProgress progress;
  final VoidCallback onPlay;

  const _VideoBody({required this.lesson, required this.video, required this.progress, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final resumeAt = progress.resumePositionSeconds;
    final duration = progress.durationSeconds > 0 ? progress.durationSeconds : video.durationSeconds;
    final requiredPercent = (VideoWatchProgress.completionRatio * 100).round();
    final watchedPercent = (progress.watchedRatio * 100).floor();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _PlayerCard(
        onPlay: onPlay,
        resumeAt: resumeAt,
        duration: duration,
        position: progress.lastPositionSeconds,
      ),
      Padding(
        padding: const EdgeInsets.all(AppSpace.s16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (resumeAt != null) ...[
            AppCard(
              color: t.brandContainer,
              border: false,
              child: Row(children: [
                Icon(Icons.replay_rounded, color: t.brandOnContainer),
                const SizedBox(width: AppSpace.s12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.dsLastStoppedAt(formatClock(resumeAt)),
                        style: text.titleSmall?.copyWith(color: t.brandOnContainer)),
                    Text(l10n.dsResumeHint, style: text.bodySmall?.copyWith(color: t.textSecondary)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: AppSpace.s16),
          ],
          _LessonBadges(lesson: lesson, typeLabel: lessonTypeLabel(l10n, lesson.type), icon: Icons.smart_display_outlined),
          const SizedBox(height: AppSpace.s8),
          Text(video.title, style: text.titleLarge),
          const SizedBox(height: AppSpace.s16),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(progress.isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                    size: 20, color: t.successSolid),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(progress.isCompleted ? l10n.dsVideoWatchedReady : l10n.dsAutoCompleteTitle,
                        style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text(l10n.dsAutoCompleteBody(requiredPercent),
                        style: text.bodySmall?.copyWith(color: t.textSecondary)),
                  ]),
                ),
              ]),
              const SizedBox(height: AppSpace.s12),
              Row(children: [
                Text(l10n.dsWatched, style: text.labelMedium?.copyWith(color: t.textSecondary)),
                const SizedBox(width: 10),
                Expanded(
                  child: ProgressLine(
                    value: progress.watchedRatio,
                    color: progress.isCompleted ? t.successSolid : t.brandPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text('$watchedPercent%', style: text.labelMedium?.copyWith(color: t.brandPrimary)),
              ]),
            ]),
          ),
          if (video.description.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s16),
            Text(video.description, style: text.bodyMedium?.copyWith(color: t.textSecondary)),
          ],
        ]),
      ),
    ]);
  }
}

/// Qorongʻi "pleyer" kartasi: video alohida ekranda ochiladi, bu yerda — oxirgi joy.
class _PlayerCard extends StatelessWidget {
  final VoidCallback onPlay;
  final int? resumeAt;
  final int duration;
  final int position;

  const _PlayerCard({required this.onPlay, required this.resumeAt, required this.duration, required this.position});

  static const _bg = Color(0xFF05080F);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final white = Colors.white;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: _bg,
        child: InkWell(
          onTap: onPlay,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (resumeAt != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.replay_rounded, size: 14, color: white),
                    const SizedBox(width: 6),
                    Text(l10n.dsResumeChip, style: text.labelMedium?.copyWith(color: white)),
                  ]),
                ),
              const Spacer(),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: white.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_rounded, size: 36, color: white),
                ),
              ),
              const Spacer(),
              if (duration > 0) ...[
                Text('${formatClock(position.clamp(0, duration))} / ${formatClock(duration)}',
                    style: text.labelMedium?.copyWith(color: white)),
                const SizedBox(height: AppSpace.s8),
                ProgressLine(
                  value: position / duration,
                  height: 4,
                  color: white,
                  trackColor: white.withValues(alpha: 0.25),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Maqola ───────────────────────────────────────────────────────────────────

class _ArticleBody extends StatelessWidget {
  final CourseLessonEntity lesson;
  final String title;
  final String content;

  const _ArticleBody({required this.lesson, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _LessonBadges(lesson: lesson, typeLabel: l10n.dsLessonTypeArticle, icon: Icons.article_outlined),
            const SizedBox(height: AppSpace.s12),
            Text(title, style: text.displayMedium),
            const SizedBox(height: AppSpace.s16),
            Divider(color: t.borderDefault),
            const SizedBox(height: AppSpace.s16),
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: text.bodyLarge?.copyWith(color: t.textPrimary, height: 1.7),
                h1: text.headlineMedium?.copyWith(color: t.textPrimary, fontWeight: FontWeight.w700),
                h2: text.titleLarge?.copyWith(color: t.textPrimary, fontWeight: FontWeight.w700),
                h3: text.titleMedium?.copyWith(color: t.brandPrimary, fontWeight: FontWeight.w700),
                listBullet: text.bodyLarge?.copyWith(color: t.brandPrimary),
                blockquoteDecoration: BoxDecoration(
                  color: t.bgSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border(left: BorderSide(color: t.brandPrimary, width: 4)),
                ),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(top: BorderSide(color: t.borderDefault, width: 1)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── PDF ──────────────────────────────────────────────────────────────────────

class _PdfBody extends StatelessWidget {
  final CourseLessonEntity lesson;
  final String title;
  final String description;
  final String? url;
  final VoidCallback onOpen;

  const _PdfBody({
    required this.lesson,
    required this.title,
    required this.description,
    required this.url,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hasUrl = url != null && url!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _LessonBadges(lesson: lesson, typeLabel: l10n.dsLessonTypePdf, icon: Icons.picture_as_pdf_outlined),
        const SizedBox(height: AppSpace.s12),
        Text(title, style: text.displayMedium),
        if (description.isNotEmpty) ...[
          const SizedBox(height: AppSpace.s12),
          Text(description, style: text.bodyMedium?.copyWith(color: t.textSecondary)),
        ],
        const SizedBox(height: AppSpace.s20),
        AppCard(
          onTap: hasUrl ? onOpen : null,
          child: Row(children: [
            IconTile(Icons.picture_as_pdf_outlined, background: t.dangerContainer, foreground: t.dangerSolid),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: Text(hasUrl ? l10n.dsOpenDocument : l10n.dsNoFileLink,
                  style: text.titleSmall?.copyWith(color: hasUrl ? t.textPrimary : t.textTertiary)),
            ),
            if (hasUrl) Icon(Icons.open_in_new_rounded, color: t.brandPrimary),
          ]),
        ),
      ]),
    );
  }
}
