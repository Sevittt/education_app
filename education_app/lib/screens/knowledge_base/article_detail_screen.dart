import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/gamification_service.dart';
import '../../services/xapi_service.dart';
import '../../models/xapi/xapi_statement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.articleEntity,
  });

  final ArticleEntity articleEntity;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _hasVoted = false;
  late int _currentHelpfulCount;
  final ScrollController _scrollController = ScrollController();
  bool _pointsAwarded = false;

  // Helper getters to abstract data source
  String get _articleId => widget.articleEntity.id;
  String get _articleTitle => widget.articleEntity.title;
  String get _articleDescription => widget.articleEntity.description;
  String get _articleContent => widget.articleEntity.content;
  String get _authorName => widget.articleEntity.authorName;
  String get _category => widget.articleEntity.category;
  String? get _pdfUrl => widget.articleEntity.pdfUrl;
  int get _initialHelpful => widget.articleEntity.helpful;
  List<String> get _tags => widget.articleEntity.tags;
  DateTime get _createdAt => widget.articleEntity.createdAt;

  String _getCategoryDisplayName(String category) {
    // Ensure l10n is available, if context is not valid yet, return category
    if (!mounted) return category;

    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'general':
        return l10n.articleCategoryGeneral;
      case 'procedure':
        return l10n.articleCategoryProcedure;
      case 'law':
        return l10n.articleCategoryLaw;
      case 'faq':
        return l10n.articleCategoryFaq;
      default:
        return category;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentHelpfulCount = _initialHelpful;
    // Increment views via provider if using entity, else via service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().incrementArticleViews(_articleId);
    });
    _scrollController.addListener(_onScroll);

    // xAPI Tracking - Experienced (Viewed)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final actor = _getCurrentActor();
      final statement = XApiStatement(
        actor: actor,
        verb: XApiVerbs.experienced,
        object: XApiObject(
          id: _articleId,
          definition: {
            'type': 'http://adlnet.gov/expapi/activities/article',
            'name': {'en-US': _articleTitle},
          },
        ),
        timestamp: DateTime.now(),
      );
      await XApiService().recordStatement(statement);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pointsAwarded) return;

    // Check if scrolled to bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      _awardPointsForReading();
    }
  }

  Future<void> _awardPointsForReading() async {
    if (_pointsAwarded) return;

    // We no longer call awardPoints directly here.
    // Instead, we record the xAPI statement and let GamificationService handle the reward.

    // xAPI Tracking - Completed
    final actor = _getCurrentActor();
    final statement = XApiStatement(
      actor: actor,
      verb: XApiVerbs.completed,
      object: XApiObject(
        id: _articleId,
        definition: {
          'type': 'http://adlnet.gov/expapi/activities/article',
          'name': {'en-US': _articleTitle},
        },
      ),
      result: XApiResult(
        completion: true,
        success: true,
      ),
      timestamp: DateTime.now(),
    );

    _pointsAwarded = true;
    await XApiService().recordStatement(statement);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pointsEarned(5)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Helper to construct actor for direct statements (DEPRECATED: Use XApiService methods instead where possible)
  XApiActor _getCurrentActor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return XApiActor(
        mbox: 'mailto:${user.uid}@sudqollanma.uz',
        name: user.displayName ?? 'User ${user.uid.substring(0, 5)}',
      );
    } else {
      return XApiActor(
        mbox: 'mailto:guest@sudqollanma.uz',
        name: 'Guest User',
      );
    }
  }

  Future<void> _handleVote() async {
    if (_hasVoted) {
      // Undo vote
      await context.read<LibraryProvider>().decrementArticleHelpful(_articleId);
      setState(() {
        _hasVoted = false;
        _currentHelpfulCount--;
      });
    } else {
      // Vote
      await context.read<LibraryProvider>().incrementArticleHelpful(_articleId);
      setState(() {
        _hasVoted = true;
        _currentHelpfulCount++;
      });
    }
  }

  Future<void> _launchPdfUrl() async {
    if (_pdfUrl == null) return;

    final Uri url = Uri.parse(_pdfUrl!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPdfOpen)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_articleTitle),
        actions: [
          if (_pdfUrl != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'PDF yuklab olish',
              onPressed: _launchPdfUrl,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 32),
                  MarkdownBody(
                    data: _articleContent,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      h2: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      p: const TextStyle(fontSize: 16, height: 1.5),
                      blockquote: TextStyle(
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Colors.blue.shade200, width: 4)),
                      ),
                      blockquotePadding:
                          const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    ),
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final Uri url = Uri.parse(href);
                        if (!await launchUrl(url)) {
                          // Handle error
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildTags(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getCategoryDisplayName(_category),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _articleTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _articleDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(_createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (_tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags.map((tag) {
        return Chip(
          label: Text('#$tag'),
          backgroundColor: Colors.grey.shade100,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bu maqola foydali bo\'ldimi?',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                '$_currentHelpfulCount',
                style: TextStyle(
                  color: _hasVoted
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _handleVote,
                icon: Icon(
                  _hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: _hasVoted
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _hasVoted
                      ? Theme.of(context).primaryColor.withAlpha(26)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
