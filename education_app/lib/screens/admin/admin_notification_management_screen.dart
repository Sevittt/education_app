import 'package:flutter/material.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import 'admin_send_notification_screen.dart';
import 'package:intl/intl.dart';

class AdminNotificationManagementScreen extends StatefulWidget {
  const AdminNotificationManagementScreen({super.key});

  @override
  State<AdminNotificationManagementScreen> createState() => _AdminNotificationManagementScreenState();
}

class _AdminNotificationManagementScreenState extends State<AdminNotificationManagementScreen> {
  // Note: NotificationService currently focuses on *user* notifications.
  // We might need to add a method to get *all* sent notifications or just show a log.
  // For now, we'll just show a button to send a new notification.
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xabarnomalar Boshqaruvi'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Xabarnomalar Tarixi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Bu yerda yuborilgan xabarnomalar tarixi ko\'rinadi (tez orada).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
              label: const Text('Yangi Xabarnoma Yuborish'),
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
