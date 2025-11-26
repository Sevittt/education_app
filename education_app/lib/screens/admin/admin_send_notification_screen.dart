import 'package:flutter/material.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSendNotificationScreen extends StatefulWidget {
  const AdminSendNotificationScreen({super.key});

  @override
  State<AdminSendNotificationScreen> createState() => _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState extends State<AdminSendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = NotificationService();
  
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

    try {
      final notification = AppNotification(
        id: '', // Will be generated
        title: _titleController.text,
        body: _bodyController.text,
        type: _selectedType,
        targetAudience: _selectedAudience,
        sentAt: Timestamp.now(),
        readBy: [],
      );

      await _service.sendNotification(notification);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xabarnoma yuborildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xabarnoma Yuborish'),
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
                      decoration: const InputDecoration(
                        labelText: 'Sarlavha',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Sarlavha kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Xabar matni',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Matn kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                      DropdownButtonFormField<NotificationType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Xabarnoma turi',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Auditoriya',
                        border: OutlineInputBorder(),
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
