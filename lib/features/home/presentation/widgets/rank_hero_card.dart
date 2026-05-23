import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import 'rank_ring_painter.dart';

class RankHeroCard extends StatefulWidget {
  final AppUser user;

  const RankHeroCard({super.key, required this.user});

  @override
  State<RankHeroCard> createState() => _RankHeroCardState();
}

class _RankHeroCardState extends State<RankHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ring;
  late final Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    final target = AppUser.getLevelProgress(widget.user.xp);
    _ring = Tween<double>(begin: 0.0, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final nextXp = AppUser.xpToNextLevel(u.xp);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rankColor = u.level.levelColor;
    final screenW = MediaQuery.of(context).size.width;

    // Premium deep gradient — dark: navy→midnight, light: indigo→violet
    final gradientColors = isDark
        ? [const Color(0xFF0D1B2E), const Color(0xFF112240), const Color(0xFF0A1628)]
        : [const Color(0xFF3B4FCC), const Color(0xFF5A3FC7), const Color(0xFF2E3CB5)];

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideUp.value),
          child: Opacity(
            opacity: (1 - _slideUp.value / 30).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(
            color: rankColor.withValues(alpha: isDark ? 0.35 : 0.22),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: 0.22),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: (isDark ? const Color(0xFF0D1B2E) : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/bg_legal_docs.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Decorative orbs
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rankColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: screenW * 0.3,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: greeting + streak ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xush kelibsiz 👋',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              u.name.split(' ').first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        // Streak pill
                        _StreakBadge(streak: u.currentStreak),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── Ring + XP info ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Progress ring
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: AnimatedBuilder(
                            animation: _ring,
                            builder: (_, __) => CustomPaint(
                              painter: RankRingPainter(
                                progress: _ring.value,
                                trackColor: Colors.white.withValues(alpha: 0.1),
                                progressColor: rankColor,
                                strokeWidth: 8.0,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      u.level.levelBadge,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${(_ring.value * 100).toInt()}%',
                                      style: TextStyle(
                                        color: rankColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        // XP & rank labels
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rank badge pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: rankColor.withValues(alpha: 0.18),
                                  border: Border.all(
                                    color: rankColor.withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  u.level.levelLabel,
                                  style: TextStyle(
                                    color: rankColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // XP big number
                              Text(
                                '${u.xp}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                              ),
                              const Text(
                                'XP ball',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Next level hint
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      nextXp > 0
                                          ? 'Keyingi maqomga +$nextXp XP'
                                          : 'Eng yuqori daraja! 🏆',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Progress bar ──
                    const SizedBox(height: 20),
                    _XpProgressBar(
                      progress: AppUser.getLevelProgress(u.xp),
                      color: rankColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Streak badge ──────────────────────────────────────────────────────────────
class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isHot = streak >= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: isHot
            ? const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF9A3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isHot ? null : Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: isHot
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak >= 7 ? '🔥' : streak >= 3 ? '⚡' : '❄️',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 5),
          Text(
            '$streak kun',
            style: TextStyle(
              color: isHot ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── XP progress bar ──────────────────────────────────────────────────────────
class _XpProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  const _XpProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maqom progressi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                // Track
                Container(
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
