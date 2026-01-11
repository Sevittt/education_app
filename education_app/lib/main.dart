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
import 'firebase_options.dart';

// Localization
import 'package:sud_qollanma/l10n/app_localizations.dart';

// Core Layer
import 'package:sud_qollanma/core/theme/app_theme.dart';

// Feature: Auth
import 'package:sud_qollanma/features/auth/data/datasources/auth_service.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/presentation/screens/auth_wrapper.dart';

// Feature: Library
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';

// Legacy Services (To be migrated to features/ in future phases)
import 'package:sud_qollanma/services/community_service.dart';
import 'package:sud_qollanma/services/news_service.dart';
import 'package:sud_qollanma/services/profile_service.dart';
import 'package:sud_qollanma/services/quiz_service.dart';
import 'package:sud_qollanma/services/resource_service.dart';
import 'package:sud_qollanma/services/systems_service.dart';
import 'package:sud_qollanma/services/faq_service.dart';
import 'package:sud_qollanma/services/notification_service.dart';

// Legacy Notifiers (To be moved to core/ in future phases)
import 'package:sud_qollanma/models/theme_notifier.dart';
import 'package:sud_qollanma/models/locale_notifier.dart';

// Legacy Screens for Routes (To be migrated to features/ in future phases)
import 'package:sud_qollanma/screens/knowledge_base/knowledge_base_screen.dart';
import 'package:sud_qollanma/screens/resource/video_tutorials_screen.dart';
import 'package:sud_qollanma/screens/systems/systems_directory_screen.dart';
import 'package:sud_qollanma/screens/faq/faq_list_screen.dart';

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
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),

        // --- Feature: Auth ---
        Provider<ProfileService>(create: (_) => ProfileService()),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ProfileService>()),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(
            context.read<AuthService>(),
            context.read<ProfileService>(),
          ),
        ),

        // --- Feature: Library ---
        ChangeNotifierProvider<LibraryProvider>(create: (_) => LibraryProvider()),

        // --- Legacy Services (To be migrated) ---
        ChangeNotifierProvider<ResourceService>(create: (_) => ResourceService()),
        Provider<CommunityService>(create: (_) => CommunityService()),
        Provider<QuizService>(create: (_) => QuizService()),
        Provider<NewsService>(create: (_) => NewsService()),
        Provider<SystemsService>(create: (_) => SystemsService()),
        Provider<FAQService>(create: (_) => FAQService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
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
    final localeNotifier = context.watch<LocaleNotifier>();

    return MaterialApp(
      onGenerateTitle: (BuildContext context) {
        return AppLocalizations.of(context)?.appTitle ?? 'Sud Qo\'llanmasi';
      },
      themeMode: themeNotifier.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: localeNotifier.appLocale,
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
        '/faq': (context) => const FAQListScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
