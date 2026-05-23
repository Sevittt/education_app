import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/presentation/screens/article_detail_screen.dart';
import 'package:sud_qollanma/features/library/presentation/screens/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SystemDetailScreen extends StatefulWidget {
  final SudSystemEntity system;

  const SystemDetailScreen({super.key, required this.system});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.system.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl(widget.system.url),
            tooltip: "Open system",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.computer,
              size: 48,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.system.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.system.status == SystemStatus.active
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.system.status == SystemStatus.active
                  ? l10n.sysStatusActive
                  : l10n.sysStatusMaintenance,
              style: TextStyle(
                color: widget.system.status == SystemStatus.active
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.system.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              if (widget.system.videoGuideUrl != null &&
                  widget.system.videoGuideUrl!.isNotEmpty)
                ActionChip(
                  avatar: const Icon(Icons.play_circle_fill, size: 20),
                  label: Text(l10n.labelVideoGuide),
                  onPressed: () => _openYoutubeOrUrl(
                      widget.system.videoGuideUrl!,
                      '${widget.system.name} - ${l10n.labelVideoGuide}'),
                ),
              if (widget.system.loginGuideUrl != null &&
                  widget.system.loginGuideUrl!.isNotEmpty)
                ActionChip(
                  avatar: const Icon(Icons.login, size: 20),
                  label: Text(l10n.labelLoginGuide),
                  onPressed: () => _openYoutubeOrUrl(
                      widget.system.loginGuideUrl!,
                      '${widget.system.name} - ${l10n.labelLoginGuide}'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final libraryProvider =
        Provider.of<LibraryProvider>(context, listen: false);

    return FutureBuilder(
      future: Future.wait([
        libraryProvider.getArticlesBySystem(widget.system.id),
        libraryProvider.getVideosBySystem(widget.system.id),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!
                  .errorGeneric(snapshot.error.toString())));
        }

        final articles = snapshot.data?[0] as List<ArticleEntity>? ?? [];
        final videos = snapshot.data?[1] as List<VideoEntity>? ?? [];

        if (articles.isEmpty && videos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "No data available",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (articles.isNotEmpty) ...[
                Text(
                  "Guides",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...articles.map((article) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.article, color: Colors.blue),
                        title: Text(article.title),
                        subtitle:
                            Text(article.category), // Fixed displayName to name
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleDetailScreen(articleEntity: article),
                            ),
                          );
                        },
                      ),
                    )),
                const SizedBox(height: 24),
              ],
              if (videos.isNotEmpty) ...[
                Text(
                  "Videos",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...videos.map((video) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading:
                            const Icon(Icons.video_library, color: Colors.red),
                        title: Text(video.title),
                        subtitle: Text(video.authorName),
                        trailing: const Icon(Icons.play_arrow, size: 20),
                        onTap: () async {
                          if (video.youtubeId != null && video.youtubeId!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerScreen(videoEntity: video),
                              ),
                            );
                          } else if (video.videoUrl != null && video.videoUrl!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerScreen(videoEntity: video),
                              ),
                            );
                          }
                        },
                      ),
                    )),
              ],
            ],
          ),
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
        // Not a YouTube link, assume it's a direct native video link if it's http
        if (urlString.startsWith('http')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoEntity: VideoEntity(
                  id: 'sys_${widget.system.id}_native',
                  title: title,
                  description: widget.system.description,
                  videoUrl: urlString,  // Set videoUrl instead of youtubeId
                  durationSeconds: 0,
                  category: 'system_guide',
                  systemId: widget.system.id,
                  thumbnailUrl: '', // Provide empty or placeholder for native fallback
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
                  AppLocalizations.of(context)!.couldNotLaunchUrl(urlString))),
        );
      }
    }
  }
}
