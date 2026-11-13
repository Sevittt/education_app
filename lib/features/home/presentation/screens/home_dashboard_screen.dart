import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/user_course_progress_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_list_card.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_visuals.dart';
import 'package:sud_qollanma/features/home/presentation/widgets/admin_stat_section.dart';
import 'package:sud_qollanma/features/library/data/datasources/video_progress_remote_source.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_watch_progress.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';
import 'package:sud_qollanma/features/notifications/presentation/providers/notification_notifier.dart';
import 'package:sud_qollanma/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:sud_qollanma/features/search/presentation/screens/global_search_screen.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';
import 'package:sud_qollanma/shared/widgets/level_names.dart';

typedef OnTabSelected = void Function(int index);

/// Bosh sahifa (Figma "01 · Bosh sahifa"): eng muhim harakat — davom ettirish.
class HomeDashboardScreen extends StatefulWidget {
  final OnTabSelected onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  Stream<int>? _unread;
  late final Stream<List<NewsEntity>> _news = context.read<NewsNotifier>().newsStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _unread = context.read<NotificationNotifier>().getUnreadCount(uid);
  }

  void _openCourse(String id) => Navigator.pushNamed(context, '/course_detail', arguments: id);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthNotifier>().appUser;
    final courses = context.watch<CourseProvider>();

    final started = <(CourseEntity, UserCourseProgressEntity)>[
      for (final c in courses.courses)
        if (courses.getUserProgress(c.id) case final p? when !p.isCompleted) (c, p),
    ]..sort((a, b) => b.$2.lastAccessedAt.compareTo(a.$2.lastAccessedAt));
    final notStarted = courses.courses.where((c) => courses.getUserProgress(c.id) == null).take(5).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s24),
        children: [
          _Header(user: user, unread: _unread),
          const SizedBox(height: AppSpace.s16),
          if (started.isNotEmpty)
            _ContinueCard(course: started.first.$1, progress: started.first.$2, onOpen: _openCourse)
          else
            _StartCard(onBrowse: () => widget.onTabSelected(1)),
          if (user != null) ...[
            const SizedBox(height: AppSpace.s24),
            _StatsCard(user: user),
          ],
          if (user?.isAdmin == true) ...[
            const SizedBox(height: AppSpace.s24),
            const AdminStatSection(),
          ],
          if (started.length > 1) ...[
            const SizedBox(height: AppSpace.s24),
            SectionHeader(AppLocalizations.of(context)!.myCoursesTitle,
                actionLabel: AppLocalizations.of(context)!.dsSeeAll, onAction: () => widget.onTabSelected(1)),
            const SizedBox(height: AppSpace.s12),
            for (final (c, p) in started.skip(1).take(2)) ...[
              CourseListCard(course: c, progress: p, onTap: () => _openCourse(c.id)),
              const SizedBox(height: AppSpace.s12),
            ],
          ],
          if (notStarted.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s24),
            SectionHeader(AppLocalizations.of(context)!.dsRecommended,
                actionLabel: AppLocalizations.of(context)!.dsSeeAll, onAction: () => widget.onTabSelected(1)),
            const SizedBox(height: AppSpace.s12),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: notStarted.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpace.s12),
                itemBuilder: (_, i) => _RecommendedTile(course: notStarted[i], onTap: () => _openCourse(notStarted[i].id)),
              ),
            ),
          ],
          StreamBuilder<List<NewsEntity>>(
            stream: _news,
            builder: (context, snap) {
              final latest = snap.data?.firstOrNull;
              if (latest == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: AppSpace.s24),
                child: _NewsTile(news: latest),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser? user;
  final Stream<int>? unread;

  const _Header({required this.user, required this.unread});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final greeting = hour < 11 ? l10n.dsGreetingMorning : hour < 18 ? l10n.dsGreetingDay : l10n.dsGreetingEvening;
    final name = user?.name ?? l10n.guestUser;

    return Row(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: t.brandContainer,
        child: Text(_initials(name), style: text.titleSmall?.copyWith(color: t.brandOnContainer)),
      ),
      const SizedBox(width: AppSpace.s12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting, style: text.bodySmall?.copyWith(color: t.textSecondary)),
          Text(name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
      CircleIconButton(Icons.search_rounded,
          tooltip: l10n.search,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchScreen()))),
      const SizedBox(width: AppSpace.s8),
      CircleIconButton(Icons.auto_awesome_outlined,
          tooltip: l10n.dsAiAssistant,
          iconColor: t.brandPrimary,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen()))),
      const SizedBox(width: AppSpace.s8),
      StreamBuilder<int>(
        stream: unread,
        builder: (context, snap) => CircleIconButton(Icons.notifications_none_rounded,
            tooltip: l10n.dsNotifications,
            showDot: (snap.data ?? 0) > 0,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
      ),
    ]);
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return (parts.first[0] + (parts.length > 1 ? parts[1][0] : '')).toUpperCase();
  }
}

