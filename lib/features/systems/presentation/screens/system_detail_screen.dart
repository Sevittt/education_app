import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import 'package:sud_qollanma/features/faq/presentation/providers/faq_notifier.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/presentation/screens/article_detail_screen.dart';
import 'package:sud_qollanma/features/library/presentation/screens/video_player_screen.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

class SystemDetailScreen extends StatefulWidget {
  final SudSystemEntity system;

  const SystemDetailScreen({super.key, required this.system});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  late Future<List<Object>> _contentFuture;

  @override
  void initState() {
    super.initState();
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    _contentFuture = Future.wait([
      libraryProvider.getArticlesBySystem(widget.system.id),
      libraryProvider.getVideosBySystem(widget.system.id),
    ]);
  }

  static String _cleanVideoTitle(VideoEntity video, String systemName) {
    final raw = video.title.trim();
    final lower = raw.toLowerCase();
    if (lower == 'tiket') {
      return '$systemName: Tiket tizimi bilan ishlash';
    }
    final recMatch = RegExp(r'screenrecorderproject(\d+)', caseSensitive: false).firstMatch(raw);
    if (recMatch != null) {
      final desc = video.description.trim();
      if (desc.isNotEmpty && !desc.toLowerCase().contains('screenrecorder')) {
        return desc;
      }
      return '$systemName — Amaliy video yoʻriqnoma #${recMatch.group(1)}';
    }
    return raw;
  }

