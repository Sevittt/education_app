import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sud_system.dart';
import '../../services/systems_service.dart';
import 'package:sud_qollanma/features/library/data/models/article_model.dart';
import 'package:sud_qollanma/features/library/data/models/video_model.dart';
import '../knowledge_base/article_detail_screen.dart';
import '../resource/video_player_screen.dart';
import '../../l10n/app_localizations.dart';

class SystemDetailScreen extends StatefulWidget {
  final SudSystem system;

  const SystemDetailScreen({super.key, required this.system});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  final SystemsService _service = SystemsService();
  Map<String, dynamic> _content = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final content = await _service.getSystemContent(widget.system.id);
    if (mounted) {
      setState(() {
        _content = content;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(widget.system.fullUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorCouldNotOpenLink)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.system.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildQuickLinks(),
                  const SizedBox(height: 24),
                  if (_content['articles'] != null && (_content['articles'] as List).isNotEmpty)
                    _buildSection(l10n.resourceTabArticles, _content['articles']),
                  if (_content['videos'] != null && (_content['videos'] as List).isNotEmpty)
                    _buildSection(l10n.resourceTabVideos, _content['videos']),
                  if (_content['faqs'] != null && (_content['faqs'] as List).isNotEmpty)
                    _buildSection(l10n.faqTitle, _content['faqs']),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _launchUrl,
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.loginWelcomeTitle), // Using generic login welcome title for now
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            image: widget.system.logoUrl != null
                ? DecorationImage(
                    image: NetworkImage(widget.system.logoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.system.logoUrl == null
              ? const Icon(Icons.computer, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.system.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(widget.system.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(SystemStatus status) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    switch (status) {
      case SystemStatus.active:
        color = Colors.green;
        break;
      case SystemStatus.maintenance:
        color = Colors.orange;
        break;
      case SystemStatus.deprecated:
        color = Colors.grey;
        break;
      case SystemStatus.offline:
        color = Colors.red;
        break;
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            status.getDisplayName(l10n),
            style: TextStyle(color: color, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            widget.system.category.getDisplayName(l10n),
            style: const TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.descriptionLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.system.description,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQuickLinks() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        if (widget.system.loginGuideId != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _navigateToArticle(widget.system.loginGuideId!),
              icon: const Icon(Icons.article_outlined),
              label: Text(l10n.loginGuideIdLabel),
            ),
          ),
        if (widget.system.loginGuideId != null && widget.system.videoGuideId != null)
          const SizedBox(width: 16),
        if (widget.system.videoGuideId != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _navigateToVideo(widget.system.videoGuideId!),
              icon: const Icon(Icons.play_circle_outline),
              label: Text(l10n.videoGuideIdLabel),
            ),
          ),
      ],
    );
  }

  Future<void> _navigateToArticle(String articleId) async {
    // Check if article is already in loaded content
    final articles = _content['articles'] as List?;
    Map<String, dynamic>? articleData;
    
    if (articles != null) {
      try {
        articleData = articles.firstWhere((a) => a['id'] == articleId);
      } catch (_) {}
    }

    if (articleData != null) {
      final article = ArticleModel.fromMap(articleData, articleId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(articleEntity: article),
        ),
      );
    } else {
      // Fetch if not found
      // Note: Ideally we should inject KnowledgeBaseService, but for now we'll create it
      // or just show a message if not found in the list (assuming all related content is fetched)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorResourceNotFound)),
      );
    }
  }

  Future<void> _navigateToVideo(String videoId) async {
    final videos = _content['videos'] as List?;
    Map<String, dynamic>? videoData;

    if (videos != null) {
      try {
        videoData = videos.firstWhere((v) => v['id'] == videoId);
      } catch (_) {}
    }

    if (videoData != null) {
      final video = VideoModel.fromMap(videoData, videoId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoEntity: video),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorVideoNotFound)),
      );
    }
  }

  Widget _buildSection(String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                title == 'Videolar' ? Icons.play_circle_outline : Icons.article_outlined,
                color: Colors.blue,
              ),
              title: Text(item['title'] ?? item['question'] ?? ''),
              subtitle: item['description'] != null 
                  ? Text(
                      item['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () {
                if (title == 'Qo\'llanmalar') {
                  final article = ArticleModel.fromMap(item, item['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(articleEntity: article),
                    ),
                  );
                } else if (title == 'Videolar') {
                  final video = VideoModel.fromMap(item, item['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(videoEntity: video),
                    ),
                  );
                } else if (title == 'Ko\'p so\'raladigan savollar') {
                  _showFAQDialog(item['question'], item['answer']);
                }
              },
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showFAQDialog(String question, String answer) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question),
        content: SingleChildScrollView(
          child: Text(answer),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeAction),
          ),
        ],
      ),
    );
  }
}
