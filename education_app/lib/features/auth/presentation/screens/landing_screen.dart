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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: Column(
                children: [
                  _FeatureCard(
                    icon: Icons.library_books_rounded,
                    title: l10n?.featureKnowledgeBase ?? 'Knowledge Base',
                    description: l10n?.featureKnowledgeBaseDesc ?? 'Access a vast library of legal resources.',
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 16),
                  _FeatureCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: l10n?.featureVideoTutorials ?? 'Video Tutorials',
                    description: l10n?.featureVideoTutorialsDesc ?? 'Learn from expert-led video guides.',
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  _FeatureCard(
                    icon: Icons.emoji_events_rounded,
                    title: l10n?.featureGamification ?? 'Gamification',
                    description: l10n?.featureGamificationDesc ?? 'Earn XP and compete on the leaderboard.',
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
                  Text(
                    l10n?.landingTitle ?? 'Professional Platform',
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _FeatureCard(
                    icon: Icons.library_books_rounded,
                    title: l10n?.featureKnowledgeBase ?? 'Knowledge Base',
                    description: l10n?.featureKnowledgeBaseDesc ?? 'Access a vast library of legal resources.',
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 24),
                  _FeatureCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: l10n?.featureVideoTutorials ?? 'Video Tutorials',
                    description: l10n?.featureVideoTutorialsDesc ?? 'Learn from expert-led video guides.',
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 24),
                  _FeatureCard(
                    icon: Icons.emoji_events_rounded,
                    title: l10n?.featureGamification ?? 'Gamification',
                    description: l10n?.featureGamificationDesc ?? 'Earn XP and compete on the leaderboard.',
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

    return Stack(
      children: [
        // Decorative Background Elements
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
         Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: isMobile ? 80.0 : 40.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subheadline
              Text(
                l10n?.landingSubtitle ?? 'Elevate your legal knowledge.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 20,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 56),
              
              // CTAs
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedButton(
                      onPressed: () => _navigateToLogin(context),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          l10n?.landingLogin ?? 'Login',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      onPressed: () => _navigateToRegister(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          l10n?.landingRegister ?? 'Register',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
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
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

