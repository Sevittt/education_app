import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/knowledge_article.dart';
import '../../services/knowledge_base_service.dart';
import 'admin_add_edit_article_screen.dart';

class AdminArticleManagementScreen extends StatefulWidget {
  const AdminArticleManagementScreen({super.key});

  @override
  State<AdminArticleManagementScreen> createState() => _AdminArticleManagementScreenState();
}

class _AdminArticleManagementScreenState extends State<AdminArticleManagementScreen> {
  final KnowledgeBaseService _service = KnowledgeBaseService();

  Future<void> _deleteArticle(KnowledgeArticle article) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maqolani o\'chirish'),
        content: Text('Siz "${article.title}" maqolasini o\'chirmoqchimisiz?'),
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
      await _service.deleteArticle(article.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maqola o\'chirildi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maqolalarni Boshqarish'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<KnowledgeArticle>>(
        stream: _service.getAllArticles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(child: Text('Maqolalar yo\'q'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(article.category.icon),
                  ),
                  title: Text(
                    article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd.MM.yyyy').format(article.updatedAt.toDate()),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAddEditArticleScreen(article: article),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteArticle(article),
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
              builder: (context) => const AdminAddEditArticleScreen(),
            ),
          );
        },
      ),
    );
  }
}
