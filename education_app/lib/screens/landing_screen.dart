import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'auth/login_screen.dart';
import 'auth/registration_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout decision
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

    // Ensure status bar style matches the background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Section
          const _HeroSection(isMobile: true),
          
          // Features
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _FeatureCard(
                  icon: Icons.library_books_rounded,
                  title: l10n?.featureKnowledgeBase ?? 'Knowledge Base',
                  description: l10n?.featureKnowledgeBaseDesc ?? 'Access a vast library of legal resources.',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.play_circle_fill_rounded,
                  title: l10n?.featureVideoTutorials ?? 'Video Tutorials',
                  description: l10n?.featureVideoTutorialsDesc ?? 'Learn from expert-led video guides.',
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.emoji_events_rounded,
                  title: l10n?.featureGamification ?? 'Gamification',
                  description: l10n?.featureGamificationDesc ?? 'Earn XP and compete on the leaderboard.',
                  color: Colors.amber,
                ),
              ],
            ),
          ),
          
          // Footer
          const _Footer(),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        // Left Side: Hero
        const Expanded(
          flex: 5,
          child: _HeroSection(isMobile: false),
        ),
        
        // Right Side: Features & Content
        Expanded(
          flex: 4,
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.landingTitle ?? 'Professional Platform',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                     _FeatureCard(
                      icon: Icons.library_books_rounded,
                      title: l10n?.featureKnowledgeBase ?? 'Knowledge Base',
                      description: l10n?.featureKnowledgeBaseDesc ?? 'Access a vast library of legal resources.',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    _FeatureCard(
                      icon: Icons.play_circle_fill_rounded,
                      title: l10n?.featureVideoTutorials ?? 'Video Tutorials',
                      description: l10n?.featureVideoTutorialsDesc ?? 'Learn from expert-led video guides.',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    _FeatureCard(
                      icon: Icons.emoji_events_rounded,
                      title: l10n?.featureGamification ?? 'Gamification',
                      description: l10n?.featureGamificationDesc ?? 'Earn XP and compete on the leaderboard.',
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 48),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: isMobile ? 60.0 : 40.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Hero(
            tag: 'app_logo',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/app_logo.png',
                height: isMobile ? 120 : 180,
                width: isMobile ? 120 : 180,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Headline
          Text(
            l10n?.landingTitle ?? 'Professional Platform',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: isMobile ? 24 : 36,
            ),
          ),
          const SizedBox(height: 16),
          
          // Subheadline
          Text(
            l10n?.landingSubtitle ?? 'Elevate your legal knowledge.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 16 : 20,
            ),
          ),
          const SizedBox(height: 48),
          
          // CTAs
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(l10n?.landingLogin ?? 'Login'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _navigateToRegister(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.primary, width: 2),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n?.landingRegister ?? 'Register'),
                ),
              ],
            ),
          ),
        ],
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
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
