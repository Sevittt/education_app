import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/models/search_result.dart';
import 'package:sud_qollanma/services/global_search_service.dart';
import 'package:sud_qollanma/screens/knowledge_base/article_detail_screen.dart';
import 'package:sud_qollanma/screens/resource/video_player_screen.dart';
import 'package:sud_qollanma/screens/systems/system_detail_screen.dart'; // Import SystemDetailScreen
import 'package:sud_qollanma/features/library/domain/entities/article_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/models/sud_system.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final GlobalSearchService _searchService = GlobalSearchService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query != _query) {
        setState(() {
          _query = query;
          _isLoading = true;
        });
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    final results = await _searchService.searchAll(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  Widget _buildResultSection(String title, List<SearchResult> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...items.map((result) => _buildResultItem(result)),
        const Divider(),
      ],
    );
  }

  Widget _buildResultItem(SearchResult result) {
    IconData icon;
    Color iconColor;
    String subtitle = result.description;

    switch (result.type) {
      case 'article':
        icon = Icons.article;
        iconColor = Colors.blue;
        break;
      case 'video':
        icon = Icons.play_circle_fill;
        iconColor = Colors.red;
        break;
      case 'system':
        icon = Icons.computer;
        iconColor = Colors.green;
        break;
      case 'faq':
        icon = Icons.help;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.search;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        result.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        _navigateToDetail(result);
      },
    );
  }



  void _navigateToDetail(SearchResult result) {
    switch (result.type) {
      case 'article':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              articleEntity: result.originalObject as ArticleEntity,
            ),
          ),
        );
        break;
      case 'video':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoEntity: result.originalObject as VideoEntity,
            ),
          ),
        );
        break;
      case 'system':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SystemDetailScreen(
              system: result.originalObject as SudSystem,
            ),
          ),
        );
        break;
      case 'faq':
        // FAQs usually don't have a detail screen, maybe expand?
        // For now, just show content
         showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result.title),
            content: Text(result.description),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.actionOk))
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final articles = _results.where((r) => r.type == 'article').toList();
    final videos = _results.where((r) => r.type == 'video').toList();
    final systems = _results.where((r) => r.type == 'system').toList();
    final faqs = _results.where((r) => r.type == 'faq').toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Qidirish...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && _query.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.searchNoResults,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    _buildResultSection('📚 Maqolalar', articles),
                    _buildResultSection('📺 Videolar', videos),
                    _buildResultSection('💻 Tizimlar', systems),
                    _buildResultSection('❓ Savol-Javoblar', faqs),
                  ],
                ),
    );
  }
}
