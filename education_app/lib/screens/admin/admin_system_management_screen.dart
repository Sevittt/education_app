import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/sud_system.dart';
import '../../services/systems_service.dart';
import 'admin_add_edit_system_screen.dart';

class AdminSystemManagementScreen extends StatefulWidget {
  const AdminSystemManagementScreen({super.key});

  @override
  State<AdminSystemManagementScreen> createState() => _AdminSystemManagementScreenState();
}

class _AdminSystemManagementScreenState extends State<AdminSystemManagementScreen> {
  final SystemsService _service = SystemsService();

  Future<void> _deleteSystem(SudSystem system) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteSystemMessage(system.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _service.deleteSystem(system.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.systemDeletedSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageSystemsTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SudSystem>>(
        stream: _service.getAllSystems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.errorPrefix}${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final systems = snapshot.data ?? [];

          if (systems.isEmpty) {
            return Center(child: Text(l10n.noSystemsFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: systems.length,
            itemBuilder: (context, index) {
              final system = systems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: system.logoUrl != null && system.logoUrl!.isNotEmpty
                      ? Image.network(
                          system.logoUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.computer, size: 40),
                        )
                      : const Icon(Icons.computer, size: 40),
                  title: Text(
                    system.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(system.category.displayName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAddEditSystemScreen(system: system),
                            ),
                          );
                        },
                        tooltip: l10n.editResourceTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSystem(system),
                        tooltip: l10n.deleteResourceTooltip,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddEditSystemScreen(),
            ),
          );
        },
        tooltip: l10n.add,
      ),
    );
  }
}
