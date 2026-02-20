// lib/main.dart
// Clean Architecture Migration - Finalized

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:ui'; // For PlatformDispatcher
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase Core
import 'package:firebase_core/firebase_core.dart';
// Systems Feature
import 'package:sud_qollanma/features/systems/data/datasources/systems_remote_datasource.dart';
import 'package:sud_qollanma/features/systems/data/repositories/systems_repository_impl.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';
import 'package:sud_qollanma/features/systems/domain/usecases/systems_read_usecases.dart';
import 'package:sud_qollanma/features/systems/domain/usecases/systems_write_usecases.dart';
import 'package:sud_qollanma/features/systems/presentation/providers/systems_notifier.dart';

import 'firebase_options.dart';

// Localization
import 'package:sud_qollanma/l10n/app_localizations.dart';

// Core Layer
import 'package:sud_qollanma/core/constants/api_constants.dart';
import 'package:sud_qollanma/core/theme/app_theme.dart';

// Feature: Auth
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:sud_qollanma/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sud_qollanma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';

// Feature: Library
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/repositories/library_repository.dart';
import 'package:sud_qollanma/features/library/data/datasources/library_remote_source.dart';
import 'package:sud_qollanma/features/library/data/repositories/library_repository_impl.dart';


// Feature: Community (Clean Arch)
import 'package:sud_qollanma/features/community/data/datasources/community_remote_datasource.dart';
import 'package:sud_qollanma/features/community/data/repositories/community_repository_impl.dart';
import 'package:sud_qollanma/features/community/domain/repositories/community_repository.dart';
import 'package:sud_qollanma/features/community/domain/usecases/get_topics.dart';
import 'package:sud_qollanma/features/community/domain/usecases/create_topic.dart';
import 'package:sud_qollanma/features/community/domain/usecases/add_comment.dart';
import 'package:sud_qollanma/features/community/presentation/providers/community_provider.dart';

import 'package:sud_qollanma/features/news/data/datasources/news_remote_datasource.dart';
import 'package:sud_qollanma/features/news/data/repositories/news_repository_impl.dart';
import 'package:sud_qollanma/features/news/domain/repositories/news_repository.dart';
import 'package:sud_qollanma/features/news/domain/usecases/get_news_stream.dart';
import 'package:sud_qollanma/features/news/domain/usecases/news_crud_usecases.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';

// Feature: Quiz (Clean Arch)
import 'package:sud_qollanma/features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'package:sud_qollanma/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:sud_qollanma/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/get_quizzes.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/get_quiz_by_id.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/get_quizzes_by_resource_id.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/submit_quiz_attempt.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/delete_quiz.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/create_quiz.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/add_question_to_quiz.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/get_user_attempts.dart';
import 'package:sud_qollanma/features/quiz/domain/usecases/get_recent_user_attempts.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';

// Feature: FAQ (Clean Arch)
import 'package:sud_qollanma/features/faq/data/datasources/faq_remote_datasource.dart';
import 'package:sud_qollanma/features/faq/data/repositories/faq_repository_impl.dart';
import 'package:sud_qollanma/features/faq/domain/repositories/faq_repository.dart';
import 'package:sud_qollanma/features/faq/domain/usecases/faq_read_usecases.dart';
import 'package:sud_qollanma/features/faq/domain/usecases/faq_write_usecases.dart';
import 'package:sud_qollanma/features/faq/presentation/providers/faq_notifier.dart';

// Feature: Analytics (Clean Arch)
import 'package:sud_qollanma/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:sud_qollanma/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:sud_qollanma/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:sud_qollanma/features/analytics/domain/usecases/analytics_usecases.dart';

// Feature: Gamification (Clean Arch)
import 'package:sud_qollanma/features/gamification/data/datasources/gamification_remote_datasource.dart';
import 'package:sud_qollanma/features/gamification/data/repositories/gamification_repository_impl.dart';
import 'package:sud_qollanma/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/gamification_usecases.dart';
import 'package:sud_qollanma/features/gamification/domain/usecases/get_leaderboard.dart';
import 'package:sud_qollanma/features/gamification/presentation/providers/gamification_provider.dart';

