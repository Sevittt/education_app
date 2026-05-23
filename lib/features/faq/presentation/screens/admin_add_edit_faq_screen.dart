import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import 'package:sud_qollanma/features/faq/presentation/providers/faq_notifier.dart';

/// Allowed systemId values — must match Firestore schema
const List<String> _kSystemIds = [
  'ESUD',
  'EXAT',
  'EDO',
  'EIMZO',
  'MYSUD',
  'VKS',
  'Umumiy',
];

class AdminAddEditFAQScreen extends StatefulWidget {
  final FaqEntity? faq;

  const AdminAddEditFAQScreen({super.key, this.faq});

  @override
  State<AdminAddEditFAQScreen> createState() => _AdminAddEditFAQScreenState();
}

class _AdminAddEditFAQScreenState extends State<AdminAddEditFAQScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _shortAnswerController;
  late TextEditingController _orderController;
  FaqCategory _selectedCategory = FaqCategory.general;
  String _selectedSystemId = 'Umumiy';
  String _selectedDifficulty = "o'rta";
  bool _isActive = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final faq = widget.faq;
    _questionController = TextEditingController(text: faq?.question ?? '');
    _answerController = TextEditingController(text: faq?.answer ?? '');
    // shortAnswer field is in FaqEntity now.
    _shortAnswerController = TextEditingController(text: faq?.shortAnswer ?? '');
    _orderController = TextEditingController(
      text: faq?.order.toString() ?? '0',
    );
    _selectedCategory = faq?.category ?? FaqCategory.general;
    // Normalise stored systemId — default to 'Umumiy' if missing/unknown
    final storedSystem = faq?.systemId ?? 'Umumiy';
    _selectedSystemId =
        _kSystemIds.contains(storedSystem) ? storedSystem : 'Umumiy';

    // Normalise difficulty — default to "o'rta" if unknown
    const kDifficulties = ["boshlang'ich", "o'rta", "murakkab"];
    final storedDifficulty = faq?.difficulty ?? "o'rta";
    _selectedDifficulty =
        kDifficulties.contains(storedDifficulty) ? storedDifficulty : "o'rta";
    _isActive = faq?.isActive ?? true;

  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _shortAnswerController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveFAQ() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final notifier = Provider.of<FaqNotifier>(context, listen: false);

    try {
      final now = DateTime.now();
      final order = int.tryParse(_orderController.text) ?? 0;

      if (widget.faq == null) {
        // Create new FAQ
        final newFAQ = FaqEntity(
          id: '',
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
          shortAnswer: _shortAnswerController.text.trim(),
          category: _selectedCategory,
          systemId: _selectedSystemId,
          difficulty: _selectedDifficulty,
          isActive: _isActive,
          order: order,
          createdAt: now,
          updatedAt: now,
        );
        await notifier.createFaq(newFAQ);
      } else {
        // Update existing FAQ
        final updatedFAQ = FaqEntity(
          id: widget.faq!.id,
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
          shortAnswer: _shortAnswerController.text.trim(),
          category: _selectedCategory,
          systemId: _selectedSystemId,
          difficulty: _selectedDifficulty,
          isActive: _isActive,
          relatedArticles: widget.faq!.relatedArticles,
          relatedVideos: widget.faq!.relatedVideos,
          viewCount: widget.faq!.viewCount,
          helpfulCount: widget.faq!.helpfulCount,
          order: order,
          createdAt: widget.faq!.createdAt,
          updatedAt: now,
        );
        await notifier.updateFaq(updatedFAQ);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.faqSavedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.faq == null ? l10n.addFaqTitle : l10n.editFaqTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveFAQ,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── SystemId ──────────────────────────────────────────
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSystemId,
                      decoration: const InputDecoration(
                        labelText: '🖥 Tizim (SystemId)',
                        border: OutlineInputBorder(),
                      ),
                      items: _kSystemIds.map((id) {
                        return DropdownMenuItem(
                          value: id,
                          child: Text(id),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSystemId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Category ──────────────────────────────────────────
                    DropdownButtonFormField<FaqCategory>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: FaqCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text('${category.icon} ${category.displayName}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Difficulty ──────────────────────────────────────────
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: '📊 Qiyinchilik darajasi (Difficulty)',
                        border: OutlineInputBorder(),
                      ),
                      items: ["boshlang'ich", "o'rta", "murakkab"].map((diff) {
                        return DropdownMenuItem(
                          value: diff,
                          child: Text(diff),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDifficulty = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── isActive ──────────────────────────────────────────
                    SwitchListTile(
                      title: const Text('🌟 Holati (Faolmi?)'),
                      subtitle: const Text('Bot va ilova qidiruvlarida chiqadi'),
                      value: _isActive,
                      onChanged: (val) {
                        setState(() => _isActive = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Question ──────────────────────────────────────────
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: l10n.questionLabel,
                        border: const OutlineInputBorder(),
                        hintText: 'Masalan: EDO da arxivlangan hujjatlarni qanday ko\'raman?',
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.questionRequired : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Short Answer (for bot) ────────────────────────────
                    TextFormField(
                      controller: _shortAnswerController,
                      decoration: const InputDecoration(
                        labelText: '📱 Qisqa javob (bot uchun)',
                        border: OutlineInputBorder(),
                        hintText: '1-2 jumlada qisqacha javob (ilovaning bot qismida ko\'rinadi)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // ── Full Answer ───────────────────────────────────────
                    TextFormField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: l10n.answerLabel,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'Batafsil javob (ilovada to\'liq ko\'rinadi)',
                      ),
                      maxLines: 10,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.answerRequired : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Order ─────────────────────────────────────────────
                    TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(
                        labelText: '🔢 Tartib raqami (order)',
                        border: OutlineInputBorder(),
                        hintText: 'Ro\'yxatdagi tartib (kichigi birinchi)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
