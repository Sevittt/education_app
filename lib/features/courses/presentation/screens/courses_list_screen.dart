import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_card.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_list_skeleton.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/layouts/responsive_layout.dart';

/// Premium kurslar ro'yxati ekrani.
///
/// Xususiyatlar:
/// - Gradient AppBar
/// - Search bar
/// - Stats Banner (3 stat)
/// - Custom Tab Bar: Barchasi / Tugallangan / Davom etayotgan
/// - Difficulty filter chips
/// - Shimmer skeleton loading
/// - Pull-to-refresh
/// - AnimatedCourseCard (staggered)
class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen>
    with SingleTickerProviderStateMixin {
  // Tabs: 0=barchasi, 1=tugallangan, 2=davom etayotgan
  late final TabController _tabController;

  String _selectedDifficulty = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
      body: SelectionArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(isDark, innerBoxIsScrolled, l10n),
          ],
          body: Consumer<CourseProvider>(
            builder: (context, provider, _) {
              // Shimmer
              if (provider.isLoading && provider.courses.isEmpty) {
                return const CourseListSkeleton();
              }

              // Xato
              if (provider.error != null && provider.courses.isEmpty) {
                return _buildError(provider.error!, l10n);
              }

              // Stats
              final stats = _buildStats(provider);

              return Column(
                children: [
                  // ─── Stats Banner ───────────────────────────────────────
                  _StatsBanner(stats: stats, isDark: isDark),

                  // ─── Difficulty filter chips ─────────────────────────────
                  _buildFilterChips(isDark, l10n),

                  // ─── Tab Bar ─────────────────────────────────────────────
                  _CourseTabBar(controller: _tabController, isDark: isDark),

                  // ─── Tab Views ───────────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCourseList(_filterCourses(provider, 'all'), provider, isDark, l10n),
                        _buildCourseList(_filterCourses(provider, 'completed'), provider, isDark, l10n),
                        _buildCourseList(_filterCourses(provider, 'inProgress'), provider, isDark, l10n),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── SliverAppBar ─────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(bool isDark, bool innerBoxIsScrolled, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF0C1520), Color(0xFF152032)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.coursesTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            l10n.boostYourKnowledge,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  _SearchBar(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    hintText: l10n.searchCoursesHint,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Filter chips ─────────────────────────────────────────────────────────

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    return Container(
      color: isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _chip(l10n.courseFilterAll, 'all', isDark),
            const SizedBox(width: 8),
            _chip(l10n.courseFilterBeginner, 'beginner', isDark),
            const SizedBox(width: 8),
            _chip(l10n.courseFilterIntermediate, 'intermediate', isDark),
            const SizedBox(width: 8),
            _chip(l10n.courseFilterAdvanced, 'advanced', isDark),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, bool isDark) {
    final isSelected = _selectedDifficulty == value;
    final activeColor = isDark ? AppColors.amber : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (s) {
          if (s) setState(() => _selectedDifficulty = value);
        },
        selectedColor: activeColor.withValues(alpha: 0.18),
        backgroundColor: isDark ? AppColors.surfaceElevated : AppColors.surfaceLight,
        side: BorderSide(
          color: isSelected ? activeColor : Colors.transparent,
          width: 1.2,
        ),
        labelStyle: TextStyle(
          color: isSelected ? activeColor : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  // ─── Filterlash ───────────────────────────────────────────────────────────

  List<CourseEntity> _filterCourses(CourseProvider provider, String tab) {
    var list = provider.courses;

    // Tab filter
    if (tab == 'completed') {
      list = list.where((c) => provider.getUserProgress(c.id)?.isCompleted == true).toList();
    } else if (tab == 'inProgress') {
      list = list.where((c) {
        final p = provider.getUserProgress(c.id);
        return p != null && !p.isNotStarted && !p.isCompleted;
      }).toList();
    }

    // Difficulty filter
    if (_selectedDifficulty != 'all') {
      list = list.where((c) => c.difficulty.name == _selectedDifficulty).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) =>
          c.title.toLowerCase().contains(_searchQuery) ||
          c.description.toLowerCase().contains(_searchQuery)).toList();
    }

    return list;
  }

  // ─── Kurs ro'yxati ────────────────────────────────────────────────────────

  Widget _buildCourseList(
      List<CourseEntity> courses, CourseProvider provider, bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      color: isDark ? AppColors.amber : AppColors.primary,
      onRefresh: () => provider.loadCourses(),
      child: courses.isEmpty
          ? _buildEmpty(isDark, l10n)
          : ResponsiveLayout(
              mobileBody: _mobileList(courses, provider),
              tabletBody: _tabletGrid(courses, provider),
              desktopBody: _tabletGrid(courses, provider), // Use grid for desktop
            ),
    );
  }

  Widget _mobileList(List<CourseEntity> courses, CourseProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final course = courses[index];
        return AnimatedCourseCard(
          key: ValueKey(course.id),
          course: course,
          progress: provider.getUserProgress(course.id),
          index: index,
          onTap: () => Navigator.pushNamed(context, '/course_detail', arguments: course.id),
        );
      },
    );
  }

  Widget _tabletGrid(List<CourseEntity> courses, CourseProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return AnimatedCourseCard(
          key: ValueKey(course.id),
          course: course,
          progress: provider.getUserProgress(course.id),
          index: index,
          onTap: () => Navigator.pushNamed(context, '/course_detail', arguments: course.id),
        );
      },
    );
  }

  // ─── Stats hisoblash ──────────────────────────────────────────────────────

  _CourseStats _buildStats(CourseProvider provider) {
    final total = provider.courses.length;
    final completed = provider.courses
        .where((c) => provider.getUserProgress(c.id)?.isCompleted == true)
        .length;
    final xp = provider.courses.fold<int>(0, (sum, c) {
      final p = provider.getUserProgress(c.id);
      if (p == null) return sum;
      return sum + (p.isCompleted ? 50 : 0); // Har tugallangan kurs uchun 50 XP
    });
    return _CourseStats(total: total, completed: completed, xp: xp);
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.coursesNotFound,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          '${l10n.errorLabel}:\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

// ─── Stats Banner ─────────────────────────────────────────────────────────────

class _CourseStats {
  final int total;
  final int completed;
  final int xp;
  const _CourseStats({required this.total, required this.completed, required this.xp});
}

class _StatsBanner extends StatelessWidget {
  final _CourseStats stats;
  final bool isDark;

  const _StatsBanner({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1C2D42), Color(0xFF152032)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1A3C6E), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.amber : AppColors.primary).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.library_books_rounded,
            value: '${stats.total}',
            label: AppLocalizations.of(context)!.statCourses,
            color: const Color(0xFF2DD4BF),
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.check_circle_rounded,
            value: '${stats.completed}',
            label: AppLocalizations.of(context)!.statCompleted,
            color: AppColors.success,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.star_rounded,
            value: '${stats.xp}',
            label: AppLocalizations.of(context)!.statXpPoints,
            color: AppColors.amber,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (ctx, t, _) => Opacity(
        opacity: t,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

// ─── Custom Tab Bar ───────────────────────────────────────────────────────────

class _CourseTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDark;

  const _CourseTabBar({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.amber : AppColors.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: activeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: activeColor, width: 1.2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: activeColor,
        unselectedLabelColor: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.tabAll),
          Tab(text: AppLocalizations.of(context)!.tabCompleted),
          Tab(text: AppLocalizations.of(context)!.tabInProgress),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimaryLight, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.7), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondaryLight, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
