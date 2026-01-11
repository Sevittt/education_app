import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/faq.dart';
import '../../services/faq_service.dart';
import 'admin_add_edit_faq_screen.dart';

class AdminFAQManagementScreen extends StatefulWidget {
  const AdminFAQManagementScreen({super.key});

  @override
  State<AdminFAQManagementScreen> createState() => _AdminFAQManagementScreenState();
}

class _AdminFAQManagementScreenState extends State<AdminFAQManagementScreen> {
  final FAQService _service = FAQService();

  Future<void> _deleteFAQ(FAQ faq) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteFaqMessage(faq.question)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _service.deleteFAQ(faq.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.faqDeletedSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageFaqTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FAQ>>(
        stream: _service.getAllFAQs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.errorPrefix}${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final faqs = snapshot.data ?? [];

          if (faqs.isEmpty) {
            return Center(child: Text(l10n.noFaqsFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(faq.category.icon),
                  ),
                  title: Text(
                    faq.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(faq.category.displayName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAddEditFAQScreen(faq: faq),
                            ),
                          );
                        },
                        tooltip: l10n.editResourceTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFAQ(faq),
                        tooltip: l10n.deleteResourceTooltip,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddEditFAQScreen(),
            ),
          );
        },
        tooltip: l10n.add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
