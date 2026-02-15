import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/providers/ai_notifier.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifier = context.watch<AiNotifier>();

    // Scroll to bottom when new messages arrive or streaming updates
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AI Yordamchi', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: notifier.clearChat,
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
                    // Streaming message placeholder or loading indicator
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
                  );
                },
              ),
            ),
            _buildInputArea(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isUser, bool isStreaming = false}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: const BoxConstraints(maxWidth: 300),
        child: GlassCard(
          borderRadius: 16,
          color: isUser 
              ? Colors.blue.withOpacity(0.2) 
              : Colors.white.withOpacity(0.1),
          startStop: isUser 
            ? [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)]
            : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "AI Yordamchi",
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
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AiNotifier notifier) {
    return GlassCard(
      padding: const EdgeInsets.all(16.0) + MediaQuery.of(context).padding.bottom.toDouble() * const EdgeInsets.only(bottom: 1).padding,
      borderRadius: 0, // Full width at bottom
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Savolingizni yozing...',
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
              color: notifier.isLoading ? Colors.white.withOpacity(0.3) : Colors.white,
            ),
            onPressed: notifier.isLoading ? null : () => _sendMessage(notifier),
          ),
        ],
      ),
    );
  }

  void _sendMessage(AiNotifier notifier) {
    final text = _controller.text;
    if (text.isNotEmpty) {
      notifier.sendMessage(text);
      _controller.clear();
    }
  }
}
