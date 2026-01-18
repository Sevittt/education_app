import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/analytics/domain/entities/xapi_statement.dart';
import 'package:intl/intl.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final CollectionReference _recordsCollection =
      FirebaseFirestore.instance.collection('learning_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.analyticsTitle),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _recordsCollection
            .orderBy('stored', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context)!.errorGeneric(snapshot.error ?? 'Unknown error')));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noRecords));
          }

          final docs = snapshot.data!.docs;
          // Simple client-side aggregation for MVP
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
      ),
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
        String verbName = verbDisplay['en-US'] ?? 
                          verbDisplay.values.firstOrNull ?? 
                          'unknown';
        counts[verbName] = (counts[verbName] ?? 0) + 1;
      } catch (e) {
        counts['unknown'] = (counts['unknown'] ?? 0) + 1;
      }
    }
    return counts;
  }

  Widget _buildSummaryCards(int totalRecords) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    totalRecords.toString(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(AppLocalizations.of(context)!.totalRecords, style: const TextStyle(color: Colors.blueGrey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Placeholder for another metric (e.g. Active Users)
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.insights, size: 32, color: Colors.green),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.realTime, style: const TextStyle(color: Colors.green)),
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
                  Text(entry.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${entry.value} (${(percentage * 100).toStringAsFixed(1)}%)'),
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
      case 'completed': return Colors.green;
      case 'passed': return Colors.teal;
      case 'failed': return Colors.red;
      case 'experienced': return Colors.blue;
      case 'interacted': return Colors.orange;
      default: return Colors.grey;
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

        final actorName = (data['actor'] as Map)['name'] ?? AppLocalizations.of(context)!.unknownUser;
        final verbDisplay = ((data['verb'] as Map)['display'] as Map)['en-US'] ?? 'acted';
        final objectName = ((data['object'] as Map)['definition'] as Map?)?['name']?['en-US'] ?? AppLocalizations.of(context)!.unknownObject;
        
        final resultScore = ((data['result'] as Map?)?['score'] as Map?)?['raw'];
        final resultSuccess = ((data['result'] as Map?)?['success']);

        return Card(
           margin: const EdgeInsets.only(bottom: 8),
           elevation: 1,
           child: ListTile(
             leading: CircleAvatar(
               backgroundColor: _getColorForVerb(verbDisplay).withAlpha(50),
               child: Icon(
                 _getIconForVerb(verbDisplay), 
                 color: _getColorForVerb(verbDisplay),
                 size: 20,
               ),
             ),
             title: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(text: actorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' '),
                    TextSpan(text: verbDisplay, style: TextStyle(color: _getColorForVerb(verbDisplay))),
                    const TextSpan(text: ' '),
                    TextSpan(text: objectName, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
             ),
             subtitle: Text(
               timestamp != null ? DateFormat('HH:mm:ss dd MMM').format(timestamp) : AppLocalizations.of(context)!.justNow,
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
      case 'completed': return Icons.check_circle_outline;
      case 'passed': return Icons.grade;
      case 'failed': return Icons.warning_amber;
      case 'experienced': return Icons.visibility;
      case 'interacted': return Icons.touch_app;
      default: return Icons.circle;
    }
  }
}