  static String _cleanCategoryLabel(String rawCategory, AppLocalizations l10n) {
    switch (rawCategory.trim().toLowerCase()) {
      case 'system':
      case 'systems':
        return l10n.dsLessonTypeArticle;
      case 'dars':
        return 'Rasmiy modul qoʻllanmasi';
      case 'beginner':
        return l10n.courseFilterBeginner;
      case 'intermediate':
        return l10n.courseFilterIntermediate;
      case 'advanced':
        return l10n.courseFilterAdvanced;
      default:
        return rawCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s8),
              child: Row(
                children: [
                  CircleIconButton(
                    Icons.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  Expanded(
                    child: Text(
                      widget.system.name,
                      style: text.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  if (widget.system.url.trim().isNotEmpty)
                    CircleIconButton(
                      Icons.open_in_new_rounded,
                      tooltip: widget.system.url,
                      iconColor: t.brandPrimary,
                      onPressed: () => _launchUrl(widget.system.url),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderCard(context),
                        const SizedBox(height: AppSpace.s24),
                        _buildFaqSection(context),
                        _buildContent(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final isActive = widget.system.status == SystemStatus.active;

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.s24),
      radius: AppRadius.xl,
      child: Column(
        children: [
          IconTile(
            Icons.dns_rounded,
            size: 64,
            circle: true,
            background: t.brandContainer,
            foreground: t.brandPrimary,
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            widget.system.name,
            style: text.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.s8),
          StatusBadge(
            isActive ? l10n.sysStatusActive : l10n.sysStatusMaintenance,
            tone: isActive ? BadgeTone.success : BadgeTone.warning,
            icon: isActive ? Icons.check_circle_rounded : Icons.build_circle_outlined,
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            widget.system.description,
            style: text.bodyLarge?.copyWith(color: t.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.s20),
          Wrap(
            spacing: AppSpace.s12,
            runSpacing: AppSpace.s12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiChatScreen()),
                  );
                },
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: Text(l10n.dsAiAssistant),
              ),
              if (widget.system.url.trim().isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => _launchUrl(widget.system.url),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(widget.system.name),
                ),
              if (widget.system.videoGuideUrl != null &&
                  widget.system.videoGuideUrl!.isNotEmpty)
                ActionChip(
                  avatar: Icon(Icons.play_circle_fill, size: 18, color: t.brandPrimary),
                  label: Text(l10n.labelVideoGuide),
                  onPressed: () => _openYoutubeOrUrl(
                    widget.system.videoGuideUrl!,
                    '${widget.system.name} - ${l10n.labelVideoGuide}',
                  ),
                ),
              if (widget.system.loginGuideUrl != null &&
                  widget.system.loginGuideUrl!.isNotEmpty)
                ActionChip(
                  avatar: Icon(Icons.login_rounded, size: 18, color: t.brandPrimary),
                  label: Text(l10n.labelLoginGuide),
                  onPressed: () => _openYoutubeOrUrl(
                    widget.system.loginGuideUrl!,
                    '${widget.system.name} - ${l10n.labelLoginGuide}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final faqNotifier = context.read<FaqNotifier>();
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return StreamBuilder<List<FaqEntity>>(
      stream: faqNotifier.getFaqsBySystem(widget.system.id),
      builder: (context, snapshot) {
        final faqs = snapshot.data ?? const <FaqEntity>[];
        if (faqs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader('${l10n.helpCenterTitle} (${faqs.length})'),
              const SizedBox(height: AppSpace.s12),
              for (final faq in faqs.take(5)) ...[
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s16,
                        vertical: AppSpace.s4,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        AppSpace.s16,
                        0,
                        AppSpace.s16,
                        AppSpace.s16,
                      ),
                      leading: IconTile(
                        Icons.help_outline_rounded,
                        size: 36,
                        background: t.goldContainer,
                        foreground: t.goldSolid,
                      ),
                      title: Text(faq.question, style: text.titleSmall),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            faq.answer,
                            style: text.bodyMedium?.copyWith(color: t.textSecondary, height: 1.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s8),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return FutureBuilder<List<Object>>(
      future: _contentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpace.s32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(l10n.errorGeneric(snapshot.error.toString())),
          );
        }

        final articles = snapshot.data?[0] as List<ArticleEntity>? ?? [];
        final videos = snapshot.data?[1] as List<VideoEntity>? ?? [];

        if (articles.isEmpty && videos.isEmpty) {
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.s20),
              child: Text(
                l10n.noDiscussionsYet,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: t.textSecondary),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (articles.isNotEmpty) ...[
              SectionHeader('${l10n.searchFilterArticles} (${articles.length})'),
              const SizedBox(height: AppSpace.s12),
              for (final article in articles) ...[
                AppCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(articleEntity: article),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      IconTile(
                        Icons.article_outlined,
                        background: t.brandContainer,
                        foreground: t.brandPrimary,
                      ),
                      const SizedBox(width: AppSpace.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(article.title, style: text.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              _cleanCategoryLabel(article.category, l10n),
                              style: text.bodySmall?.copyWith(color: t.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: t.textTertiary),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s12),
              ],
              const SizedBox(height: AppSpace.s12),
            ],
            if (videos.isNotEmpty) ...[
              SectionHeader('${l10n.searchFilterVideos} (${videos.length})'),
              const SizedBox(height: AppSpace.s12),
              for (final video in videos) ...[
                AppCard(
                  onTap: () {
                    if ((video.youtubeId != null && video.youtubeId!.isNotEmpty) ||
                        (video.videoUrl != null && video.videoUrl!.isNotEmpty)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(videoEntity: video),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      IconTile(
                        Icons.smart_display_outlined,
                        background: t.dangerContainer,
                        foreground: t.dangerSolid,
                      ),
                      const SizedBox(width: AppSpace.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cleanVideoTitle(video, widget.system.name),
                              style: text.titleSmall,
                            ),
                            if (video.authorName.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                video.authorName,
                                style: text.bodySmall?.copyWith(color: t.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.play_arrow_rounded, color: t.brandPrimary),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s12),
              ],
            ],
          ],
        );
      },
    );
  }

  void _openYoutubeOrUrl(String urlString, String title) {
    try {
      final videoId = YoutubePlayer.convertUrlToId(urlString);
      if (videoId != null && videoId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoEntity: VideoEntity(
                id: 'sys_${widget.system.id}_$videoId',
                title: title,
                description: widget.system.description,
                youtubeId: videoId,
                durationSeconds: 0,
                category: 'system_guide',
                systemId: widget.system.id,
                thumbnailUrl: 'https://img.youtube.com/vi/$videoId/0.jpg',
                tags: [widget.system.id],
                authorId: 'system',
                authorName: 'Oliy sud',
                createdAt: DateTime.now(),
              ),
            ),
          ),
        );
      } else {
        if (urlString.startsWith('http')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoEntity: VideoEntity(
                  id: 'sys_${widget.system.id}_native',
                  title: title,
                  description: widget.system.description,
                  videoUrl: urlString,
                  durationSeconds: 0,
                  category: 'system_guide',
                  systemId: widget.system.id,
                  thumbnailUrl: '',
                  tags: [widget.system.id],
                  authorId: 'system',
                  authorName: 'Oliy sud',
                  createdAt: DateTime.now(),
                ),
              ),
            ),
          );
        } else {
          _launchUrl(urlString);
        }
      }
    } catch (e) {
      _launchUrl(urlString);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotLaunchUrl(urlString),
            ),
          ),
        );
      }
    }
  }
}
