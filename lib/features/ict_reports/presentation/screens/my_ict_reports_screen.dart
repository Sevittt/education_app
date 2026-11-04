import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import '../../data/ict_report_remote_source.dart';
import '../../domain/entities/ict_report.dart';
import '../widgets/ict_report_card.dart';
import 'ict_report_form_screen.dart';

/// AKT xodimining yuborgan muammo/yechimlari va ularning holati.
class MyIctReportsScreen extends StatelessWidget {
  const MyIctReportsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, IctReport report) async {
    final source = context.read<IctReportRemoteSource>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('O\'chirilsinmi?'),
        content: Text('"${report.problem}" hali ko\'rib chiqilmagan. Uni qaytarib olasizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Yo\'q')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('O\'chirish')),
        ],
      ),
    );
    if (ok == true) await source.deletePending(report.id);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthNotifier>().appUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Mening yuborganlarim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IctReportFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Yangi'),
      ),
      body: uid == null
          ? const SizedBox.shrink()
          : StreamBuilder<List<IctReport>>(
              stream: context.read<IctReportRemoteSource>().watchMine(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Yuklab bo\'lmadi: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snapshot.data!;
                if (reports.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Hali hech narsa yubormadingiz.\n'
                        'Duch kelgan muammo va yechimingizni ulashing — '
                        'boshqa sudlardagi hamkasblarga yordam beradi.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    for (final r in reports)
                      IctReportCard(
                        report: r,
                        trailing: r.status == IctReportStatus.pending
                            ? IconButton(
                                tooltip: 'O\'chirish',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(context, r),
                              )
                            : null,
                      ),
                  ],
                );
              },
            ),
    );
  }
}
