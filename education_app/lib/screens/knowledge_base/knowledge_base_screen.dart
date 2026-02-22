import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';

import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'article_detail_screen.dart';

/// Refactored Knowledge Base Screen using LibraryProvider.
class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'all',
    'beginner',
    'akt',
    'system',
    'auth',
    'general'
  ];

  String? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  List<ArticleEntity> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Fetch articles on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().watchArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryDisplayName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'all':
        return l10n.allCategories;
      case 'beginner':
        return l10n.catNewEmployees;
      case 'akt':
        return l10n.catIctSpecialists;
      case 'system':
        return l10n.catSystems;
      case 'auth':
        return l10n.catAuth;
      case 'general':
        return l10n.catGeneral;
      default:
        return category;
    }
  }

  void _onSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (_isSearching) {
      final results =
          await context.read<LibraryProvider>().searchArticles(query);
      setState(() {
        _searchResults = results;
      });
    }
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      if (_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _isSearching = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.featureKnowledgeBase),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          _buildCategoryFilter(l10n),
          Expanded(
            child: _isSearching
                ? _buildSearchResults(l10n)
                : _buildArticleList(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchArticlesPlaceholder,
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        onChanged: _onSearch,
      ),
    );
  }

  Widget _buildCategoryFilter(AppLocalizations l10n) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _categories.map((category) {
          return _buildCategoryChip(
            category == 'all' ? null : category,
            _getCategoryDisplayName(category, l10n),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _onCategorySelected(selected ? category : null);
        },
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : colorScheme.outline,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildArticleCard(_searchResults[index], l10n);
      },
    );
  }

  Widget _buildArticleList(AppLocalizations l10n) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.articles.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
              child: Text(l10n.errorGeneric(provider.error ?? 'Unknown')));
        }

        final allArticles = provider.articles;
        final articles = _selectedCategory == null
            ? allArticles
            : allArticles
                .where((a) => a.category == _selectedCategory)
                .toList();

        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_outlined,
                    size: 64, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  l10n.noArticlesAvailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return _buildArticleCard(articles[index], l10n);
          },
        );
      },
    );
  }

  Widget _buildArticleCard(ArticleEntity article, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Increment views
          context.read<LibraryProvider>().incrementArticleViews(article.id);
          // Navigate to detail screen (using legacy model for now)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                articleEntity: article,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryDisplayName(article.category, l10n),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (article.isPinned)
                    Icon(Icons.push_pin,
                        size: 16, color: colorScheme.secondary),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    article.authorName,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                  ),
                  const Spacer(),
                  Icon(Icons.remove_red_eye_outlined,
                      size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${article.views}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.thumb_up_outlined,
                      size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${article.helpful}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
