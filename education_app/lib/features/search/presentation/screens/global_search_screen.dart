import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/search_result_entity.dart';
import '../providers/search_notifier.dart';

// Feature dependencies
import '../../../library/domain/entities/article_entity.dart';
import '../../../library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
// Screens for navigation
import '../../../library/presentation/screens/article_detail_screen.dart';
import '../../../library/presentation/screens/video_player_screen.dart';
import '../../../systems/presentation/screens/system_detail_screen.dart'; 

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
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
        });
        if (query.isNotEmpty) {
           context.read<SearchNotifier>().search(query);
        } else {
           context.read<SearchNotifier>().clearResults();
        }
      }
    });
  }

  Widget _buildResultSection(String title, List<SearchResultEntity> items) {
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

  Widget _buildResultItem(SearchResultEntity result) {
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

  void _navigateToDetail(SearchResultEntity result) {
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
              system: result.originalObject as SudSystemEntity,
            ),
          ),
        );
        break;
      case 'faq':
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
    final notifier = context.watch<SearchNotifier>();
    final results = notifier.results;
    
    final articles = results.where((r) => r.type == 'article').toList();
    final videos = results.where((r) => r.type == 'video').toList();
    final systems = results.where((r) => r.type == 'system').toList();
    final faqs = results.where((r) => r.type == 'faq').toList();

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
      body: notifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty && _query.isNotEmpty && !notifier.isLoading
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
