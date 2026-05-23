import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: Center(child: Text(l10n.changePasswordHint)),
    );
  }
}
