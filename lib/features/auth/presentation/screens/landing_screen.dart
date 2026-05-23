import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/auth/presentation/screens/login_screen.dart';
import 'package:sud_qollanma/features/auth/presentation/screens/registration_screen.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:sud_qollanma/shared/widgets/animated_button.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const _DesktopLayout();
          } else {
            return const _MobileLayout();
          }
        },
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        image: DecorationImage(
          image: const AssetImage('assets/images/Shared_Knowledge.png'),
          fit: BoxFit.cover,
          opacity: isDark ? 0.05 : 0.03, // Subtle texture
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroSection(isMobile: true),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: Column(
                children: [
                  _FeatureCard(
                    icon: Icons.library_books_rounded,
                    title: l10n?.featureKnowledgeBase ?? 'Knowledge Base',
                    description: l10n?.featureKnowledgeBaseDesc ??
                        'Access a vast library of legal resources.',
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 16),
                  _FeatureCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: l10n?.featureVideoTutorials ?? 'Video Tutorials',
                    description: l10n?.featureVideoTutorialsDesc ??
                        'Learn from expert-led video guides.',
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  _FeatureCard(
                    icon: Icons.emoji_events_rounded,
                    title: l10n?.featureGamification ?? 'Gamification',
                    description: l10n?.featureGamificationDesc ??
                        'Earn XP and compete on the leaderboard.',
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        image: DecorationImage(
          image: const AssetImage('assets/images/Shared_Knowledge.png'),
          fit: BoxFit.cover,
          opacity: isDark ? 0.05 : 0.03,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: _HeroSection(isMobile: false),
          ),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FeatureCard(
                    icon: Icons.library_books_rounded,
                    title: l10n?.featureKnowledgeBase ?? 'Knowledge Base',
                    description: l10n?.featureKnowledgeBaseDesc ??
                        'Access a vast library of legal resources.',
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 24),
                  _FeatureCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: l10n?.featureVideoTutorials ?? 'Video Tutorials',
                    description: l10n?.featureVideoTutorialsDesc ??
                        'Learn from expert-led video guides.',
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 24),
                  _FeatureCard(
                    icon: Icons.emoji_events_rounded,
                    title: l10n?.featureGamification ?? 'Gamification',
                    description: l10n?.featureGamificationDesc ??
                        'Earn XP and compete on the leaderboard.',
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 48),
                  const _Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isMobile;

  const _HeroSection({required this.isMobile});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(
          onSwitchToLogin: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: isMobile ? 60.0 : 40.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Keep column compact
          children: [
            // Logo with Glass Effect
            Hero(
              tag: 'app_logo',
              child: GlassCard(
                borderRadius: 100,
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: isMobile ? 100 : 160,
                  width: isMobile ? 100 : 160,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Headline
            Text(
              l10n?.landingTitle ?? 'Professional Platform',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Subheadline
            Text(
              l10n?.landingSubtitle ??
                  'Elevate your legal knowledge. Anytime. Anywhere.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 16 : 20,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // CTAs — use theme primary (indigo in light, amber in dark)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () => _navigateToLogin(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n?.landingLogin ?? 'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _navigateToRegister(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n?.landingRegister ?? 'Register',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Text(
        '© $year Court Handbook Project',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
