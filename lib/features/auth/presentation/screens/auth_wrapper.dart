import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/presentation/widgets/court_selection_modal.dart';
import 'package:sud_qollanma/features/home/presentation/screens/home_page.dart';
import 'package:sud_qollanma/features/auth/presentation/screens/landing_screen.dart';
import 'package:sud_qollanma/core/widgets/app_splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _modalShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        // Firebase auth holati aniqlanmaguncha splash ko'rsatamiz
        if (!authNotifier.isInitialized) {
          return const AppSplashScreen();
        }

        if (authNotifier.isAuthenticated) {
          final user = authNotifier.appUser!;

          // If user hasn't selected a court yet, show mandatory modal
          if (!user.hasCourtSelected && !_modalShown) {
            // Schedule after current build frame to avoid setState in build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_modalShown) {
                _modalShown = true;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,       // Cannot be dismissed by tapping outside
                  enableDrag: false,           // Cannot be dragged to close
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: authNotifier,
                    child: const CourtSelectionModal(),
                  ),
                ).then((_) {
                  // Reset flag so modal re-shows if user somehow still has no court
                  if (mounted) setState(() => _modalShown = false);
                });
              }
            });
          }

          return const HomePage();
        } else {
          _modalShown = false;
          return const LandingScreen();
        }
      },
    );
  }
}
