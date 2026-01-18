import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'admin_send_notification_screen.dart';

class AdminNotificationManagementScreen extends StatefulWidget {
  const AdminNotificationManagementScreen({super.key});

  @override
  State<AdminNotificationManagementScreen> createState() => _AdminNotificationManagementScreenState();
}

class _AdminNotificationManagementScreenState extends State<AdminNotificationManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationManagementTitle),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              l10n.notificationHistoryTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.notificationHistoryPlaceholder,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSendNotificationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: Text(l10n.sendNewNotificationButton),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
