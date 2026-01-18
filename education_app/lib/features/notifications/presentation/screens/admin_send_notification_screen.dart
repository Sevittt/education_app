import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:sud_qollanma/l10n/app_localizations.dart';

import '../../domain/entities/notification_entity.dart';
import '../providers/notification_notifier.dart';

class AdminSendNotificationScreen extends StatefulWidget {
  const AdminSendNotificationScreen({super.key});

  @override
  State<AdminSendNotificationScreen> createState() => _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState extends State<AdminSendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  NotificationType _selectedType = NotificationType.system;
  TargetAudience _selectedAudience = TargetAudience.all;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final notifier = Provider.of<NotificationNotifier>(context, listen: false);

    try {
      final notification = NotificationEntity(
        id: '', // Will be generated
        title: _titleController.text,
        body: _bodyController.text,
        type: _selectedType,
        targetAudience: _selectedAudience,
        sentAt: DateTime.now(),
        readBy: const [],
      );

      // We use createNotification mostly, but if we wanted bulk to specific users we'd use sendBulk
      // But here we rely on targetAudience 'all' or others handled by query.
      await notifier.createNotification(notification);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationSentSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendNotificationTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendNotification,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.notificationTitleLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.notificationTitleRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: InputDecoration(
                        labelText: l10n.notificationBodyLabel,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.notificationBodyRequired : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<NotificationType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: l10n.notificationTypeLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: NotificationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text('${type.icon} ${type.displayName}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TargetAudience>(
                      value: _selectedAudience,
                      decoration: InputDecoration(
                        labelText: l10n.targetAudienceLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: TargetAudience.values.map((audience) {
                        return DropdownMenuItem(
                          value: audience,
                          child: Text(audience.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAudience = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
