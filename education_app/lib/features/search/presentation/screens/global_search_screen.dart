import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/search_result_entity.dart';
import '../providers/search_notifier.dart';

// Feature dependencies for navigation
import '../../../library/presentation/screens/article_detail_screen.dart';
import '../../../library/presentation/screens/video_player_screen.dart';
import '../../../systems/presentation/screens/system_detail_screen.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../systems/presentation/providers/systems_notifier.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchNotifier>().search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<SearchNotifier>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGlassGradient : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Search Header ---
              _buildSearchHeader(theme, l10n),

              // --- Filter Chips ---
              if (notifier.results.isNotEmpty || notifier.lastQuery.isNotEmpty)
                _buildFilterChips(notifier, l10n),

              // --- Results Body ---
              Expanded(
                child: _buildBody(notifier, theme, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: 16,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: '${l10n.search}...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.7)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchNotifier>().clearResults();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {}); // Update clear button visibility
                  _onSearchChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(SearchNotifier notifier, AppLocalizations l10n) {
    final counts = notifier.typeCounts;
    final activeFilter = notifier.activeFilter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildChip(
              label: 'Barchasi',
              icon: Icons.apps,
              isSelected: activeFilter == null,
              count: notifier.results.length,
              onTap: () => notifier.setFilter(null),
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'Tizimlar',
              icon: Icons.computer,
              isSelected: activeFilter == SearchResultType.system,
              count: counts[SearchResultType.system] ?? 0,
              color: Colors.greenAccent,
              onTap: () => notifier.setFilter(SearchResultType.system),
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'Maqolalar',
              icon: Icons.article,
              isSelected: activeFilter == SearchResultType.article,
              count: counts[SearchResultType.article] ?? 0,
              color: Colors.blueAccent,
              onTap: () => notifier.setFilter(SearchResultType.article),
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'Videolar',
              icon: Icons.play_circle_fill,
              isSelected: activeFilter == SearchResultType.video,
              count: counts[SearchResultType.video] ?? 0,
              color: Colors.redAccent,
              onTap: () => notifier.setFilter(SearchResultType.video),
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'FAQ',
              icon: Icons.help_outline,
              isSelected: activeFilter == SearchResultType.faq,
              count: counts[SearchResultType.faq] ?? 0,
              color: Colors.orangeAccent,
              onTap: () => notifier.setFilter(SearchResultType.faq),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.white70),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchNotifier notifier, ThemeData theme, AppLocalizations l10n) {
    if (notifier.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (notifier.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'Xatolik yuz berdi',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => notifier.search(notifier.lastQuery),
              child: const Text('Qayta urinish', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (notifier.lastQuery.isEmpty) {
      return _buildEmptyPrompt(theme);
    }

    final directResults = notifier.directResults;
    final semanticResults = notifier.semanticResults;

    if (directResults.isEmpty && semanticResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              l10n.searchNoResults,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '"${notifier.lastQuery}" bo\'yicha natija topilmadi',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // --- Direct Results ---
        if (directResults.isNotEmpty) ...[
          _buildSectionHeader('🔍 Natijalar (${directResults.length})'),
          const SizedBox(height: 8),
          ...directResults.map((r) => _buildResultCard(r)),
        ],

        // --- Semantic Results ---
        if (semanticResults.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('📎 Bog\'liq materiallar (${semanticResults.length})'),
          const SizedBox(height: 8),
          ...semanticResults.map((r) => _buildResultCard(r, isSemantic: true)),
        ],
      ],
    );
  }

  Widget _buildEmptyPrompt(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore, size: 80, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            'Yagona Oyna',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tizimlar, maqolalar, videolar va\nFAQ — hammasini bir joydan toping',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildResultCard(SearchResultEntity result, {bool isSemantic = false}) {
    final config = _getTypeConfig(result.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: () => _navigateToDetail(result),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Type icon with colored circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(config.icon, color: config.color, size: 24),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: config.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            config.label,
                            style: TextStyle(
                              color: config.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSemantic) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '📎 Bog\'liq',
                              style: TextStyle(color: Colors.white54, fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Type Config Helper ---
  _TypeConfig _getTypeConfig(SearchResultType type) {
    switch (type) {
      case SearchResultType.system:
        return _TypeConfig(
          icon: Icons.computer_rounded,
          color: Colors.greenAccent,
          label: 'TIZIM',
        );
      case SearchResultType.article:
        return _TypeConfig(
          icon: Icons.article_rounded,
          color: Colors.blueAccent,
          label: 'MAQOLA',
        );
      case SearchResultType.video:
        return _TypeConfig(
          icon: Icons.play_circle_fill_rounded,
          color: Colors.redAccent,
          label: 'VIDEO',
        );
      case SearchResultType.faq:
        return _TypeConfig(
          icon: Icons.help_outline_rounded,
          color: Colors.orangeAccent,
          label: 'FAQ',
        );
    }
  }

  // --- Navigation ---
  void _navigateToDetail(SearchResultEntity result) async {
    switch (result.type) {
      case SearchResultType.article:
        final article = await context.read<LibraryProvider>().getArticleById(result.id);
        if (article != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(articleEntity: article),
            ),
          );
        }
        break;
      case SearchResultType.video:
        final video = await context.read<LibraryProvider>().getVideoById(result.id);
        if (video != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoEntity: video),
            ),
          );
        }
        break;
      case SearchResultType.system:
        final system = await context.read<SystemsNotifier>().getSystemById(result.id);
        if (system != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SystemDetailScreen(system: system),
            ),
          );
        }
        break;
      case SearchResultType.faq:
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(result.title),
              content: SingleChildScrollView(child: Text(result.description)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        break;
    }
  }
}

/// Helper class for type-specific visual config.
class _TypeConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _TypeConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}