/// "Davom ettirish" kartasi: oxirgi ochilgan kurs, keyingi dars va video joyi.
class _ContinueCard extends StatelessWidget {
  final CourseEntity course;
  final UserCourseProgressEntity progress;
  final ValueChanged<String> onOpen;

  const _ContinueCard({required this.course, required this.progress, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final lessons = course.allLessons;
    final next = lessons.where((l) => !progress.isLessonCompleted(l.id)).firstOrNull;
    final done = lessons.where((l) => progress.isLessonCompleted(l.id)).length;

    return AppCard(
      color: t.heroBg,
      border: false,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpace.s20),
      onTap: () => onOpen(course.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text(l10n.dsContinueLabel, style: text.labelSmall?.copyWith(color: t.heroMuted)),
          const Spacer(),
          if (next != null) ...[
            Icon(lessonTypeIcon(next.type), size: 14, color: t.heroMuted),
            const SizedBox(width: 4),
            Text(
              [lessonTypeLabel(l10n, next.type), if (next.estimatedMinutes != null) l10n.dsMinutes(next.estimatedMinutes!)]
                  .join(' · '),
              style: text.labelMedium?.copyWith(color: t.heroMuted),
            ),
          ],
        ]),
        const SizedBox(height: 14),
        Text(course.title, style: text.titleLarge?.copyWith(color: t.heroFg)),
        if (next != null) ...[
          const SizedBox(height: 4),
          Text(next.title, style: text.bodyMedium?.copyWith(color: t.heroMuted)),
        ],
        if (next?.type == LessonType.video) _VideoResume(videoId: next!.refId),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(l10n.dsLessonsDone(done, lessons.length), style: text.bodySmall?.copyWith(color: t.heroMuted))),
          Text('${(progress.percentComplete * 100).round()}%', style: text.labelMedium?.copyWith(color: t.heroFg)),
        ]),
        const SizedBox(height: 6),
        ProgressLine(value: progress.percentComplete, color: t.goldSolid, trackColor: t.heroTrack),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: t.heroFg, foregroundColor: t.heroBg),
          onPressed: () => onOpen(course.id),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(l10n.dsContinueButton),
        ),
      ]),
    );
  }
}

/// Videoning oxirgi joyi (users/{uid}/video_progress) — boʻlmasa hech narsa koʻrsatmaydi.
class _VideoResume extends StatefulWidget {
  final String videoId;

  const _VideoResume({required this.videoId});

  @override
  State<_VideoResume> createState() => _VideoResumeState();
}

