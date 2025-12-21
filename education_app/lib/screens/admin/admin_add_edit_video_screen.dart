import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/video_tutorial.dart';
import '../../models/sud_system.dart';
import '../../services/video_tutorial_service.dart';
import '../../services/systems_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddEditVideoScreen extends StatefulWidget {
  final VideoTutorial? video;

  const AdminAddEditVideoScreen({super.key, this.video});

  @override
  State<AdminAddEditVideoScreen> createState() => _AdminAddEditVideoScreenState();
}

class _AdminAddEditVideoScreenState extends State<AdminAddEditVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = VideoTutorialService();
  final _systemsService = SystemsService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _youtubeIdController;
  late TextEditingController _durationController;
  late TextEditingController _tagsController;
  
  VideoCategory _selectedCategory = VideoCategory.beginner;
  String? _selectedSystemId;
  List<SudSystem> _systems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.video?.title ?? '');
    _descriptionController = TextEditingController(text: widget.video?.description ?? '');
    _youtubeIdController = TextEditingController(text: widget.video?.youtubeId ?? '');
    _durationController = TextEditingController(text: widget.video?.duration.toString() ?? '');
    _tagsController = TextEditingController(text: widget.video?.tags.join(', ') ?? '');
    _selectedCategory = widget.video?.category ?? VideoCategory.beginner;
    _selectedSystemId = widget.video?.systemId;
    _loadSystems();
  }

  Future<void> _loadSystems() async {
    final systems = await _systemsService.getAllSystems().first;
    if (mounted) {
      setState(() {
        _systems = systems;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeIdController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final authorId = user?.uid ?? 'admin';
      final authorName = user?.displayName ?? 'Admin';

      final duration = int.tryParse(_durationController.text) ?? 0;
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final video = VideoTutorial(
        id: widget.video?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        youtubeId: _youtubeIdController.text,
        duration: duration,
        category: _selectedCategory,
        systemId: _selectedSystemId,
        thumbnailUrl: _service.getYoutubeThumbnail(_youtubeIdController.text),
        tags: tags,
        authorId: authorId,
        authorName: authorName,
        createdAt: widget.video?.createdAt ?? Timestamp.now(),
        order: widget.video?.order ?? 0,
      );

      if (widget.video == null) {
        // Create new
        await _service.createVideo(video);
      } else {
        // Update existing
        await _service.updateVideo(widget.video!.id, video);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.videoSavedSuccess)),
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
        title: Text(widget.video == null ? l10n.addVideoTitle : l10n.editVideoTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveVideo,
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
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.titleLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.titleRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _youtubeIdController,
                      decoration: InputDecoration(
                        labelText: l10n.youtubeIdLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.youtubeIdHint,
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.youtubeIdRequired : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<VideoCategory>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: VideoCategory.values.map((category) {
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
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSystemId,
                      decoration: InputDecoration(
                        labelText: l10n.systemOptionalLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(l10n.notSelectedLabel),
                        ),
                        ..._systems.map((system) {
                          return DropdownMenuItem(
                            value: system.id,
                            child: Text(system.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedSystemId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: l10n.durationLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.durationHint,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? l10n.durationRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: l10n.tagsLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.videoTagsHint,
                      ),
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
                  ],
                ),
              ),
            ),
    );
  }
}
