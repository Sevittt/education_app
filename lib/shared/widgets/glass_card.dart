import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';

/// A clean Material card — no blur, no glass.
/// In light mode: white surface with soft shadow.
/// In dark mode: navy surface (#152032) with border.
///
/// [isHighlighted]: draws an amber border — used for leaderboard top-3, etc.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isHighlighted;

  // Legacy params — accepted but ignored (backward compat with old call sites)
  // ignore: avoid_unused_constructor_parameters
  final LinearGradient? gradient;
  // ignore: avoid_unused_constructor_parameters
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.onTap,
    this.isHighlighted = false,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final border  = isHighlighted
        ? const BorderSide(color: AppColors.amber, width: 1.5)
        : BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          );

    final splash    = isDark
        ? AppColors.amber.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.06);
    final highlight = isDark
        ? AppColors.amber.withValues(alpha: 0.04)
        : AppColors.primary.withValues(alpha: 0.03);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.fromBorderSide(border),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: splash,
          highlightColor: highlight,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
