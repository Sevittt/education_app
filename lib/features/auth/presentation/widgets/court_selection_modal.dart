import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/data/uzbekistan_courts.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/core/utils/court_localizer.dart';

/// Bottom sheet that forces existing users to select their court.
/// Cannot be dismissed — selection is mandatory.
class CourtSelectionModal extends StatefulWidget {
  const CourtSelectionModal({super.key});

  @override
  State<CourtSelectionModal> createState() => _CourtSelectionModalState();
}

class _CourtSelectionModalState extends State<CourtSelectionModal> {
  final _formKey = GlobalKey<FormState>();

  RegionInfo? _selectedRegion;
  CourtType? _selectedCourtType;
  CourtInfo? _selectedCourt;

  List<CourtType> get _availableTypes {
    if (_selectedRegion == null) return [];
    return _selectedRegion!.availableTypes;
  }

  List<CourtInfo> get _filteredCourts {
    if (_selectedRegion == null || _selectedCourtType == null) return [];
    return _selectedRegion!.courtsByType(_selectedCourtType!);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourt == null) return;

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final success = await authNotifier.updateUserCourt(
      courtId: _selectedCourt!.id,
      courtName: _selectedCourt!.name,
      courtTypeId: _selectedCourtType!.id,
      courtTypeName: _selectedCourtType!.displayName,
      regionId: _selectedRegion!.id,
      regionName: _selectedRegion!.name,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authNotifier.errorMessage ?? 'Xatolik yuz berdi'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  InputDecoration _dec(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authNotifier = Provider.of<AuthNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      // Prevent back-navigation — court selection is mandatory
      canPop: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.selectYourCourtTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.selectYourCourtSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Step 1: Region
                          _StepLabel(step: '1', label: l10n.selectRegionLabel),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<RegionInfo>(
                            key: const ValueKey('modal_region_dropdown'),
                            initialValue: _selectedRegion,
                            isExpanded: true,
                            decoration: _dec(l10n.regionDropdownLabel, Icons.map_outlined),
                            items: UzbekistanCourts.regions
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r.localizedName(context), overflow: TextOverflow.ellipsis, maxLines: 1),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _selectedRegion = v;
                              _selectedCourtType = null;
                              _selectedCourt = null;
                            }),
                            validator: (v) =>
                                v == null ? l10n.selectRegionLabel : null,
                          ),
                          const SizedBox(height: 20),

                          // Step 2: Court Type
                          _StepLabel(step: '2', label: l10n.selectCourtTypeLabel),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<CourtType>(
                            key: ValueKey('modal_type_${_selectedRegion?.id ?? "none"}'),
                            initialValue: _selectedCourtType,
                            isExpanded: true,
                            decoration: _dec(l10n.courtTypeDropdownLabel, Icons.category_outlined),
                            items: _availableTypes
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text('${t.icon} ${t.localizedDisplayName(context)}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                    ))
                                .toList(),
                            onChanged: _selectedRegion == null
                                ? null
                                : (v) => setState(() {
                                      _selectedCourtType = v;
                                      _selectedCourt = null;
                                    }),
                            validator: (v) =>
                                v == null ? l10n.selectCourtTypeLabel : null,
                            hint: _selectedRegion == null
                                ? Text(l10n.selectRegionFirst,
                                    style: const TextStyle(fontSize: 13))
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Step 3: Specific Court
                          _StepLabel(step: '3', label: l10n.selectSpecificCourtLabel),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<CourtInfo>(
                            key: ValueKey('modal_court_${_selectedCourtType?.id ?? "none"}'),
                            initialValue: _selectedCourt,
                            isExpanded: true,
                            decoration: _dec(l10n.specificCourtDropdownLabel, Icons.account_balance_outlined),
                            items: _filteredCourts
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c.localizedName(context),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: _selectedCourtType == null
                                ? null
                                : (v) => setState(() => _selectedCourt = v),
                            validator: (v) =>
                                v == null ? l10n.selectSpecificCourtLabel : null,
                            hint: _selectedCourtType == null
                                ? Text(l10n.selectCourtTypeFirst,
                                    style: const TextStyle(fontSize: 13))
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          ElevatedButton.icon(
                            icon: authNotifier.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              authNotifier.isLoading ? l10n.savingInProgress : l10n.saveAndContinue,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: authNotifier.isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String step;
  final String label;
  const _StepLabel({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
