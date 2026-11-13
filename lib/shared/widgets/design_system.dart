import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';

/// Figma dizayn tizimidagi asosiy komponentlar (Belgi, Progress, Boʻlim
/// sarlavhasi, Karta, Pastki panel). Ranglar faqat [AppTokens] dan olinadi.

enum BadgeTone { brand, success, warning, danger, gold, neutral }

extension _ToneColors on BadgeTone {
  (Color, Color) colors(AppTokens t) => switch (this) {
        BadgeTone.brand => (t.brandContainer, t.brandOnContainer),
        BadgeTone.success => (t.successContainer, t.successSolid),
        BadgeTone.warning => (t.streakContainer, t.streakSolid),
        BadgeTone.danger => (t.dangerContainer, t.dangerSolid),
        BadgeTone.gold => (t.goldContainer, t.goldInk),
        BadgeTone.neutral => (t.bgSubtle, t.textSecondary),
      };
}

/// Holat va metaxususiyat belgisi: qiyinlik, seriya, sertifikat, natija.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  final IconData? icon;

  const StatusBadge(this.label, {super.key, this.tone = BadgeTone.brand, this.icon});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = tone.colors(context.tokens);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// 6px progress chizigʻi.
class ProgressLine extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? trackColor;
  final double height;

  const ProgressLine({super.key, required this.value, this.color, this.trackColor, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color ?? t.brandPrimary,
        backgroundColor: trackColor ?? t.bgSubtle,
      ),
    );
  }
}

/// Foiz halqasi (kurs progressi, test natijasi, kunlik maqsad).
class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double thickness;
  final Color? color;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.thickness = 6,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0.0, 1.0), thickness, color ?? t.brandPrimary, t.bgSubtle),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double thickness;
  final Color color;
  final Color track;

  _RingPainter(this.value, this.thickness, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(thickness / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = track;
    canvas.drawArc(inset, 0, math.pi * 2, false, paint);
    if (value > 0) {
      canvas.drawArc(inset, -math.pi / 2, math.pi * 2 * value, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track || old.thickness != thickness;
}

/// Boʻlim sarlavhasi: "Mening kurslarim ……… Barchasi".
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(title, style: text.titleLarge)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: text.labelLarge?.copyWith(color: context.tokens.brandPrimary)),
          ),
      ],
    );
  }
}

/// Oq/qorongʻi sirtli, chegarali karta (radius 16, padding 16).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool border;
  final double radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.s16),
    this.color,
    this.border = true,
    this.radius = AppRadius.lg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border ? BorderSide(color: t.borderDefault) : BorderSide.none,
    );
    return Material(
      color: color ?? t.bgSurface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Rangli fonli ikonka plitkasi (kurs ikonkasi, statistika belgisi).
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final bool circle;

  const IconTile(
    this.icon, {
    super.key,
    required this.background,
    required this.foreground,
    this.size = 40,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: size / 2, color: foreground),
    );
  }
}

/// 40px aylana ikonka tugmasi (qidiruv, bildirishnoma, orqaga).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final String? tooltip;
  final bool showDot;

  const CircleIconButton(
    this.icon, {
    super.key,
    this.onPressed,
    this.iconColor,
    this.tooltip,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final button = Material(
      color: t.bgSurface,
      shape: CircleBorder(side: BorderSide(color: t.borderDefault)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: iconColor ?? t.textPrimary),
        ),
      ),
    );
    return Tooltip(
      message: tooltip ?? '',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (showDot)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: t.dangerSolid,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.bgSurface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ekran pastidagi asosiy harakat paneli (bitta "Asosiy" tugma qoidasi).
class StickyActionBar extends StatelessWidget {
  final List<Widget> children;
  final String? caption;

  const StickyActionBar({super.key, required this.children, this.caption});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.borderDefault)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F1B2D).withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s12, AppSpace.s16, AppSpace.s12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (caption != null) ...[
              Text(caption!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textTertiary)),
              const SizedBox(height: AppSpace.s8),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
