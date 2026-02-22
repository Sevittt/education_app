import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/shared/layouts/responsive_layout.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/presentation/screens/article_detail_screen.dart';

class ArticlesTab extends StatefulWidget {
  const ArticlesTab({super.key});

  @override
  State<ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<ArticlesTab> {
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  List<ArticleEntity> _searchResults = [];

  // Article categories as strings
  static const List<String> _categories = [
    'general',
    'procedure',
    'law',
    'faq',
  ];

  @override
  void initState() {
    super.initState();
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

  void _onSearch(String query) {
    final provider = context.read<LibraryProvider>();
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (_isSearching) {
      final allArticles = provider.articles;
      _searchResults = allArticles.where((article) {
        final titleMatch = article.title.toLowerCase().contains(query.toLowerCase());
        final descMatch = article.description.toLowerCase().contains(query.toLowerCase());
        final contentMatch = article.content.toLowerCase().contains(query.toLowerCase());
        return titleMatch || descMatch || contentMatch;
      }).toList();
      setState(() {});
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
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(
          child: _isSearching ? _buildSearchResults() : _buildArticleList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchArticlesPlaceholder,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: _onSearch,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, l10n.filterAll),
          ..._categories.map((category) {
            return _buildCategoryChip(category, _getCategoryDisplayName(category, l10n));
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _onCategorySelected(selected ? category : null);
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noResultsFound,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobileBody: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return _buildArticleCard(_searchResults[index]);
        },
      ),
      desktopBody: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return _buildArticleCard(_searchResults[index]);
        },
      ),
    );
  }

  Widget _buildArticleList() {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.articles.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return Center(child: Text(l10n.errorGeneric(provider.error ?? 'Unknown')));
        }

        List<ArticleEntity> articles = provider.articles;
        if (_selectedCategory != null) {
          articles = articles.where((a) => a.category == _selectedCategory).toList();
        }

        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.noArticlesAvailable,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ResponsiveLayout(
          mobileBody: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _buildArticleCard(articles[index]);
            },
          ),
          desktopBody: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _buildArticleCard(articles[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(ArticleEntity article) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(articleEntity: article),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryDisplayName(article.category, l10n),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (article.isPinned)
                    Icon(Icons.push_pin, size: 16, color: Colors.orange.shade700),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: TextStyle(color: Colors.grey.shade600),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    article.authorName,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${article.views}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${article.helpful}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
