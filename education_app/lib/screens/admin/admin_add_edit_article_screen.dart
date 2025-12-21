import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/knowledge_article.dart';
import '../../services/knowledge_base_service.dart';

class AdminAddEditArticleScreen extends StatefulWidget {
  final KnowledgeArticle? article;

  const AdminAddEditArticleScreen({super.key, this.article});

  @override
  State<AdminAddEditArticleScreen> createState() => _AdminAddEditArticleScreenState();
}

class _AdminAddEditArticleScreenState extends State<AdminAddEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KnowledgeBaseService();
  
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  ArticleCategory _selectedCategory = ArticleCategory.general;
  
  bool _isLoading = false;
  String? _pdfUrl;
  String? _pdfFileName;
  File? _selectedPdfFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(text: widget.article?.content ?? '');
    _tagsController = TextEditingController(text: widget.article?.tags.join(', ') ?? '');
    _selectedCategory = widget.article?.category ?? ArticleCategory.general;
    _pdfUrl = widget.article?.pdfUrl;
    // Note: We can't access l10n here in initState easily without context, 
    // but we can set _pdfFileName in build or use a boolean flag.
    // For simplicity, we'll handle the display logic in build.
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedPdfFile = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      String? pdfUrl = _pdfUrl;
      
      // Upload PDF if selected
      if (_selectedPdfFile != null) {
        pdfUrl = await _service.uploadPDF(_selectedPdfFile!, 'temp_${DateTime.now().millisecondsSinceEpoch}');
      }

      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final user = FirebaseAuth.instance.currentUser;
      final authorId = user?.uid ?? 'admin';
      final authorName = user?.displayName ?? 'Admin';

      final article = KnowledgeArticle(
        id: widget.article?.id ?? '',
        title: _titleController.text,
        description: _contentController.text.length > 100 
            ? '${_contentController.text.substring(0, 100)}...' 
            : _contentController.text,
        content: _contentController.text,
        pdfUrl: pdfUrl,
        category: _selectedCategory,
        tags: tags,
        authorId: authorId,
        authorName: authorName,
        createdAt: widget.article?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      if (widget.article == null) {
        // Create new
        await _service.createArticle(article);
      } else {
        // Update existing
        await _service.updateArticle(widget.article!.id, article);
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
    
    // Determine PDF file name display
    String pdfDisplayText = l10n.noPdfSelected;
    if (_pdfFileName != null) {
      pdfDisplayText = _pdfFileName!;
    } else if (_pdfUrl != null) {
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
                    DropdownButtonFormField<ArticleCategory>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: ArticleCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text('${category.icon} ${category.getDisplayName(l10n)}'),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed: _pickPdf,
                          tooltip: l10n.uploadPdfTooltip,
                        ),
                      ),
                    ),
                    if (_pdfUrl != null && _selectedPdfFile == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.currentFileLabel(_pdfUrl!),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
