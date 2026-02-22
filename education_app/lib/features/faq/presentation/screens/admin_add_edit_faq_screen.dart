import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';
import 'package:sud_qollanma/features/faq/presentation/providers/faq_notifier.dart';

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
  FaqCategory _selectedCategory = FaqCategory.general;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.faq?.question ?? '');
    _answerController = TextEditingController(text: widget.faq?.answer ?? '');
    _selectedCategory = widget.faq?.category ?? FaqCategory.general;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _saveFAQ() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final notifier = Provider.of<FaqNotifier>(context, listen: false);

    try {
      if (widget.faq == null) {
        // Create new
        final newFAQ = FaqEntity(
          id: '', // ID generates elsewhere or handled by repo/datasource if needed, but for Clean Arch often ID is generated in DataSource or here if using UUID. Firestore generates ID if passed as empty or map. Entity usually requires ID.
          // In this project, creating with empty ID usually implies Firestore add() which generates ID.
          // Let's ensure our Repo handles empty ID or generation. FaqRemoteDataSourceImpl.createFaq uses .add(), so ID in entity is ignored during creation.
          question: _questionController.text,
          answer: _answerController.text,
          category: _selectedCategory,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await notifier.createFaq(newFAQ);
      } else {
        // Update existing
         // FaqEntity is equatable and likely immutable (if using Equatable correctly, usually fields are final).
         // We need a copyWith equivalent? FaqEntity usually has copyWith if generated or manually added.
         // Step 9129 created FaqEntity without copyWith method (my bad, I missed it there, but FaqModel has it).
         // Actually FaqEntity in step 9129 does NOT have copyWith. I should have added it.
         // However, I can just create a new FaqEntity with the same ID.
         final updatedFAQ = FaqEntity(
            id: widget.faq!.id,
            question: _questionController.text,
            answer: _answerController.text,
            category: _selectedCategory,
            systemId: widget.faq!.systemId,
            relatedArticles: widget.faq!.relatedArticles,
            relatedVideos: widget.faq!.relatedVideos,
            viewCount: widget.faq!.viewCount,
            helpfulCount: widget.faq!.helpfulCount,
            order: widget.faq!.order,
            createdAt: widget.faq!.createdAt,
            updatedAt: DateTime.now(),
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
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: l10n.questionLabel,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.questionRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: l10n.answerLabel,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.answerRequired : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
