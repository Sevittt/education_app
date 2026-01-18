import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/presentation/screens/article_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class SystemDetailScreen extends StatefulWidget {
  final SudSystemEntity system;

  const SystemDetailScreen({super.key, required this.system});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.system.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl(widget.system.url),
            tooltip: "Open System",
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
              color: theme.primaryColor.withOpacity(0.1),
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
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.system.status == SystemStatus.active
                  ? "Active"
                  : "Maintenance",
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
              if (widget.system.videoGuideUrl != null && widget.system.videoGuideUrl!.isNotEmpty)
                ActionChip(
                  avatar: const Icon(Icons.play_circle_fill, size: 20),
                  label: const Text("Video Guide"),
                  onPressed: () => _launchUrl(widget.system.videoGuideUrl!),
                ),
              if (widget.system.loginGuideUrl != null && widget.system.loginGuideUrl!.isNotEmpty)
                ActionChip(
                  avatar: const Icon(Icons.login, size: 20),
                  label: const Text("Login Guide"),
                  onPressed: () => _launchUrl(widget.system.loginGuideUrl!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder(
      future: Future.wait([
        libraryProvider.getArticlesBySystem(widget.system.id),
        libraryProvider.getVideosBySystem(widget.system.id),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final articles = snapshot.data?[0] as List<ArticleEntity>? ?? [];
        final videos = snapshot.data?[1] as List<VideoEntity>? ?? [];

        if (articles.isEmpty && videos.isEmpty) {
          return Center(
            child: Padding(
                padding: const EdgeInsets.all(32.0),
              child: Text(
                "No Data Available",
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
                    subtitle: Text(article.category), // Fixed displayName to name
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailScreen(articleEntity: article),
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
                    leading: const Icon(Icons.video_library, color: Colors.red),
                    title: Text(video.title),
                    subtitle: Text(video.authorName),
                    trailing: const Icon(Icons.play_arrow, size: 20),
                    onTap: () async {
                      if (video.youtubeId.isNotEmpty) {
                         // Simple launch for now, or navigate to video player
                         await launchUrl(Uri.parse('https://youtu.be/${video.youtubeId}'));
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }
}
