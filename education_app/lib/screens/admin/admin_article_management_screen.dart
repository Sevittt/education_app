import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteArticleMessage(article.title)),
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
      await _service.deleteArticle(article.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.resourceDeletedSuccess(article.title))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageArticlesTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<KnowledgeArticle>>(
        stream: _service.getAllArticles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.errorPrefix}${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return Center(child: Text(l10n.noResourcesFoundManager));
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
                        tooltip: l10n.editResourceTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteArticle(article),
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
              builder: (context) => const AdminAddEditArticleScreen(),
            ),
          );
        },
        tooltip: l10n.add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
