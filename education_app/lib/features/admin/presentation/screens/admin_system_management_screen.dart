import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/custom_network_image.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/presentation/providers/systems_notifier.dart';
import 'admin_add_edit_system_screen.dart';

class AdminSystemManagementScreen extends StatefulWidget {
  const AdminSystemManagementScreen({super.key});

  @override
  State<AdminSystemManagementScreen> createState() => _AdminSystemManagementScreenState();
}

class _AdminSystemManagementScreenState extends State<AdminSystemManagementScreen> {

  Future<void> _deleteSystem(SudSystemEntity system) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = Provider.of<SystemsNotifier>(context, listen: false);

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
      try {
        await notifier.deleteSystem(system.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.systemDeletedSuccess)),
          );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorPrefix + e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = Provider.of<SystemsNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageSystemsTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SudSystemEntity>>(
        stream: notifier.systemsStream,
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
                      ? CustomNetworkImage(
                          imageUrl: system.logoUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.computer, size: 40),
                  title: Text(
                    system.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Assuming category has displayName or using switch if removed from Entity
                  subtitle: Text(system.category.name), 
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddEditSystemScreen(),
            ),
          );
        },
        tooltip: l10n.add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
