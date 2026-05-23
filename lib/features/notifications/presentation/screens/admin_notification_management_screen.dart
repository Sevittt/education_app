import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:sud_qollanma/shared/widgets/animated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'admin_send_notification_screen.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_model.dart';

class AdminNotificationManagementScreen extends StatefulWidget {
  const AdminNotificationManagementScreen({super.key});

  @override
  State<AdminNotificationManagementScreen> createState() =>
      _AdminNotificationManagementScreenState();
}

class _AdminNotificationManagementScreenState
    extends State<AdminNotificationManagementScreen> {
  bool _testLoading = false;

  Future<void> _testCourseReminder() async {
    final userIdCtrl = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kurs eslatmasini test qilish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quyidagi foydalanuvchiga tugallanmagan kursi bo\'yicha\nFCM test notification yuboriladi.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: userIdCtrl,
              decoration: const InputDecoration(
                labelText: 'User ID (bo\'sh → o\'zing)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yuborish'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _testLoading = true);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('testCourseReminder');
      final uid = userIdCtrl.text.trim();
      final result = await callable.call<Map<String, dynamic>>(
        uid.isNotEmpty ? {'userId': uid} : {},
      );
      final data = result.data;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'Yuborildi! Kurs: ${data['courseTitle']} → ${data['userId']}',
          ),
        ));
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Xato: ${e.message}'),
        ));
      }
    } finally {
      if (mounted) setState(() => _testLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.notificationManagementTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkGlassGradient : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          l10n.notificationHistoryTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('app_notifications')
                                .orderBy('sentAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: isDark ? Colors.white : Colors.black)));
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              final docs = snapshot.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    l10n.noNotifications,
                                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                  ),
                                );
                              }

                              final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

                              return ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final data = docs[index].data() as Map<String, dynamic>;
                                  final title = data['title'] ?? 'No title';
                                  final body = data['body'] ?? '';
                                  final sentAt = data['sentAt'] is Timestamp 
                                      ? (data['sentAt'] as Timestamp).toDate() 
                                      : DateTime.now();
                                  final typeString = data['type'] ?? 'system';
                                  final targetAudienceString = data['targetAudience'] ?? 'all';
                                  final readBy = List<String>.from(data['readBy'] ?? []);
                                  
                                  final typeEnum = NotificationType.values.firstWhere(
                                    (e) => e.name == typeString, 
                                    orElse: () => NotificationType.system
                                  );
                                  final audienceEnum = TargetAudience.values.firstWhere(
                                    (e) => e.name == targetAudienceString, 
                                    orElse: () => TargetAudience.all
                                  );

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: (isDark ? Colors.black : Colors.white).withAlpha(128),
                                    child: ListTile(
                                      title: Text(
                                        title,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${dateFormat.format(sentAt)} • ${typeEnum.getLocalizedName(l10n)} • ${l10n.notificationLabelTo(audienceEnum.getLocalizedName(l10n))} • ${l10n.notificationLabelReadBy(readBy.length)}',
                                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(l10n.deleteResourceConfirmTitle),
                                              content: Text(l10n.deleteResourceConfirmMessage),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelButtonText)),
                                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.deleteButtonText, style: const TextStyle(color: Colors.red))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await FirebaseFirestore.instance.collection('app_notifications').doc(docs[index].id).delete();
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminSendNotificationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.send_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          l10n.sendNewNotificationButton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // ─── Test: Kurs eslatmasi ──────────────────────────────
                AnimatedButton(
                  onPressed: _testLoading ? null : _testCourseReminder,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: _testLoading
                          ? AppColors.borderDark
                          : AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _testLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.warning,
                                ),
                              )
                            : const Icon(Icons.science_rounded,
                                color: AppColors.warning),
                        const SizedBox(width: 12),
                        const Text(
                          'Kurs eslatmasini test qilish',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