// Feature: Notifications (Clean Arch)
import 'package:sud_qollanma/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:sud_qollanma/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:sud_qollanma/features/notifications/domain/repositories/notification_repository.dart';
import 'package:sud_qollanma/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:sud_qollanma/features/notifications/presentation/providers/notification_notifier.dart';

// Feature: Search (Clean Arch)
import 'package:sud_qollanma/features/search/domain/usecases/search_all.dart';
import 'package:sud_qollanma/features/search/presentation/providers/search_notifier.dart';
import 'package:sud_qollanma/core/services/ai_service.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/providers/ai_notifier.dart';



// Legacy Notifiers (To be moved to core/ in future phases)
import 'package:sud_qollanma/core/providers/theme_notifier.dart';
import 'package:sud_qollanma/core/providers/locale_provider.dart';

// Legacy Screens for Routes (To be migrated to features/ in future phases)
import 'package:sud_qollanma/features/library/presentation/screens/knowledge_base_screen.dart';
import 'package:sud_qollanma/features/library/presentation/screens/video_tutorials_screen.dart';
import 'package:sud_qollanma/features/systems/presentation/screens/systems_directory_screen.dart';
import 'package:sud_qollanma/features/faq/presentation/screens/faq_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  // Crashlytics (disabled on Web)
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    MultiProvider(
      providers: [
        // --- Core Notifiers ---
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),


        // --- Feature: Gamification (Clean Arch) - MUST BE BEFORE AUTH ---
        Provider<GamificationRemoteDataSource>(create: (_) => GamificationRemoteDataSourceImpl()),
        Provider<GamificationRepository>(
          create: (context) => GamificationRepositoryImpl(
            context.read<GamificationRemoteDataSource>(),
          ),
        ),
        Provider<UpdateStreak>(create: (context) => UpdateStreak(context.read<GamificationRepository>())),
        Provider<AwardPoints>(create: (context) => AwardPoints(context.read<GamificationRepository>())),
        Provider<CalculateQuizScore>(create: (context) => CalculateQuizScore(context.read<GamificationRepository>())),
        Provider<GetLeaderboard>(create: (context) => GetLeaderboard(context.read<GamificationRepository>())),
        ChangeNotifierProvider<GamificationProvider>(
          create: (context) => GamificationProvider(
            awardPoints: context.read<AwardPoints>(),
            calculateQuizScore: context.read<CalculateQuizScore>(),
            updateStreak: context.read<UpdateStreak>(),
          ),
        ),

        // --- Feature: Auth ---
        // --- Feature: Auth ---
        Provider<AuthRemoteDataSource>(
          create: (_) => AuthRemoteDataSourceImpl(),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(
            context.read<AuthRepository>(),
            context.read<UpdateStreak>(),
          ),
        ),



        // --- Feature: Community (Clean Arch) ---
        Provider<CommunityRemoteDataSource>(create: (_) => CommunityRemoteDataSourceImpl()),
        Provider<CommunityRepository>(
          create: (context) => CommunityRepositoryImpl(
            remoteDataSource: context.read<CommunityRemoteDataSource>(),
          ),
        ),
        Provider<GetTopics>(
          create: (context) => GetTopics(context.read<CommunityRepository>()),
        ),
        Provider<CreateTopic>(
          create: (context) => CreateTopic(context.read<CommunityRepository>()),
        ),
        Provider<AddComment>(
          create: (context) => AddComment(context.read<CommunityRepository>()),
        ),
        ChangeNotifierProvider<CommunityProvider>(
          create: (context) => CommunityProvider(
            getTopics: context.read<GetTopics>(),
            createTopic: context.read<CreateTopic>(),
            addComment: context.read<AddComment>(),
            repository: context.read<CommunityRepository>(),
          ),
        ),

        // --- Feature: News (Clean Arch) ---
        Provider<NewsRemoteDataSource>(create: (_) => NewsRemoteDataSourceImpl()),
        Provider<NewsRepository>(
          create: (context) => NewsRepositoryImpl(context.read<NewsRemoteDataSource>()),
        ),
        Provider<GetNewsStream>(create: (context) => GetNewsStream(context.read<NewsRepository>())),
        Provider<AddNews>(create: (context) => AddNews(context.read<NewsRepository>())),
        Provider<UpdateNews>(create: (context) => UpdateNews(context.read<NewsRepository>())),
        Provider<DeleteNews>(create: (context) => DeleteNews(context.read<NewsRepository>())),
        ChangeNotifierProvider<NewsNotifier>(
          create: (context) => NewsNotifier(
            getNewsStream: context.read<GetNewsStream>(),
            addNewsUseCase: context.read<AddNews>(),
            updateNewsUseCase: context.read<UpdateNews>(),
            deleteNewsUseCase: context.read<DeleteNews>(),
          ),
        ),

        // --- Feature: Quiz (Clean Arch) ---
        Provider<QuizRemoteDataSource>(create: (_) => QuizRemoteDataSourceImpl()),
        Provider<QuizRepository>(
          create: (context) => QuizRepositoryImpl(
            remoteDataSource: context.read<QuizRemoteDataSource>(),
            // xApiService removed, logic moved to UseCases if needed, or pass AnalyticsRepository
            // For now, removing direct dependency, ensuring migration uses UseCases
          ),
        ),
        Provider<GetQuizzes>(
          create: (context) => GetQuizzes(context.read<QuizRepository>()),
        ),
        Provider<GetQuizById>(
          create: (context) => GetQuizById(context.read<QuizRepository>()),
        ),
        Provider<SubmitQuizAttempt>(
          create: (context) => SubmitQuizAttempt(
            context.read<QuizRepository>(),
            trackQuizCompleted: context.read<TrackQuizCompleted>(),
          ),
        ),
        Provider<GetUserAttempts>(
          create: (context) => GetUserAttempts(context.read<QuizRepository>()),
        ),
        Provider<GetRecentUserAttempts>(
          create: (context) => GetRecentUserAttempts(context.read<QuizRepository>()),
        ),
        Provider<GetQuizzesByResourceId>(
          create: (context) => GetQuizzesByResourceId(context.read<QuizRepository>()),
        ),
        Provider<DeleteQuiz>(
          create: (context) => DeleteQuiz(context.read<QuizRepository>()),
        ),
        Provider<CreateQuiz>(
          create: (context) => CreateQuiz(context.read<QuizRepository>()),
        ),
        Provider<AddQuestionToQuiz>(
          create: (context) => AddQuestionToQuiz(context.read<QuizRepository>()),
        ),
        ChangeNotifierProvider<QuizProvider>(
          create: (context) => QuizProvider(
            getQuizzes: context.read<GetQuizzes>(),
            getQuizById: context.read<GetQuizById>(),
            submitQuizAttempt: context.read<SubmitQuizAttempt>(),
            getUserAttempts: context.read<GetUserAttempts>(),
            getRecentUserAttempts: context.read<GetRecentUserAttempts>(),
            getQuizzesByResourceId: context.read<GetQuizzesByResourceId>(),
            deleteQuizUseCase: context.read<DeleteQuiz>(),
            createQuizUseCase: context.read<CreateQuiz>(),
            addQuestionToQuizUseCase: context.read<AddQuestionToQuiz>(),
          ),
        ),

        // --- Systems Feature ---
        Provider<SystemsRemoteDataSource>(
          create: (_) => SystemsRemoteDataSourceImpl(),
        ),
        ProxyProvider<SystemsRemoteDataSource, SystemsRepository>(
          update: (_, dataSource, __) => SystemsRepositoryImpl(dataSource),
        ),
        // Use Cases
        ProxyProvider<SystemsRepository, GetSystems>(
          update: (_, repo, __) => GetSystems(repo),
        ),
        ProxyProvider<SystemsRepository, GetSystemsByCategory>(
          update: (_, repo, __) => GetSystemsByCategory(repo),
        ),
        ProxyProvider<SystemsRepository, GetActiveSystems>(
          update: (_, repo, __) => GetActiveSystems(repo),
        ),
        ProxyProvider<SystemsRepository, GetSystemById>(
          update: (_, repo, __) => GetSystemById(repo),
        ),
        ProxyProvider<SystemsRepository, CreateSystem>(
          update: (_, repo, __) => CreateSystem(repo),
        ),
        ProxyProvider<SystemsRepository, UpdateSystem>(
          update: (_, repo, __) => UpdateSystem(repo),
        ),
        ProxyProvider<SystemsRepository, DeleteSystem>(
          update: (_, repo, __) => DeleteSystem(repo),
        ),
        ProxyProvider<SystemsRepository, UpdateSystemStatus>(
          update: (_, repo, __) => UpdateSystemStatus(repo),
        ),
        // Notifier
        ChangeNotifierProvider<SystemsNotifier>(
          create: (context) => SystemsNotifier(
            getSystems: context.read<GetSystems>(),
            getSystemsByCategory: context.read<GetSystemsByCategory>(),
            getActiveSystems: context.read<GetActiveSystems>(),
            getSystemById: context.read<GetSystemById>(),
            createSystem: context.read<CreateSystem>(),
            updateSystem: context.read<UpdateSystem>(),
            deleteSystem: context.read<DeleteSystem>(),
            updateSystemStatus: context.read<UpdateSystemStatus>(),
          ),
        ),

        // --- Legacy Services (Facades) ---migrated) ---
        // ChangeNotifierProvider<ResourceService>(create: (_) => ResourceService()), // REMOVED
        // Provider<CommunityService>(create: (_) => CommunityService()), // REMOVED
        // Provider<QuizService>(create: (_) => QuizService()), // REMOVED
        // Provider<NewsService>(create: (_) => NewsService()), // REMOVED
        // Provider<SystemsService>(create: (_) => SystemsService()), // REMOVED


        // --- Feature: FAQ (Clean Arch) ---
        Provider<FaqRemoteDataSource>(
          create: (_) => FaqRemoteDataSourceImpl(),
        ),
        Provider<FaqRepository>(
          create: (context) => FaqRepositoryImpl(
            remoteDataSource: context.read<FaqRemoteDataSource>(),
          ),
        ),
        // UseCases
        Provider<GetFaqs>(create: (context) => GetFaqs(context.read<FaqRepository>())),
        Provider<GetFaqsByCategory>(create: (context) => GetFaqsByCategory(context.read<FaqRepository>())),
        Provider<GetFaqsBySystem>(create: (context) => GetFaqsBySystem(context.read<FaqRepository>())),
        Provider<GetFaqById>(create: (context) => GetFaqById(context.read<FaqRepository>())),
        Provider<SearchFaqs>(create: (context) => SearchFaqs(context.read<FaqRepository>())),
        Provider<CreateFaq>(create: (context) => CreateFaq(context.read<FaqRepository>())),
        Provider<UpdateFaq>(create: (context) => UpdateFaq(context.read<FaqRepository>())),
        Provider<DeleteFaq>(create: (context) => DeleteFaq(context.read<FaqRepository>())),
        Provider<ToggleFaqHelpful>(create: (context) => ToggleFaqHelpful(context.read<FaqRepository>())),
        // Notifier
        ChangeNotifierProvider<FaqNotifier>(
          create: (context) => FaqNotifier(
            getFaqs: context.read<GetFaqs>(),
            getFaqsByCategory: context.read<GetFaqsByCategory>(),
            getFaqsBySystem: context.read<GetFaqsBySystem>(),
            getFaqById: context.read<GetFaqById>(),
            searchFaqs: context.read<SearchFaqs>(),
            createFaq: context.read<CreateFaq>(),
            updateFaq: context.read<UpdateFaq>(),
            deleteFaq: context.read<DeleteFaq>(),
            toggleFaqHelpful: context.read<ToggleFaqHelpful>(),
          ),
        ),

        // Provider<FAQService>(create: (_) => FAQService()), // Replaced by Clean Arch
        // NOTE: Quiz providers are registered above (line ~250). Do NOT duplicate here.

        // Feature: Notifications (Clean Arch)
        Provider<NotificationRemoteDataSource>(create: (_) => NotificationRemoteDataSourceImpl()),
        Provider<NotificationRepository>(
          create: (context) => NotificationRepositoryImpl(
            remoteDataSource: context.read<NotificationRemoteDataSource>(),
          ),
        ),
        // UseCases
        Provider<GetUserNotifications>(create: (context) => GetUserNotifications(context.read<NotificationRepository>())),
        Provider<GetUnreadCount>(create: (context) => GetUnreadCount(context.read<NotificationRepository>())),
        Provider<MarkNotificationAsRead>(create: (context) => MarkNotificationAsRead(context.read<NotificationRepository>())),
        Provider<MarkAllNotificationsAsRead>(create: (context) => MarkAllNotificationsAsRead(context.read<NotificationRepository>())),
        Provider<CreateNotification>(create: (context) => CreateNotification(context.read<NotificationRepository>())),
        Provider<DeleteNotification>(create: (context) => DeleteNotification(context.read<NotificationRepository>())),
        Provider<SendBulkNotification>(create: (context) => SendBulkNotification(context.read<NotificationRepository>())),
        Provider<CleanExpiredNotifications>(create: (context) => CleanExpiredNotifications(context.read<NotificationRepository>())),
        // Notifier
        ChangeNotifierProvider<NotificationNotifier>(
          create: (context) => NotificationNotifier(
            getUserNotifications: context.read<GetUserNotifications>(),
            getUnreadCount: context.read<GetUnreadCount>(),
            markNotificationAsRead: context.read<MarkNotificationAsRead>(),
            markAllNotificationsAsRead: context.read<MarkAllNotificationsAsRead>(),
            createNotification: context.read<CreateNotification>(),
            deleteNotification: context.read<DeleteNotification>(),
            sendBulkNotification: context.read<SendBulkNotification>(),
            cleanExpiredNotifications: context.read<CleanExpiredNotifications>(),
          ),
        ),

        // Feature: Library
        Provider<LibraryRepository>(create: (context) => LibraryRepositoryImpl()),
        ChangeNotifierProvider<LibraryProvider>(create: (context) => LibraryProvider(repository: context.read<LibraryRepository>())),
        


        // Feature: Analytics (Clean Arch)
        Provider<AnalyticsRemoteDataSource>(create: (_) => AnalyticsRemoteDataSourceImpl()),
        Provider<AnalyticsRepository>(create: (context) => AnalyticsRepositoryImpl(context.read<AnalyticsRemoteDataSource>())),
        // Analytics UseCases (Orchestrators)
        Provider<LogXApiStatement>(create: (context) => LogXApiStatement(
          context.read<AnalyticsRepository>(),
          context.read<GamificationRepository>(),
        )),
        Provider<TrackVideoWatched>(create: (context) => TrackVideoWatched(context.read<LogXApiStatement>())),
        Provider<TrackQuizCompleted>(create: (context) => TrackQuizCompleted(context.read<LogXApiStatement>())),

        // Feature: Search (Clean Arch)
        Provider<SearchAll>(
          create: (context) => SearchAll(
            libraryRepository: context.read<LibraryRepository>(),
            systemsRepository: context.read<SystemsRepository>(),
            faqRepository: context.read<FaqRepository>(),
          ),
        ),
        ChangeNotifierProvider<SearchNotifier>(
          create: (context) => SearchNotifier(searchAll: context.read<SearchAll>()),
        ),
        
        // Feature: AI Chat
        Provider<AiService>(create: (_) => AiService()),
        ChangeNotifierProvider<AiNotifier>(
          create: (context) => AiNotifier(context.read<AiService>()),
        ),

        // Notifier
        // ChangeNotifierProvider<GamificationNotifier>(...) // If needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      onGenerateTitle: (BuildContext context) {
        return AppLocalizations.of(context)?.appTitle ?? 'Sud Qo\'llanmasi';
      },
      themeMode: themeNotifier.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: localeProvider.appLocale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('uz', ''),
        Locale('ru', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // NEW: Using AuthWrapper as home
      home: const AuthWrapper(),
      routes: {
        '/knowledge_base': (context) => const KnowledgeBaseScreen(),
        '/video_tutorials': (context) => const VideoTutorialsScreen(),
        '/systems': (context) => const SystemsDirectoryScreen(),
        '/faq': (context) => const FaqListScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
