import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';

class DashboardStatsRow extends StatelessWidget {
  final AppUser user;

  const DashboardStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.check_circle_rounded,
            value: '${user.simulationsCompleted}',
            label: 'Tugatilgan',
            gradientColors: const [Color(0xFF27AE7A), Color(0xFF1DB860)],
            iconBg: const Color(0xFF0F3D2A),
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.quiz_rounded,
            value: '${user.quizzesPassed}',
            label: 'Viktorina',
            gradientColors: const [Color(0xFFC9A84C), Color(0xFFE8C96E)],
            iconBg: const Color(0xFF2A2210),
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.bolt_rounded,
            value: '${user.xp}',
            label: 'XP ball',
            gradientColors: const [Color(0xFF5B6EE8), Color(0xFF7C8FF5)],
            iconBg: const Color(0xFF0F1A3D),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradientColors;
  final Color iconBg;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradientColors,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = gradientColors.first;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border.all(
            color: isDark
                ? accentColor.withValues(alpha: 0.2)
                : accentColor.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.1 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with gradient background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 12),

            // Value
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 3),

            // Label
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
