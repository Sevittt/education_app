import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/knowledge_article.dart';
import '../../services/knowledge_base_service.dart';
import 'article_detail_screen.dart';
import 'package:intl/intl.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final KnowledgeBaseService _service = KnowledgeBaseService();
  final TextEditingController _searchController = TextEditingController();
  
  ArticleCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  List<KnowledgeArticle> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (_isSearching) {
      final results = await _service.searchArticles(query);
      setState(() {
        _searchResults = results;
      });
    }
  }

  void _onCategorySelected(ArticleCategory? category) {
    setState(() {
      _selectedCategory = category;
      // Clear search when changing category to avoid confusion
      if (_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _isSearching = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilimlar Bazasi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildArticleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Maqolalarni qidirish...',
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
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, 'Barchasi'),
          ...ArticleCategory.values.map((category) {
            return _buildCategoryChip(category, category.displayName);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ArticleCategory? category, String label) {
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
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
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
              'Hech narsa topilmadi',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildArticleCard(_searchResults[index]);
      },
    );
  }

  Widget _buildArticleList() {
    Stream<List<KnowledgeArticle>> stream;
    if (_selectedCategory != null) {
      stream = _service.getArticlesByCategory(_selectedCategory!);
    } else {
      stream = _service.getAllArticles();
    }

    return StreamBuilder<List<KnowledgeArticle>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final articles = snapshot.data ?? [];

        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Maqolalar mavjud emas',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return _buildArticleCard(articles[index]);
          },
        );
      },
    );
  }

  Widget _buildArticleCard(KnowledgeArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
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
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.category.displayName,
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
