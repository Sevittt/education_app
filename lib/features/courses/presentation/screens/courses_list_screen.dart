import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/courses/presentation/widgets/course_list_card.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

enum _StatusFilter { all, mine, completed }

/// Kurslar roʻyxati (Figma "02 · Kurslar"): qidiruv, filtrlar, avval davom etayotganlar.
class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _StatusFilter _status = _StatusFilter.all;
  CourseDifficulty? _difficulty;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _open(String id) => Navigator.pushNamed(context, '/course_detail', arguments: id);

  List<CourseEntity> _filter(CourseProvider p) {
    return p.courses.where((c) {
      final progress = p.getUserProgress(c.id);
      final statusOk = switch (_status) {
        _StatusFilter.all => true,
        _StatusFilter.mine => progress != null && !progress.isCompleted,
        _StatusFilter.completed => progress?.isCompleted == true,
      };
      final difficultyOk = _difficulty == null || c.difficulty == _difficulty;
      final queryOk = _query.isEmpty ||
          c.title.toLowerCase().contains(_query) ||
          c.description.toLowerCase().contains(_query);
      return statusOk && difficultyOk && queryOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final provider = context.watch<CourseProvider>();
    final list = _filter(provider);

    final grouped = _status == _StatusFilter.all && _difficulty == null && _query.isEmpty;
    final inProgress = grouped
        ? list.where((c) {
            final p = provider.getUserProgress(c.id);
            return p != null && !p.isCompleted;
          }).toList()
        : const <CourseEntity>[];

    Widget chip(String label, bool selected, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(right: AppSpace.s8),
          child: ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onTap(),
            labelStyle: text.labelLarge?.copyWith(color: selected ? t.textOnBrand : t.textSecondary),
            side: selected ? BorderSide.none : BorderSide(color: t.borderDefault),
          ),
        );

    Widget cards(List<CourseEntity> courses) => LayoutBuilder(builder: (context, c) {
          final columns = c.maxWidth >= 720 ? 2 : 1;
          final width = (c.maxWidth - (columns - 1) * AppSpace.s12) / columns;
          return Wrap(
            spacing: AppSpace.s12,
            runSpacing: AppSpace.s12,
            children: [
              for (final course in courses)
                SizedBox(
                  width: width,
                  child: CourseListCard(
                    key: ValueKey(course.id),
                    course: course,
                    progress: provider.getUserProgress(course.id),
                    onTap: () => _open(course.id),
                  ),
                ),
            ],
          );
        });

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => provider.loadCourses(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, 96),
          children: [
            Text(l10n.coursesTitle, style: text.displayMedium),
            const SizedBox(height: AppSpace.s16),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: l10n.searchCoursesHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        }),
                      ),
              ),
            ),
            const SizedBox(height: AppSpace.s12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: [
                chip(l10n.courseFilterAll, _status == _StatusFilter.all && _difficulty == null,
                    () => setState(() {
                          _status = _StatusFilter.all;
                          _difficulty = null;
                        })),
                chip(l10n.myCoursesTitle, _status == _StatusFilter.mine,
                    () => setState(() => _status = _status == _StatusFilter.mine ? _StatusFilter.all : _StatusFilter.mine)),
                chip(l10n.dsCompleted, _status == _StatusFilter.completed,
                    () => setState(() => _status = _status == _StatusFilter.completed ? _StatusFilter.all : _StatusFilter.completed)),
                for (final (d, label) in [
                  (CourseDifficulty.beginner, l10n.courseFilterBeginner),
                  (CourseDifficulty.intermediate, l10n.courseFilterIntermediate),
                  (CourseDifficulty.advanced, l10n.courseFilterAdvanced),
                ])
                  chip(label, _difficulty == d, () => setState(() => _difficulty = _difficulty == d ? null : d)),
              ]),
            ),
            const SizedBox(height: AppSpace.s20),
            if (provider.error != null && provider.courses.isEmpty)
              _Empty(icon: Icons.cloud_off_rounded, message: '${l10n.errorLabel}: ${provider.error}')
            else if (provider.isLoading && provider.courses.isEmpty)
              const Padding(padding: EdgeInsets.all(AppSpace.s32), child: Center(child: CircularProgressIndicator()))
            else if (list.isEmpty)
              _Empty(icon: Icons.search_off_rounded, message: l10n.coursesNotFound)
            else ...[
              if (inProgress.isNotEmpty) ...[
                SectionHeader(l10n.dsInProgress),
                const SizedBox(height: AppSpace.s12),
                cards(inProgress),
                const SizedBox(height: AppSpace.s20),
                SectionHeader(l10n.dsAllCourses(list.length)),
                const SizedBox(height: AppSpace.s12),
              ],
              cards(list),
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String message;

  const _Empty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s32),
      child: Column(children: [
        Icon(icon, size: 48, color: t.textTertiary),
        const SizedBox(height: AppSpace.s12),
        Text(message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary)),
      ]),
    );
  }
}