class _VideoResumeState extends State<_VideoResume> {
  Future<VideoWatchProgress>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_VideoResume old) {
    super.didUpdateWidget(old);
    if (old.videoId != widget.videoId) _load();
  }

  void _load() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _future = uid == null ? null : VideoProgressRemoteSource().get(uid, widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoWatchProgress>(
      future: _future,
      builder: (context, snap) {
        final p = snap.data;
        final at = p?.resumePositionSeconds;
        if (p == null || at == null) return const SizedBox.shrink();
        final t = context.tokens;
        final text = Theme.of(context).textTheme;
        final l10n = AppLocalizations.of(context)!;
        final leftMin = ((p.durationSeconds - at) / 60).ceil();
        return Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(AppSpace.s12),
          decoration: BoxDecoration(color: t.heroTrack, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Row(children: [
            IconTile(Icons.replay_rounded, background: t.heroFg, foreground: t.heroBg, circle: true),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.dsResumeAt(formatClock(at)), style: text.titleSmall?.copyWith(color: t.heroFg)),
                Text(l10n.dsResumeRemaining(leftMin), style: text.bodySmall?.copyWith(color: t.heroMuted)),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _StartCard extends StatelessWidget {
  final VoidCallback onBrowse;

  const _StartCard({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      color: t.heroBg,
      border: false,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpace.s20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l10n.dsStartFirstCourseTitle, style: text.titleLarge?.copyWith(color: t.heroFg)),
        const SizedBox(height: 4),
        Text(l10n.dsStartFirstCourseBody, style: text.bodyMedium?.copyWith(color: t.heroMuted)),
        const SizedBox(height: AppSpace.s16),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: t.heroFg, foregroundColor: t.heroBg),
          onPressed: onBrowse,
          child: Text(l10n.dsBrowseCourses),
        ),
      ]),
    );
  }
}

/// Seriya, XP va keyingi darajagacha progress.
class _StatsCard extends StatelessWidget {
  final AppUser user;

  const _StatsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final toNext = AppUser.xpToNextLevel(user.xp);
    final next = nextLevelId(user.xp);

    Widget metric(IconData icon, Color bg, Color fg, String value, String label) => Expanded(
          child: Row(children: [
            IconTile(icon, background: bg, foreground: fg),
            const SizedBox(width: 10),
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(label, style: text.bodySmall?.copyWith(color: t.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        );

    return AppCard(
      child: Column(children: [
        Row(children: [
          metric(Icons.local_fire_department_outlined, t.streakContainer, t.streakSolid,
              l10n.dsStreakDays(user.currentStreak), l10n.dsStreakLabel),
          Container(width: 1, height: 40, color: t.borderDefault, margin: const EdgeInsets.symmetric(horizontal: AppSpace.s12)),
          metric(Icons.bolt_rounded, t.goldContainer, t.goldSolid, l10n.dsXpValue('${user.xp}'), l10n.dsXpTotal),
        ]),
        const SizedBox(height: AppSpace.s16),
        Divider(color: t.borderDefault),
        const SizedBox(height: AppSpace.s16),
        Row(children: [
          Icon(Icons.workspace_premium_outlined, size: 16, color: t.brandPrimary),
          const SizedBox(width: 6),
          Text(levelName(l10n, user.level), style: text.titleSmall),
          const Spacer(),
          Text(next == null ? l10n.dsMaxLevel : l10n.dsXpToLevel(levelName(l10n, next), toNext),
              style: text.labelMedium?.copyWith(color: t.textSecondary)),
        ]),
        const SizedBox(height: AppSpace.s8),
        ProgressLine(value: AppUser.getLevelProgress(user.xp)),
      ]),
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const _RecommendedTile({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final mandatory = course.allLessons.any((l) => l.isRequired) && course.targetRole.isNotEmpty;
    return SizedBox(
      width: 232,
      child: AppCard(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconTile(courseIcon(course), background: t.brandContainer, foreground: t.brandPrimary),
            const Spacer(),
            if (course.hasCertificate)
              StatusBadge(l10n.dsCertificate, tone: BadgeTone.gold)
            else if (mandatory)
              StatusBadge(difficultyLabel(l10n, course.difficulty)),
          ]),
          const SizedBox(height: 10),
          Expanded(child: Text(course.title, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
          Text('${l10n.dsModules(course.modules.length)} · ${formatDuration(l10n, course.estimatedMinutes)}',
              style: text.bodySmall?.copyWith(color: t.textSecondary)),
        ]),
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  final NewsEntity news;

  const _NewsTile({required this.news});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: () {
        final uri = Uri.tryParse(news.url);
        if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Row(children: [
        IconTile(Icons.campaign_outlined, background: t.bgSubtle, foreground: t.textSecondary),
        const SizedBox(width: AppSpace.s12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(news.title, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('${l10n.dsAnnouncements} · ${news.source}', style: text.bodySmall?.copyWith(color: t.textSecondary)),
          ]),
        ),
        Icon(Icons.chevron_right_rounded, color: t.textTertiary),
      ]),
    );
  }
}
