import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/presentation/providers/systems_notifier.dart';
import 'package:sud_qollanma/features/systems/presentation/screens/system_detail_screen.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

/// "Tizim holati / Sud tizimlari" section showing real-time court system statuses
/// and opening each system's hub on tap.
class AdminStatSection extends StatelessWidget {
  const AdminStatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final systemsNotifier = Provider.of<SystemsNotifier>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l10n.dashboardAdminTitle,
          actionLabel: l10n.dsSeeAll,
          onAction: () => Navigator.pushNamed(context, '/systems'),
        ),
        const SizedBox(height: AppSpace.s12),
        StreamBuilder<List<SudSystemEntity>>(
          stream: systemsNotifier.systemsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingGrid();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final systems = snapshot.data!;
            final displaySystems = systems.take(3).toList();

            return Row(
              children: [
                for (var i = 0; i < displaySystems.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpace.s12),
                  Expanded(
                    child: _SystemStatusCard(system: displaySystems[i]),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SystemStatusCard extends StatefulWidget {
  final SudSystemEntity system;

  const _SystemStatusCard({required this.system});

  @override
  State<_SystemStatusCard> createState() => _SystemStatusCardState();
}

class _SystemStatusCardState extends State<_SystemStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isActive = widget.system.status == SystemStatus.active;
    final accentColor = isActive ? t.successSolid : t.dangerSolid;
    final containerColor = isActive ? t.successContainer : t.dangerContainer;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s16, horizontal: AppSpace.s12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SystemDetailScreen(system: widget.system),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    return Container(
                      width: 36 + (10 * _pulseCtrl.value),
                      height: 36 + (10 * _pulseCtrl.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.18 * (1 - _pulseCtrl.value)),
                      ),
                    );
                  },
                ),
              IconTile(
                isActive ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 36,
                circle: true,
                background: containerColor,
                foreground: accentColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s12),
          Text(
            widget.system.name,
            style: text.titleSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isActive ? l10n.statusOnline : l10n.statusOffline,
            style: text.labelSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Container(
            height: 108,
            margin: EdgeInsets.only(left: i == 0 ? 0 : AppSpace.s12),
            decoration: BoxDecoration(
              color: t.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: t.borderDefault),
            ),
          ),
        ),
      ),
    );
  }
}
