import 'package:flutter/material.dart';
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Savolni o\'chirish'),
        content: Text('Siz "${faq.question}" savolini o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _service.deleteFAQ(faq.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savol o\'chirildi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savol-Javoblarni Boshqarish'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FAQ>>(
        stream: _service.getAllFAQs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final faqs = snapshot.data ?? [];

          if (faqs.isEmpty) {
            return const Center(child: Text('Savollar yo\'q'));
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFAQ(faq),
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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddEditFAQScreen(),
            ),
          );
        },
      ),
    );
  }
}
