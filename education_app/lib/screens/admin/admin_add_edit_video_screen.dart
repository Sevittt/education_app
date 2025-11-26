import 'package:flutter/material.dart';
import '../../models/video_tutorial.dart';
import '../../services/video_tutorial_service.dart';
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
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _youtubeIdController;
  late TextEditingController _durationController;
  VideoCategory _selectedCategory = VideoCategory.beginner;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.video?.title ?? '');
    _descriptionController = TextEditingController(text: widget.video?.description ?? '');
    _youtubeIdController = TextEditingController(text: widget.video?.youtubeId ?? '');
    _durationController = TextEditingController(text: widget.video?.duration.toString() ?? '');
    _selectedCategory = widget.video?.category ?? VideoCategory.beginner;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeIdController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      final duration = int.tryParse(_durationController.text) ?? 0;

      final video = VideoTutorial(
        id: widget.video?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        youtubeId: _youtubeIdController.text,
        duration: duration,
        category: _selectedCategory,
        systemId: null, // TODO: Add system selection
        thumbnailUrl: _service.getYoutubeThumbnail(_youtubeIdController.text),
        tags: [], // TODO: Add tags input
        authorId: 'admin',
        authorName: 'Admin',
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
          const SnackBar(content: Text('Video saqlandi')),
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
        title: Text(widget.video == null ? 'Yangi Video' : 'Videoni Tahrirlash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveVideo,
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
                      controller: _youtubeIdController,
                      decoration: const InputDecoration(
                        labelText: 'YouTube ID',
                        border: OutlineInputBorder(),
                        hintText: 'Masalan: dQw4w9WgXcQ',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'YouTube ID kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<VideoCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategoriya',
                        border: OutlineInputBorder(),
                      ),
                      items: VideoCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Davomiyligi',
                        border: OutlineInputBorder(),
                        hintText: 'Masalan: 10:30',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Davomiylik kiritilishi shart' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Tavsif',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Tavsif kiritilishi shart' : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
