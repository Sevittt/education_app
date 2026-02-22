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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use AuthRepository instead of ProfileService
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
                ), // "Error loading users: {error}"
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noUsersFound)); // "No users found."
          }

          final users = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
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
                      ), // "No email provided"
                      Text(
                        // O'ZGARISH: Rol nomini yordamchi funksiya orqali olish
                        '${l10n.roleLabel} ${_getRoleName(user.role, l10n)}', // "Role: {roleName}"
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                      if (user.registrationDate != null)
                        Text(
                          '${l10n.registeredOnLabel}: ${DateFormat.yMMMd(l10n.localeName).format(user.registrationDate!)}', // "Registered: {date}"
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                  isThreeLine: true, // Adjust if content overflows
                  // For future: Add trailing icons/buttons for actions like 'Edit Role' (would need Admin SDK)
                  // trailing: Icon(Icons.more_vert),
                  // onTap: () {
                  //   // Navigate to a user detail screen or show options
                  // },
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

// Add new localization keys to your .arb files:
// "errorLoadingUsers": "Error loading users: {error}",
// "noUsersFound": "No users found.",
// "noEmailProvided": "No email provided",
// "roleLabel": "Role",
// "registeredOnLabel": "Registered"
// (You should already have "manageUsersTitle" from AdminPanelScreen)
