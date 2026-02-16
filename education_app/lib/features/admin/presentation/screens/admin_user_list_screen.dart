import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:sud_qollanma/l10n/app_localizations.dart';

import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';
import 'package:sud_qollanma/features/auth/domain/repositories/auth_repository.dart';

class AdminAppUserListScreen extends StatelessWidget {
  const AdminAppUserListScreen({super.key});

  String? _getRoleName(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.xodim:
        return l10n.roleXodim;
      case UserRole.ekspert:
        return l10n.roleEkspert;
      case UserRole.admin:
        return l10n.roleAdmin;
    }
  }

  // Color for role badge
  Color _getRoleColor(UserRole role, ColorScheme colorScheme) {
    switch (role) {
      case UserRole.admin:
        return colorScheme.error;
      case UserRole.ekspert:
        return colorScheme.tertiary;
      case UserRole.xodim:
        return colorScheme.secondary;
    }
  }

  // Show role change dialog
  Future<void> _showRoleChangeDialog(
    BuildContext context,
    AppUser user,
    AuthRepository authRepository,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<UserRole>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${user.name} — ${l10n.roleLabel}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              final isCurrentRole = role == user.role;
              return ListTile(
                leading: Icon(
                  isCurrentRole ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isCurrentRole ? Theme.of(ctx).colorScheme.primary : null,
                ),
                title: Text(_getRoleName(role, l10n) ?? role.name),
                selected: isCurrentRole,
                onTap: () => Navigator.of(ctx).pop(role),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (result != null && result != user.role && context.mounted) {
      try {
        await authRepository.updateUserRole(user.id, result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${user.name} roli ${_getRoleName(result, l10n)} ga o\'zgartirildi',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xatolik: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageUsersTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: authRepository.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.errorLoadingUsers(
                  snapshot.error.toString(),
                ),
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noUsersFound));
          }

          final users = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final roleColor = _getRoleColor(user.role, colorScheme);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage:
                        user.profilePictureUrl != null &&
                                user.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                    child:
                        user.profilePictureUrl == null ||
                                user.profilePictureUrl!.isEmpty
                            ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                            : null,
                  ),
                  title: Text(user.name, style: textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? l10n.noEmailProvided,
                      ),
                      const SizedBox(height: 4),
                      // Role badge - tappable to change
                      GestureDetector(
                        onTap: () => _showRoleChangeDialog(
                          context, user, authRepository, l10n,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _getRoleName(user.role, l10n) ?? user.role.name,
                            style: textTheme.labelSmall?.copyWith(
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (user.registrationDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${l10n.registeredOnLabel}: ${DateFormat.yMMMd(l10n.localeName).format(user.registrationDate!)}',
                            style: textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: '${l10n.roleLabel} o\'zgartirish',
                    onPressed: () => _showRoleChangeDialog(
                      context, user, authRepository, l10n,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 4),
          );
        },
      ),
    );
  }
}
