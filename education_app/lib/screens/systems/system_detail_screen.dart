import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sud_system.dart';
import '../../services/systems_service.dart';

class SystemDetailScreen extends StatefulWidget {
  final SudSystem system;

  const SystemDetailScreen({super.key, required this.system});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  final SystemsService _service = SystemsService();
  Map<String, dynamic> _content = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final content = await _service.getSystemContent(widget.system.id);
    if (mounted) {
      setState(() {
        _content = content;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(widget.system.fullUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Havolani ochib bo\'lmadi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.system.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildQuickLinks(),
                  const SizedBox(height: 24),
                  if (_content['articles'] != null && (_content['articles'] as List).isNotEmpty)
                    _buildSection('Qo\'llanmalar', _content['articles']),
                  if (_content['videos'] != null && (_content['videos'] as List).isNotEmpty)
                    _buildSection('Videolar', _content['videos']),
                  if (_content['faqs'] != null && (_content['faqs'] as List).isNotEmpty)
                    _buildSection('Ko\'p so\'raladigan savollar', _content['faqs']),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _launchUrl,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Tizimga kirish'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            image: widget.system.logoUrl != null
                ? DecorationImage(
                    image: NetworkImage(widget.system.logoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.system.logoUrl == null
              ? const Icon(Icons.computer, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.system.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(widget.system.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(SystemStatus status) {
    Color color;
    switch (status) {
      case SystemStatus.active:
        color = Colors.green;
        break;
      case SystemStatus.maintenance:
        color = Colors.orange;
        break;
      case SystemStatus.deprecated:
        color = Colors.grey;
        break;
      case SystemStatus.offline:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tavsif',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.system.description,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQuickLinks() {
    return Row(
      children: [
        if (widget.system.loginGuideId != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to article
              },
              icon: const Icon(Icons.article_outlined),
              label: const Text('Kirish qo\'llanmasi'),
            ),
          ),
        if (widget.system.loginGuideId != null && widget.system.videoGuideId != null)
          const SizedBox(width: 16),
        if (widget.system.videoGuideId != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to video
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Video qo\'llanma'),
            ),
          ),
      ],
    );
  }

  Widget _buildSection(String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.arrow_right, color: Colors.blue),
              title: Text(item['title'] ?? item['question'] ?? ''),
              onTap: () {
                // Navigate to content
              },
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
