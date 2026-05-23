import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

/// Auto-scrolling news carousel with live dots indicator.
/// Mobile: horizontal PageView that auto-advances every [autoScrollDuration].
/// Desktop: vertical scrollable list.
class AutoScrollingNewsSection extends StatefulWidget {
  final NewsNotifier newsNotifier;
  final bool isDesktop;
  final Future<void> Function(BuildContext ctx, String url) launchUrl;

  const AutoScrollingNewsSection({
    super.key,
    required this.newsNotifier,
    required this.isDesktop,
    required this.launchUrl,
  });

  @override
  State<AutoScrollingNewsSection> createState() =>
      _AutoScrollingNewsSectionState();
}

class _AutoScrollingNewsSectionState extends State<AutoScrollingNewsSection> {
  late final PageController _pageCtrl;
  late Stream<List<NewsEntity>> _newsStream;
  Timer? _timer;
  int _currentPage = 0;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.9);
    _newsStream = widget.newsNotifier.newsStream;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startTimer(int count) {
    if (count <= 1) {
      _timer?.cancel();
      return;
    }
    if (_timer?.isActive ?? false) return;

    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      
      final next = (_currentPage + 1) % count;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_justice_scales.jpg'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Section header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.amber, AppColors.amberLight]
                        : [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.latestNewsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Content ──
        StreamBuilder<List<NewsEntity>>(
          stream: _newsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingShimmer(isDark: isDark);
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n.errorLoadingNews(snapshot.error.toString()),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l10n.noNewsAvailable));
            }

            final newsList = snapshot.data!;
            _itemCount = newsList.length;

            if (widget.isDesktop) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: newsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) =>
                    _NewsCard(item: newsList[i], isDesktop: true, launchUrl: widget.launchUrl),
              );
            }

            // Start timer if not already running
            _startTimer(_itemCount);

            return Column(
              children: [
                SizedBox(
                  height: 230,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: newsList.length,
                    onPageChanged: (i) {
                      setState(() => _currentPage = i);
                    },
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _NewsCard(
                          item: newsList[i],
                          isDesktop: false,
                          launchUrl: widget.launchUrl),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    newsList.length > 8 ? 8 : newsList.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentPage % (newsList.length > 8 ? 8 : newsList.length) ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == _currentPage % (newsList.length > 8 ? 8 : newsList.length)
                            ? (isDark ? AppColors.amber : AppColors.primary)
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    ),
                  ),
                ),
                ],
              );
            },
          ),
        ],
    ),
  );
  }
}



// ── Single news card ──────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final NewsEntity item;
  final bool isDesktop;
  final Future<void> Function(BuildContext ctx, String url) launchUrl;

  const _NewsCard({
    required this.item,
    required this.isDesktop,
    required this.launchUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return GestureDetector(
      onTap: () => launchUrl(context, item.url),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: isDesktop
            ? _DesktopLayout(item: item, l10n: l10n, theme: theme, isDark: isDark)
            : _MobileLayout(item: item, l10n: l10n, theme: theme, isDark: isDark),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final NewsEntity item;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isDark;

  const _MobileLayout(
      {required this.item,
      required this.l10n,
      required this.theme,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          height: 105,
          width: double.infinity,
          color: isDark ? AppColors.surfaceElevated : AppColors.backgroundLight,
          child: Center(
            child: Icon(Icons.newspaper_rounded,
                size: 32,
                color: isDark ? AppColors.amber.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.4)),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.source,
                        style: TextStyle(
                          color: isDark ? AppColors.amber : AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.publicationDate != null)
                      Text(
                        MaterialLocalizations.of(context)
                            .formatShortDate(item.publicationDate!),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final NewsEntity item;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isDark;

  const _DesktopLayout(
      {required this.item,
      required this.l10n,
      required this.theme,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Container(
            width: 80,
            height: 110,
            color: isDark ? AppColors.surfaceElevated : AppColors.backgroundLight,
            child: Icon(Icons.newspaper_rounded,
                size: 28,
                color: isDark ? AppColors.amber.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.4)),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.source,
                        style: TextStyle(
                          color: isDark ? AppColors.amber : AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.publicationDate != null)
                      Text(
                        MaterialLocalizations.of(context)
                            .formatShortDate(item.publicationDate!),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shimmer loading placeholder ───────────────────────────────────────────────
class _LoadingShimmer extends StatefulWidget {
  final bool isDark;
  const _LoadingShimmer({required this.isDark});

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: 210,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 240,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: (widget.isDark ? AppColors.surfaceDark : AppColors.borderLight)
                  .withValues(alpha: _anim.value),
            ),
          ),
        ),
      ),
    );
  }
}
