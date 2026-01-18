import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../domain/entities/faq_entity.dart';
import '../providers/faq_notifier.dart';

class FaqListScreen extends StatefulWidget {
  const FaqListScreen({super.key});

  @override
  State<FaqListScreen> createState() => _FaqListScreenState();
}

class _FaqListScreenState extends State<FaqListScreen> {
  final TextEditingController _searchController = TextEditingController();
  FaqCategory? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    // Initial fetch handled by StreamBuilder or Provider logic if needed, 
    // but here we'll rely on the Notifier's stream getters.
    // However, the Notifier exposes streams, so we can use StreamBuilder directly.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifier = Provider.of<FaqNotifier>(context, listen: false);

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
            child: StreamBuilder<List<FaqEntity>>(
              stream: _selectedCategory != null
                  ? notifier.getFaqsByCategory(_selectedCategory!)
                  : notifier.faqsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final faqs = snapshot.data ?? [];
                final filteredFaqs = _filterFaqs(faqs);

                if (filteredFaqs.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredFaqs.length,
                  itemBuilder: (context, index) {
                    return _buildFaqTile(filteredFaqs[index], l10n, notifier);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<FaqEntity> _filterFaqs(List<FaqEntity> faqs) {
    if (_searchController.text.isEmpty) {
      return faqs;
    }
    final query = _searchController.text.toLowerCase();
    return faqs.where((faq) {
      return faq.question.toLowerCase().contains(query) ||
             faq.answer.toLowerCase().contains(query);
    }).toList();
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

  String _getCategoryName(FaqCategory category, AppLocalizations? l10n) {
    switch (category) {
      case FaqCategory.login:
        return l10n?.faqCategoryLogin ?? 'Login Issues';
      case FaqCategory.password:
        return l10n?.faqCategoryPassword ?? 'Password Issues';
      case FaqCategory.upload:
        return l10n?.faqCategoryUpload ?? 'File Upload';
      case FaqCategory.access:
        return l10n?.faqCategoryAccess ?? 'Access Rights';
      case FaqCategory.general:
        return l10n?.faqCategoryGeneral ?? 'General Questions';
      case FaqCategory.technical:
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
                });
              }
            },
          ),
          const SizedBox(width: 8),
          ...FaqCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${category.icon} ${_getCategoryName(category, l10n)}'),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFaqTile(FaqEntity faq, AppLocalizations? l10n, FaqNotifier notifier) {
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
                onPressed: () => notifier.markAsHelpful(faq.id),
                tooltip: 'Yes',
              ),
              IconButton(
                icon: const Icon(Icons.thumb_down_outlined, size: 20),
                onPressed: () => notifier.unmarkAsHelpful(faq.id),
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
