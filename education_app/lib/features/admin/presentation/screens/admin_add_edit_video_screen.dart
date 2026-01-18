import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/library/presentation/providers/library_provider.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/presentation/providers/systems_notifier.dart';

class AdminAddEditVideoScreen extends StatefulWidget {
  final VideoEntity? video;

  const AdminAddEditVideoScreen({super.key, this.video});

  @override
  State<AdminAddEditVideoScreen> createState() => _AdminAddEditVideoScreenState();
}

class _AdminAddEditVideoScreenState extends State<AdminAddEditVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _youtubeIdController;
  late TextEditingController _durationController;
  late TextEditingController _tagsController;
  
  String _selectedCategory = 'beginner';
  String? _selectedSystemId;
  List<SudSystemEntity> _systems = [];
  bool _isLoading = false;

  // Video categories - now as strings to match VideoEntity
  static const List<String> _categories = [
    'beginner',
    'intermediate',
    'advanced',
    'practical',
    'theory',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.video?.title ?? '');
    _descriptionController = TextEditingController(text: widget.video?.description ?? '');
    _youtubeIdController = TextEditingController(text: widget.video?.youtubeId ?? '');
    _durationController = TextEditingController(text: widget.video?.durationSeconds.toString() ?? '');
    _tagsController = TextEditingController(text: widget.video?.tags.join(', ') ?? '');
    _selectedCategory = widget.video?.category ?? 'beginner';
    _selectedSystemId = widget.video?.systemId;
    
    // Load systems after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSystems();
    });
  }

  Future<void> _loadSystems() async {
    final notifier = Provider.of<SystemsNotifier>(context, listen: false);
    // Assuming notifier has a way to get systems, or we listen to stream
    // Since stream might be expensive to listen here, we just take first element
    final systems = await notifier.systemsStream.first;
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

  String _getCategoryDisplayName(String category, AppLocalizations l10n) {
    // Using hardcoded names since localization keys may not exist
    switch (category) {
      case 'beginner':
        return 'Boshlang\'ich';
      case 'intermediate':
        return 'O\'rta';
      case 'advanced':
        return 'Yuqori';
      case 'practical':
        return 'Amaliy';
      case 'theory':
        return 'Nazariy';
      default:
        return category;
    }
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<LibraryProvider>();

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

      final video = VideoEntity(
        id: widget.video?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        youtubeId: _youtubeIdController.text,
        durationSeconds: duration,
        category: _selectedCategory,
        systemId: _selectedSystemId,
        thumbnailUrl: provider.getYoutubeThumbnail(_youtubeIdController.text),
        tags: tags,
        authorId: authorId,
        authorName: authorName,
        views: widget.video?.views ?? 0,
        likes: widget.video?.likes ?? 0,
        createdAt: widget.video?.createdAt ?? DateTime.now(),
        order: widget.video?.order ?? 0,
      );

      if (widget.video == null) {
        // Create new
        await provider.createVideo(video);
      } else {
        // Update existing
        await provider.updateVideo(widget.video!.id, video);
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
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryDisplayName(category, l10n)),
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
                      value: _selectedSystemId,
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
