import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/csv_report_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final CollectionReference _recordsCollection =
      FirebaseFirestore.instance.collection('learning_records');

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.analyticsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'xAPI faollik'),
            Tab(icon: Icon(Icons.table_chart_rounded), text: 'Sud faolligi'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'CSV yuklash',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hisobot tayyorlanmoqda...')),
                );
                await CsvReportService().generateAndShareCourtReport();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xatolik: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildXapiTab(),
          _buildCourtStatsTab(),
        ],
      ),
    );
  }

  // ─── Tab 1: xAPI ──────────────────────────────────────────────────────────

  Widget _buildXapiTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _recordsCollection
          .orderBy('stored', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.errorGeneric(
                  snapshot.error?.toString() ?? 'Unknown error')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noRecords));
        }

        final docs = snapshot.data!.docs;
        final verbCounts = _aggregateDiffVerbs(docs);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(docs.length),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.activityDistribution,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildVerbChart(verbCounts, docs.length),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.recentActivityFeed,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRecentActivityList(docs),
            ],
          ),
        );
      },
    );
  }

  // ─── Tab 2: Court stats table ─────────────────────────────────────────────

  Widget _buildCourtStatsTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        final Map<String, Map<String, dynamic>> stats = {};

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final court = data['courtName'] as String? ?? "Noma'lum sud";
          final xp = (data['xp'] as num?)?.toInt() ?? 0;
          final passed = (data['quizzesPassed'] as num?)?.toInt() ?? 0;
          final aced = (data['totalQuizzesAced'] as num?)?.toInt() ?? 0;
          final sims = (data['simulationsCompleted'] as num?)?.toInt() ?? 0;

          stats.putIfAbsent(court, () => {
            'count': 0, 'xp': 0, 'passed': 0, 'aced': 0, 'sims': 0,
          });
          stats[court]!['count'] = (stats[court]!['count'] as int) + 1;
          stats[court]!['xp'] = (stats[court]!['xp'] as int) + xp;
          stats[court]!['passed'] = (stats[court]!['passed'] as int) + passed;
          stats[court]!['aced'] = (stats[court]!['aced'] as int) + aced;
          stats[court]!['sims'] = (stats[court]!['sims'] as int) + sims;
        }

        final rows = stats.entries.toList()
          ..sort((a, b) => (b.value['xp'] as int).compareTo(a.value['xp'] as int));

        if (rows.isEmpty) {
          return const Center(child: Text("Ma'lumot yo'q"));
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final headerColor = isDark ? AppColors.surfaceElevated : AppColors.primaryContainer;
        final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Jami: ${docs.length} foydalanuvchi • ${rows.length} sud',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(headerColor),
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textColor,
                  ),
                  dataTextStyle: TextStyle(fontSize: 12, color: textColor),
                  columnSpacing: 20,
                  horizontalMargin: 12,
                  columns: const [
                    DataColumn(label: Text('Sud nomi')),
                    DataColumn(label: Text('Xodim'), numeric: true),
                    DataColumn(label: Text('Umumiy XP'), numeric: true),
                    DataColumn(label: Text("O'rta XP"), numeric: true),
                    DataColumn(label: Text('Testlar'), numeric: true),
                    DataColumn(label: Text("A'lo"), numeric: true),
                    DataColumn(label: Text('Sim.'), numeric: true),
                  ],
                  rows: rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value.value;
                    final count = s['count'] as int;
                    final xp = s['xp'] as int;
                    final avgXp = count > 0 ? (xp / count).toStringAsFixed(1) : '0';
                    final isEven = i.isEven;

                    return DataRow(
                      color: WidgetStateProperty.all(
                        isEven
                            ? Colors.transparent
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.black.withValues(alpha: 0.02)),
                      ),
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              entry.value.key,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text('$count')),
                        DataCell(
                          Text(
                            '$xp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: xp > 500 ? AppColors.success : textColor,
                            ),
                          ),
                        ),
                        DataCell(Text(avgXp)),
                        DataCell(Text('${s['passed']}')),
                        DataCell(Text('${s['aced']}')),
                        DataCell(Text('${s['sims']}')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _aggregateDiffVerbs(List<DocumentSnapshot> docs) {
    final Map<String, int> counts = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Safely access nested verb display
      // data['verb']['display']['en-US']
      try {
        final verbDisplay = (data['verb'] as Map)['display'] as Map;
        // Try en-US, fallback to first key, fallback to ID
        String verbName =
            verbDisplay['en-US'] ?? verbDisplay.values.firstOrNull ?? 'unknown';
        counts[verbName] = (counts[verbName] ?? 0) + 1;
      } catch (e) {
        counts['unknown'] = (counts['unknown'] ?? 0) + 1;
      }
    }
    return counts;
  }

  Widget _buildSummaryCards(int totalRecords) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    totalRecords.toString(),
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: cs.primary),
                  ),
                  Text(AppLocalizations.of(context)!.totalRecords,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Placeholder for another metric (e.g. Active Users)
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.insights, size: 32, color: AppColors.success),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.realTime,
                      style: TextStyle(color: AppColors.success)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerbChart(Map<String, int> counts, int total) {
    // Sort by count descending
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final percentage = entry.value / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      entry.key.replaceAll('_', ' ')[0].toUpperCase() +
                          entry.key.replaceAll('_', ' ').substring(1).toLowerCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                      '${entry.value} (${(percentage * 100).toStringAsFixed(1)}%)'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                color: _getColorForVerb(entry.key),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForVerb(String verb) {
    switch (verb.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'passed':
        return Colors.teal;
      case 'failed':
        return Colors.red;
      case 'experienced':
        return Colors.blue;
      case 'interacted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecentActivityList(List<DocumentSnapshot> docs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length > 10 ? 10 : docs.length, // Show top 10
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        // We could use XApiStatement.fromJson(data) but sometimes firestore timestamp formatting differs
        // Let's try manual extraction for safety or use the model carefully.

        DateTime? timestamp;
        if (data['stored'] is Timestamp) {
          timestamp = (data['stored'] as Timestamp).toDate();
        }

        final actorName = (data['actor'] as Map)['name'] ??
            AppLocalizations.of(context)!.unknownUser;
        final verbDisplay =
            ((data['verb'] as Map)['display'] as Map)['en-US'] ?? 'acted';
        final objectName = ((data['object'] as Map)['definition']
                as Map?)?['name']?['en-US'] ??
            AppLocalizations.of(context)!.unknownObject;

        final resultScore =
            ((data['result'] as Map?)?['score'] as Map?)?['raw'];
        final resultSuccess = ((data['result'] as Map?)?['success']);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ListTile(
            leading: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 40, maxHeight: 40),
              child: CircleAvatar(
                backgroundColor: _getColorForVerb(verbDisplay).withAlpha(50),
                child: Icon(
                  _getIconForVerb(verbDisplay),
                  color: _getColorForVerb(verbDisplay),
                  size: 20,
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                      text: actorName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' '),
                  TextSpan(
                      text: verbDisplay,
                      style: TextStyle(color: _getColorForVerb(verbDisplay))),
                  const TextSpan(text: ' '),
                  TextSpan(
                      text: objectName,
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            subtitle: Text(
              timestamp != null
                  ? DateFormat('HH:mm:ss dd MMM').format(timestamp)
                  : AppLocalizations.of(context)!.justNow,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            trailing: _buildResultBadge(resultSuccess, resultScore),
          ),
        );
      },
    );
  }

  Widget? _buildResultBadge(bool? success, dynamic score) {
    if (success == null && score == null) return null;

    final l10n = AppLocalizations.of(context)!;

    if (success != null) {
      return Chip(
        label: Text(
          success ? l10n.labelPass : l10n.labelFail,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }

    if (score != null) {
      return Chip(
        label: Text('$score%', style: const TextStyle(fontSize: 10)),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }
    return null;
  }

  IconData _getIconForVerb(String verb) {
    switch (verb.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'passed':
        return Icons.grade;
      case 'failed':
        return Icons.warning_amber;
      case 'experienced':
        return Icons.visibility;
      case 'interacted':
        return Icons.touch_app;
      default:
        return Icons.circle;
    }
  }
}
