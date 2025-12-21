import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/sud_system.dart';
import '../../services/systems_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddEditSystemScreen extends StatefulWidget {
  final SudSystem? system;

  const AdminAddEditSystemScreen({super.key, this.system});

  @override
  State<AdminAddEditSystemScreen> createState() => _AdminAddEditSystemScreenState();
}

class _AdminAddEditSystemScreenState extends State<AdminAddEditSystemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SystemsService();
  
  late TextEditingController _nameController;
  late TextEditingController _fullNameController;
  late TextEditingController _urlController;
  late TextEditingController _logoUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _loginGuideIdController;
  late TextEditingController _videoGuideIdController;
  
  SystemCategory _selectedCategory = SystemCategory.primary;
  SystemStatus _selectedStatus = SystemStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.system?.name ?? '');
    _fullNameController = TextEditingController(text: widget.system?.fullName ?? '');
    _urlController = TextEditingController(text: widget.system?.url ?? '');
    _logoUrlController = TextEditingController(text: widget.system?.logoUrl ?? '');
    _descriptionController = TextEditingController(text: widget.system?.description ?? '');
    _loginGuideIdController = TextEditingController(text: widget.system?.loginGuideId ?? '');
    _videoGuideIdController = TextEditingController(text: widget.system?.videoGuideId ?? '');
    
    _selectedCategory = widget.system?.category ?? SystemCategory.primary;
    _selectedStatus = widget.system?.status ?? SystemStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _urlController.dispose();
    _logoUrlController.dispose();
    _descriptionController.dispose();
    _loginGuideIdController.dispose();
    _videoGuideIdController.dispose();
    super.dispose();
  }

  Future<void> _saveSystem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final system = SudSystem(
        id: widget.system?.id ?? '',
        name: _nameController.text,
        fullName: _fullNameController.text,
        url: _urlController.text,
        logoUrl: _logoUrlController.text.isEmpty ? null : _logoUrlController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        status: _selectedStatus,
        loginGuideId: _loginGuideIdController.text.isEmpty ? null : _loginGuideIdController.text,
        videoGuideId: _videoGuideIdController.text.isEmpty ? null : _videoGuideIdController.text,
        faqIds: widget.system?.faqIds ?? [],
        createdAt: widget.system?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      if (widget.system == null) {
        // Create new
        await _service.createSystem(system);
      } else {
        // Update existing
        await _service.updateSystem(widget.system!.id, system);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.systemSavedSuccess)),
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
        title: Text(widget.system == null ? l10n.addSystemTitle : l10n.editSystemTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSystem,
            tooltip: l10n.save,
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
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.shortNameLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.shortNameHint,
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.nameRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: l10n.fullNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.fullNameRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: l10n.websiteUrlLabel,
                        border: const OutlineInputBorder(),
                        hintText: 'https://esud.uz',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.urlRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _logoUrlController,
                      decoration: InputDecoration(
                        labelText: l10n.logoUrlLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.logoUrlRequired : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SystemCategory>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: SystemCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.getDisplayName(l10n)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SystemStatus>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: l10n.statusLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: SystemStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.getDisplayName(l10n)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionLabel,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.descriptionRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loginGuideIdController,
                      decoration: InputDecoration(
                        labelText: l10n.loginGuideIdLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _videoGuideIdController,
                      decoration: InputDecoration(
                        labelText: l10n.videoGuideIdLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
