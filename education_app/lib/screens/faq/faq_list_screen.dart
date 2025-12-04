import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/faq.dart';
import '../../services/faq_service.dart';

class FAQListScreen extends StatefulWidget {
  const FAQListScreen({super.key});

  @override
  State<FAQListScreen> createState() => _FAQListScreenState();
}

class _FAQListScreenState extends State<FAQListScreen> {
  final FAQService _service = FAQService();
  final TextEditingController _searchController = TextEditingController();
  FAQCategory? _selectedCategory;
  List<FAQ> _faqs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFAQs() async {
    setState(() => _isLoading = true);
    
    Stream<List<FAQ>> stream;
    if (_selectedCategory != null) {
      stream = _service.getFAQsByCategory(_selectedCategory!);
    } else {
      stream = _service.getAllFAQs();
    }

    stream.listen((faqs) {
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _isLoading = false;
        });
      }
    });
  }

  List<FAQ> get _filteredFAQs {
    if (_searchController.text.isEmpty) {
      return _faqs;
    }
    final query = _searchController.text.toLowerCase();
    return _faqs.where((faq) {
      return faq.question.toLowerCase().contains(query) ||
             faq.answer.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.faqTitle ?? 'Frequently Asked Questions'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          _buildCategoryFilters(l10n),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFAQs.isEmpty
                    ? _buildEmptyState(l10n)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredFAQs.length,
                        itemBuilder: (context, index) {
                          return _buildFAQTile(_filteredFAQs[index], l10n);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n?.searchHelp ?? 'Search help...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  String _getCategoryName(FAQCategory category, AppLocalizations? l10n) {
    switch (category) {
      case FAQCategory.login:
        return l10n?.faqCategoryLogin ?? 'Login Issues';
      case FAQCategory.password:
        return l10n?.faqCategoryPassword ?? 'Password Issues';
      case FAQCategory.upload:
        return l10n?.faqCategoryUpload ?? 'File Upload';
      case FAQCategory.access:
        return l10n?.faqCategoryAccess ?? 'Access Rights';
      case FAQCategory.general:
        return l10n?.faqCategoryGeneral ?? 'General Questions';
      case FAQCategory.technical:
        return l10n?.faqCategoryTechnical ?? 'Technical Issues';
    }
  }

  Widget _buildCategoryFilters(AppLocalizations? l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text(l10n?.allCategories ?? 'All Categories'),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategory = null;
                  _loadFAQs();
                });
              }
            },
          ),
          const SizedBox(width: 8),
          ...FAQCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${category.icon} ${_getCategoryName(category, l10n)}'),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                    _loadFAQs();
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFAQTile(FAQ faq, AppLocalizations? l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _getCategoryName(faq.category, l10n),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          MarkdownBody(
            data: faq.answer,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n?.helpfulFeedback ?? 'Was this helpful?',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.thumb_up_outlined, size: 20),
                onPressed: () => _service.incrementHelpfulCount(faq.id),
                tooltip: 'Yes',
              ),
              IconButton(
                icon: const Icon(Icons.thumb_down_outlined, size: 20),
                onPressed: () => _service.decrementHelpfulCount(faq.id),
                tooltip: 'No',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n?.noArticlesFound ?? 'No FAQs found',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
