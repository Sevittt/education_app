import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/providers/ai_notifier.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart'; // Added for ImageSource

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(AiNotifier notifier) {
    final text = _controller.text;
    if (text.trim().isNotEmpty || notifier.selectedImageBytes != null) {
      notifier.sendMessage(text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifier = context.watch<AiNotifier>();

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notifier.isLoading) _scrollToBottom();
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AI Yordamchi "Sodiq"', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: notifier.clearChat,
            tooltip: 'Tozalash',
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGlassGradient : AppColors.primaryGradient,
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: notifier.messages.length + (notifier.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == notifier.messages.length) {
                    return _buildMessageBubble(
                      text: notifier.currentStreamingMessage ?? "...",
                      isUser: false,
                      isStreaming: true,
                    );
                  }
                  final msg = notifier.messages[index];
                  return _buildMessageBubble(
                    text: msg.text,
                    isUser: msg.isUser,
                    imageBytes: msg.imageBytes,
                  );
                },
              ),
            ),
            _buildQuickActions(context, notifier),
            _buildInputArea(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AiNotifier notifier) {
    if (notifier.messages.isNotEmpty) return const SizedBox.shrink();
    
    final actions = [
      {'icon': Icons.wifi_off, 'label': "Internet yo'q", 'query': "Internet ishlamayapti, nima qilay?"},
      {'icon': Icons.description_outlined, 'label': "Fayl ochilmayapti", 'query': "PDF fayl ochilmayapti, yordam bering."},
      {'icon': Icons.print_disabled, 'label': "Printer ishlamayapti", 'query': "Printer chop etmayapti, nima qilish kerak?"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(action['icon'] as IconData, size: 16, color: Colors.white),
              label: Text(action['label'] as String, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.white.withOpacity(0.2),
              side: BorderSide.none,
              onPressed: () {
                notifier.sendMessage(action['query'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text, 
    required bool isUser, 
    Uint8List? imageBytes,
    bool isStreaming = false
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GlassCard(
              borderRadius: 16,
              gradient: LinearGradient(
                colors: isUser 
                  ? [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)]
                  : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: isUser ? Colors.blue.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.support_agent, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Sodiq (AI Mentor)",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (imageBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(imageBytes, width: 200, fit: BoxFit.cover),
                      ),
                    ),
                  if (text.isNotEmpty)
                    MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.white),
                        strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AiNotifier notifier) {
    return GlassCard(
      padding: EdgeInsets.only(
        left: 8, 
        right: 16, 
        top: 8, 
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      borderRadius: 0,
      child: Column(
        children: [
          if (notifier.selectedImageBytes != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 16),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(notifier.selectedImageBytes!, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onPressed: notifier.clearSelectedImage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                onPressed: () => notifier.pickImage(ImageSource.gallery),
                tooltip: 'Rasm yuklash',
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Savol bering yoki rasm yuboring...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(notifier),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: (notifier.isLoading || (_controller.text.isEmpty && notifier.selectedImageBytes == null)) 
                      ? Colors.white.withOpacity(0.3) 
                      : Colors.white,
                ),
                onPressed: (notifier.isLoading) ? null : () => _sendMessage(notifier),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
