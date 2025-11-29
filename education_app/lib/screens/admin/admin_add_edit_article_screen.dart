import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (_pdfUrl != null) {
      _pdfFileName = 'Mavjud PDF fayl';
    }
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
          const SnackBar(content: Text('Maqola saqlandi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'Yangi Maqola' : 'Maqolani Tahrirlash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveArticle,
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
                      decoration: const InputDecoration(
                        labelText: 'Sarlavha',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Sarlavha kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ArticleCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategoriya',
                        border: OutlineInputBorder(),
                      ),
                      items: ArticleCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text('${category.icon} ${category.displayName}'),
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
                      decoration: const InputDecoration(
                        labelText: 'Mazmuni (Markdown)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Mazmun kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Teglar (vergul bilan ajrating)',
                        border: OutlineInputBorder(),
                        hintText: 'masalan: sud, qonun, kodeks',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: Text(_pdfFileName ?? 'PDF fayl tanlanmagan'),
                        trailing: IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed: _pickPdf,
                          tooltip: 'PDF yuklash',
                        ),
                      ),
                    ),
                    if (_pdfUrl != null && _selectedPdfFile == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Joriy fayl: $_pdfUrl',
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
