import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';

class AdminAddEditArticleScreen extends StatefulWidget {
  final ArticleEntity? article;

  const AdminAddEditArticleScreen({super.key, this.article});

  @override
  State<AdminAddEditArticleScreen> createState() => _AdminAddEditArticleScreenState();
}

class _AdminAddEditArticleScreenState extends State<AdminAddEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  String _selectedCategory = 'general';
  
  bool _isLoading = false;
  String? _pdfUrl;

  // Article categories
  static const List<String> _categories = [
    'general',
    'procedure',
    'law',
    'faq',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(text: widget.article?.content ?? '');
    _tagsController = TextEditingController(text: widget.article?.tags.join(', ') ?? '');
    _selectedCategory = widget.article?.category ?? 'general';
    _pdfUrl = widget.article?.pdfUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _getCategoryDisplayName(String category) {
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

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'general':
        return '📄';
      case 'procedure':
        return '📋';
      case 'law':
        return '⚖️';
      case 'faq':
        return '❓';
      default:
        return '📄';
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<LibraryProvider>();

    try {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final user = FirebaseAuth.instance.currentUser;
      final authorId = user?.uid ?? 'admin';
      final authorName = user?.displayName ?? 'Admin';

      final article = ArticleEntity(
        id: widget.article?.id ?? '',
        title: _titleController.text,
        description: _contentController.text.length > 100 
            ? '${_contentController.text.substring(0, 100)}...' 
            : _contentController.text,
        content: _contentController.text,
        pdfUrl: _pdfUrl,
        category: _selectedCategory,
        systemId: widget.article?.systemId,
        tags: tags,
        authorId: authorId,
        authorName: authorName,
        views: widget.article?.views ?? 0,
        helpful: widget.article?.helpful ?? 0,
        createdAt: widget.article?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: widget.article?.isPinned ?? false,
      );

      if (widget.article == null) {
        await provider.createArticle(article);
      } else {
        await provider.updateArticle(widget.article!.id, article);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.articleSavedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    String pdfDisplayText = l10n.noPdfSelected;
    if (_pdfUrl != null) {
      pdfDisplayText = l10n.existingPdfFile;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? l10n.addArticleTitle : l10n.editArticleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveArticle,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.titleLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.titleRequired : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text('${_getCategoryIcon(category)} ${_getCategoryDisplayName(category)}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: l10n.contentLabel,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.contentRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: l10n.tagsLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.tagsHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: Text(pdfDisplayText),
                        subtitle: _pdfUrl != null 
                            ? Text(AppLocalizations.of(context)!.labelPdfAvailable, style: TextStyle(color: Colors.green.shade600))
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
