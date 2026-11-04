import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/presentation/providers/systems_notifier.dart';
import '../../data/ict_report_remote_source.dart';
import '../../domain/entities/ict_report.dart';

/// AKT xodimi duch kelgan muammo va uning yechimini adminga yuboradi.
class IctReportFormScreen extends StatefulWidget {
  const IctReportFormScreen({super.key});

  @override
  State<IctReportFormScreen> createState() => _IctReportFormScreenState();
}

class _IctReportFormScreenState extends State<IctReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _solutionCtrl = TextEditingController();
  FaqCategory _category = FaqCategory.technical;
  SudSystemEntity? _system;
  bool _submitting = false;
  // Har rebuild'da qayta obuna bo'lmaslik uchun bir marta olinadi
  late final Stream<List<SudSystemEntity>> _systems =
      context.read<SystemsNotifier>().systemsStream;

  @override
  void dispose() {
    _problemCtrl.dispose();
    _descriptionCtrl.dispose();
    _solutionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthNotifier>().appUser;
    if (user == null) return;

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<IctReportRemoteSource>().submit(IctReport(
            authorId: user.id,
            authorName: user.name,
            courtName: user.courtName,
            regionName: user.regionName,
            systemId: _system?.id,
            systemName: _system?.name,
            category: _category,
            problem: _problemCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            solution: _solutionCtrl.text.trim(),
          ));
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Yuborildi. Admin ko\'rib chiqqach holati shu yerda ko\'rinadi.'),
      ));
      Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Yuborib bo\'lmadi: $e')));
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value, int max) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'To\'ldirish shart';
    if (text.length > max) return 'Ko\'pi bilan $max belgi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Muammo va yechim')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ishda duch kelgan muammo va uni qanday hal qilganingizni yozing. '
              'Admin ko\'rib chiqib, foydali bo\'lsa FAQ bo\'limida hamma uchun nashr qiladi.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<SudSystemEntity>>(
              stream: _systems,
              builder: (context, snapshot) {
                final systems = snapshot.data ?? const <SudSystemEntity>[];
                return DropdownButtonFormField<String?>(
                  initialValue: _system?.id,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tizim (ixtiyoriy)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tizimga bog\'liq emas'),
                    ),
                    for (final s in systems)
                      DropdownMenuItem<String?>(value: s.id, child: Text(s.name)),
                  ],
                  onChanged: (id) => setState(() {
                    _system = systems.where((s) => s.id == id).firstOrNull;
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FaqCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Turi',
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
              controller: _problemCtrl,
              maxLength: IctReport.maxProblemLength,
              decoration: const InputDecoration(
                labelText: 'Muammo',
                hintText: 'Masalan: E-SUD\'ga kirishda "sertifikat topilmadi" xatosi',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _required(v, IctReport.maxProblemLength),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionCtrl,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Tafsilot (ixtiyoriy)',
                hintText: 'Qachon, qaysi kompyuterda, qanday xabar chiqdi',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v?.trim().length ?? 0) > IctReport.maxTextLength
                  ? 'Ko\'pi bilan ${IctReport.maxTextLength} belgi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _solutionCtrl,
              minLines: 4,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Yechim',
                hintText: 'Muammoni qanday hal qildingiz — qadamma-qadam',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => _required(v, IctReport.maxTextLength),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Adminga yuborish'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
