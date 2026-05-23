import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/core/data/uzbekistan_courts.dart';
import 'package:sud_qollanma/core/utils/court_localizer.dart';
import 'package:sud_qollanma/shared/widgets/language_switcher.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const RegistrationScreen({super.key, required this.onSwitchToLogin});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  CourtRole? _selectedRole;

  // Court selection (cascade)
  RegionInfo? _selectedRegion;
  CourtType? _selectedCourtType;
  CourtInfo? _selectedCourt;

  List<CourtType> get _availableCourtTypes {
    if (_selectedRegion == null) return [];
    return _selectedRegion!.availableTypes;
  }

  List<CourtInfo> get _filteredCourts {
    if (_selectedRegion == null || _selectedCourtType == null) return [];
    return _selectedRegion!.courtsByType(_selectedCourtType!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      _showError(AppLocalizations.of(context)!.registrationRoleError);
      return;
    }
    if (_selectedCourt == null) {
      _showError("Iltimos, o'zingizning sudingizni tanlang");
      return;
    }

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    final success = await authNotifier.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole!,
      courtId: _selectedCourt!.id,
      courtName: _selectedCourt!.name,
      courtTypeId: _selectedCourtType!.id,
      courtTypeName: _selectedCourtType!.displayName,
      regionId: _selectedRegion!.id,
      regionName: _selectedRegion!.name,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (authNotifier.errorMessage != null) {
      _showError(authNotifier.errorMessage!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _googleSignIn() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final success = await authNotifier.signInWithGoogle();
    if (success) {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted && authNotifier.errorMessage != null) {
      _showError(authNotifier.errorMessage!);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      filled: true,
      fillColor: colorScheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authNotifier = Provider.of<AuthNotifier>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.registrationTitle,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.registrationSubtitle,
                    style: textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: _fieldDecoration(
                      label: l10n.registrationFullNameLabel,
                      icon: Icons.person_outline,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.registrationFullNameError
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: _fieldDecoration(
                      label: l10n.emailLabel,
                      icon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null ||
                          v.trim().isEmpty ||
                          !RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(v)) {
                        return l10n.registrationEmailError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role
                  DropdownButtonFormField<CourtRole>(
                    initialValue: _selectedRole,
                    decoration: _fieldDecoration(
                      label: l10n.registrationRoleLabel,
                      icon: Icons.work_outline,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: CourtRole.judge,
                        child: Text(l10n.registrationRoleJudge),
                      ),
                      DropdownMenuItem(
                        value: CourtRole.assistant,
                        child: Text(l10n.registrationRoleAssistant, overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      DropdownMenuItem(
                        value: CourtRole.chancellery,
                        child: Text(l10n.registrationRoleChancellery, overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      DropdownMenuItem(
                        value: CourtRole.archive,
                        child: Text(l10n.registrationRoleArchive, overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      DropdownMenuItem(
                        value: CourtRole.ict_specialist,
                        child: Text(l10n.registrationRoleIctSpecialist, overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedRole = v),
                    validator: (v) =>
                        v == null ? l10n.registrationRoleError : null,
                  ),
                  const SizedBox(height: 24),

                  // --- Court Selection Section ---
                  _SectionHeader(
                    icon: Icons.location_on_outlined,
                    label: l10n.courtDataHeader,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),

                  // Step 1: Region
                  DropdownButtonFormField<RegionInfo>(
                    key: ValueKey('region_dropdown'),
                    initialValue: _selectedRegion,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      label: l10n.regionDropdownLabel,
                      icon: Icons.map_outlined,
                    ),
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
                        v == null ? 'Iltimos, hududni tanlang' : null,
                  ),
                  const SizedBox(height: 12),

                  // Step 2: Court Type
                  DropdownButtonFormField<CourtType>(
                    key: ValueKey('type_${_selectedRegion?.id ?? "none"}'),
                    initialValue: _selectedCourtType,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      label: l10n.courtTypeDropdownLabel,
                      icon: Icons.category_outlined,
                    ),
                    items: _availableCourtTypes
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
                        v == null ? 'Iltimos, sud turini tanlang' : null,
                    hint: _selectedRegion == null
                        ? Text(l10n.selectRegionFirst,
                            style: const TextStyle(fontSize: 13))
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Step 3: Specific Court
                  DropdownButtonFormField<CourtInfo>(
                    key: ValueKey('court_${_selectedCourtType?.id ?? "none"}'),
                    initialValue: _selectedCourt,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      label: l10n.specificCourtDropdownLabel,
                      icon: Icons.account_balance_outlined,
                    ),
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
                        v == null ? "Iltimos, aniq sudni tanlang" : null,
                    hint: _selectedCourtType == null
                        ? Text(l10n.selectCourtTypeFirst,
                            style: const TextStyle(fontSize: 13))
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: _fieldDecoration(
                      label: l10n.registrationPasswordLabel,
                      icon: Icons.lock_outline,
                    ),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? l10n.registrationPasswordError
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: _fieldDecoration(
                      label: l10n.registrationConfirmPasswordLabel,
                      icon: Icons.lock_outline,
                    ),
                    obscureText: true,
                    validator: (v) => v != _passwordController.text
                        ? l10n.registrationConfirmPasswordError
                        : null,
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  ElevatedButton(
                    onPressed: authNotifier.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: authNotifier.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(l10n.registrationSignUpButton),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: colorScheme.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(l10n.orDivider,
                            style: textTheme.labelMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ),
                      Expanded(
                          child: Divider(color: colorScheme.outlineVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In
                  ElevatedButton.icon(
                    icon: Image.asset('assets/images/goog_logo.png',
                        height: 22.0),
                    label: Text(l10n.signInWithGoogle),
                    onPressed: _googleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainer,
                      foregroundColor: colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: widget.onSwitchToLogin,
                    child: Text(l10n.registrationSwitchToLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        right: 16,
        child: const LanguageSwitcher(),
      ),
    ],
  ),
);
  }
}

/// Section header widget for grouping form fields
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withValues(alpha: 0.3))),
      ],
    );
  }
}
