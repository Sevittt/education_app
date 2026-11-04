import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import '../../data/ict_report_remote_source.dart';
import '../../domain/entities/ict_report.dart';
import '../widgets/ict_report_card.dart';

/// Admin: AKT xodimlari yuborgan muammo/yechimlarni ko'rib chiqish.
class AdminIctReportsScreen extends StatelessWidget {
  const AdminIctReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: IctReportStatus.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AKT xodimlari takliflari'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kutilmoqda'),
              Tab(text: 'Nashr qilingan'),
              Tab(text: 'Rad etilgan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReportList(status: IctReportStatus.pending),
            _ReportList(status: IctReportStatus.approved),
            _ReportList(status: IctReportStatus.rejected),
          ],
        ),
      ),
    );
  }
}

class _ReportList extends StatefulWidget {
  final IctReportStatus status;

  const _ReportList({required this.status});

  @override
  State<_ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<_ReportList> {
  late final Stream<List<IctReport>> _stream =
      context.read<IctReportRemoteSource>().watchByStatus(widget.status);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IctReport>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Yuklab bo\'lmadi: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return const Center(child: Text('Yozuvlar yo\'q'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final r in reports)
              IctReportCard(
                report: r,
                showAuthor: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => IctReportReviewScreen(report: r)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Bitta yozuvni ko'rish; kutilayotgan bo'lsa FAQ'ga nashr qilish yoki rad etish.
class IctReportReviewScreen extends StatefulWidget {
  final IctReport report;

  const IctReportReviewScreen({super.key, required this.report});

  @override
  State<IctReportReviewScreen> createState() => _IctReportReviewScreenState();
}

class _IctReportReviewScreenState extends State<IctReportReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _questionCtrl = TextEditingController(text: widget.report.problem);
  late final _answerCtrl = TextEditingController(text: widget.report.solution);
  late FaqCategory _category = widget.report.category;
  bool _busy = false;

  bool get _isPending => widget.report.status == IctReportStatus.pending;

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final adminId = context.read<AuthNotifier>().appUser?.id;
    if (adminId == null) return;

    await _run(
      () => context.read<IctReportRemoteSource>().approveAsFaq(
            report: widget.report,
            question: _questionCtrl.text.trim(),
            answer: _answerCtrl.text.trim(),
            category: _category,
            systemId: widget.report.systemId,
            adminId: adminId,
          ),
      'FAQ\'ga nashr qilindi',
    );
  }

  Future<void> _reject() async {
    final adminId = context.read<AuthNotifier>().appUser?.id;
    if (adminId == null) return;
    final source = context.read<IctReportRemoteSource>();

    final comment = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (comment == null || !mounted) return;

    await _run(
      () => source.reject(
        reportId: widget.report.id,
        comment: comment,
        adminId: adminId,
      ),
      'Rad etildi',
    );
  }

  Future<void> _run(Future<Object?> Function() action, String doneMessage) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(doneMessage)));
      Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Taklifni ko\'rib chiqish')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IctStatusChip(status: r.status),
            const SizedBox(height: 12),
            Text(
              [r.authorName, r.courtName, r.regionName, r.systemName]
                  .whereType<String>()
                  .where((s) => s.isNotEmpty)
                  .join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _Section(title: 'Muammo', text: r.problem),
            if (r.description.isNotEmpty) _Section(title: 'Tafsilot', text: r.description),
            _Section(title: 'Yechim', text: r.solution),
            if (r.adminComment?.isNotEmpty ?? false)
              _Section(title: 'Admin izohi', text: r.adminComment!),
            if (_isPending) ...[
              const Divider(height: 32),
              Text('FAQ sifatida nashr qilish',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Matnni foydalanuvchilar uchun tushunarli qilib tahrirlang.',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              DropdownButtonFormField<FaqCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategoriya',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final c in FaqCategory.values)
                    DropdownMenuItem(value: c, child: Text('${c.icon} ${c.displayName}')),
                ],
                onChanged: (c) => setState(() => _category = c ?? _category),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Savol',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'To\'ldirish shart' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerCtrl,
                minLines: 4,
                maxLines: 14,
                decoration: const InputDecoration(
                  labelText: 'Javob',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'To\'ldirish shart' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _reject,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Rad etish'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _publish,
                      icon: const Icon(Icons.publish_rounded),
                      label: const Text('Nashr qilish'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String text;

  const _Section({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 4),
          SelectableText(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rad etish sababi'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        minLines: 2,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'AKT xodimi shu izohni ko\'radi',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          onPressed: _ctrl.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _ctrl.text.trim()),
          child: const Text('Rad etish'),
        ),
      ],
    );
  }
}
