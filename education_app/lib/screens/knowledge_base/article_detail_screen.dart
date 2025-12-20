import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/knowledge_article.dart';
import '../../services/knowledge_base_service.dart';
import '../../services/gamification_service.dart';
import '../../services/xapi_service.dart';
import '../../models/xapi/xapi_statement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';

class ArticleDetailScreen extends StatefulWidget {
  final KnowledgeArticle article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final KnowledgeBaseService _service = KnowledgeBaseService();
  bool _hasVoted = false;
  late int _currentHelpfulCount;
  final ScrollController _scrollController = ScrollController();
  bool _pointsAwarded = false;

  @override
  void initState() {
    super.initState();
    _currentHelpfulCount = widget.article.helpful;
    // Increment views when screen opens
    _service.incrementViews(widget.article.id);
    _scrollController.addListener(_onScroll);
    
    // xAPI Tracking - Experienced (Viewed)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       final actor = _getCurrentActor();
       final statement = XApiStatement(
         actor: actor,
         verb: XApiVerbs.experienced,
         object: XApiObject(
           id: widget.article.id,
           definition: {
             'type': 'http://adlnet.gov/expapi/activities/article',
             'name': {'en-US': widget.article.title},
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      _awardPointsForReading();
    }
  }

  Future<void> _awardPointsForReading() async {
    if (_pointsAwarded) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _pointsAwarded = true;
    
    // Award 5 points for reading an article
    await GamificationService().awardPoints(
      userId: userId, 
      points: 5, 
      actionType: 'article_read',
      description: 'Read article: ${widget.article.title}'
    );

    // xAPI Tracking - Completed
    final actor = _getCurrentActor();
    final statement = XApiStatement(
      actor: actor,
      verb: XApiVerbs.completed,
      object: XApiObject(
        id: widget.article.id, // e.g. "article_123" (Should technically be a URI)
        definition: {
          'type': 'http://adlnet.gov/expapi/activities/article',
          'name': {'en-US': widget.article.title},
        },
      ),
      result: XApiResult(
        completion: true,
        success: true,
      ),
      timestamp: DateTime.now(),
    );
    await XApiService().recordStatement(statement);

    if (mounted) {
       final l10n = AppLocalizations.of(context)!;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(l10n.pointsEarned(5))),
       );
    }
  }

  // Helper to construct actor for direct statements
  XApiActor _getCurrentActor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return XApiActor(
        mbox: 'mailto:${user.email ?? "no-email-${user.uid}@sudqollanma.uz"}',
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
      await _service.decrementHelpful(widget.article.id);
      setState(() {
        _hasVoted = false;
        _currentHelpfulCount--;
      });
    } else {
      // Vote
      await _service.incrementHelpful(widget.article.id);
      setState(() {
        _hasVoted = true;
        _currentHelpfulCount++;
      });
    }
  }

  Future<void> _launchPdfUrl() async {
    if (widget.article.pdfUrl == null) return;
    
    final Uri url = Uri.parse(widget.article.pdfUrl!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF faylni ochib bo\'lmadi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        actions: [
          if (widget.article.pdfUrl != null)
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
                    data: widget.article.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      p: const TextStyle(fontSize: 16, height: 1.5),
                      blockquote: TextStyle(
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.blue.shade200, width: 4)),
                      ),
                      blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
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
            widget.article.category.displayName,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.article.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.article.description,
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
                  widget.article.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(widget.article.createdAt.toDate()),
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
    if (widget.article.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.article.tags.map((tag) {
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
                  color: _hasVoted ? Theme.of(context).primaryColor : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _handleVote,
                icon: Icon(
                  _hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: _hasVoted ? Theme.of(context).primaryColor : Colors.grey.shade600,
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
