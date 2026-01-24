import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/systems/presentation/screens/systems_directory_screen.dart';
import 'package:sud_qollanma/features/faq/presentation/screens/faq_list_screen.dart';
import 'tabs/articles_tab.dart';
import 'tabs/videos_tab.dart';
import 'tabs/files_tab.dart';

import 'package:sud_qollanma/features/quiz/presentation/screens/quiz_list_screen.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.resourcesScreenTitle),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.resourceTabArticles, icon: const Icon(Icons.article_outlined)),
              Tab(text: l10n.resourceTabVideos, icon: const Icon(Icons.video_library_outlined)),
              Tab(text: l10n.resourceTabFiles, icon: const Icon(Icons.folder_open_outlined)),
              Tab(text: l10n.quizTitle, icon: const Icon(Icons.quiz_outlined)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.question_answer),
              tooltip: l10n.faqTitle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaqListScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.computer),
              tooltip: l10n.systemsDirectoryTitle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SystemsDirectoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            const ArticlesTab(),
            const VideosTab(),
            const FilesTab(),
            const QuizListScreen(),
          ],
        ),
      ),
    );
  }
}
