import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/providers/ai_notifier.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart'; // Added for ImageSource
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

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
    final notifier = context.watch<AiNotifier>();
    final l10n = AppLocalizations.of(context);

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notifier.isLoading) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.aiAssistantName ?? 'AI Yordamchi "Sodiq"'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: notifier.clearChat,
            tooltip: l10n?.clearChatTooltip ?? 'Tozalash',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: notifier.messages.length + (notifier.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == notifier.messages.length) {
                  return _buildMessageBubble(
                    context: context,
                    text: notifier.currentStreamingMessage ?? "...",
                    isUser: false,
                    isStreaming: true,
                  );
                }
                final msg = notifier.messages[index];
                return _buildMessageBubble(
                  context: context,
                  text: msg.text,
                  isUser: msg.isUser,
                  imageBytes: msg.imageBytes,
                );
              },
            ),
          ),
          _buildQuickActions(context, notifier, l10n),
          _buildInputArea(context, notifier, l10n),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, AiNotifier notifier, AppLocalizations? l10n) {
    if (notifier.messages.isNotEmpty) return const SizedBox.shrink();

    final actions = [
      {
        'icon': Icons.wifi_off,
        'label': l10n?.noInternetLabel ?? "Internet yo'q",
        'query': l10n?.noInternetQuery ?? "Internet ishlamayapti, nima qilay?"
      },
      {
        'icon': Icons.description_outlined,
        'label': l10n?.fileNotOpeningLabel ?? "Fayl ochilmayapti",
        'query':
            l10n?.fileNotOpeningQuery ?? "PDF fayl ochilmayapti, yordam bering."
      },
      {
        'icon': Icons.print_disabled,
        'label': l10n?.printerNotWorkingLabel ?? "Printer ishlamayapti",
        'query': l10n?.printerNotWorkingQuery ??
            "Printer chop etmayapti, nima qilish kerak?"
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(
                action['icon'] as IconData,
                size: 16,
                color: isDark ? AppColors.amber : AppColors.primary,
              ),
              label: Text(
                action['label'] as String,
                style: TextStyle(
                  color: isDark ? AppColors.amber : AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: isDark
                  ? AppColors.amberContainer
                  : AppColors.primaryContainer,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                notifier.sendMessage(action['query'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(
      {required BuildContext context,
      required String text,
      required bool isUser,
      Uint8List? imageBytes,
      bool isStreaming = false}) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Builder(builder: (ctx) {
              final dark = Theme.of(ctx).brightness == Brightness.dark;
              final userBubbleBg  = dark ? AppColors.amberContainer : AppColors.primaryContainer;
              final aiBubbleBg    = dark ? AppColors.surfaceElevated  : AppColors.surfaceVariantLight;
              return GlassCard(
              borderRadius: 16,
              gradient: LinearGradient(
                colors: isUser
                    ? [userBubbleBg, userBubbleBg]
                    : [aiBubbleBg, aiBubbleBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.support_agent,
                            color: Theme.of(ctx).colorScheme.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n?.aiMentorName ?? "Sodiq (AI Mentor)",
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
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
                        child: Image.memory(imageBytes,
                            width: 200, fit: BoxFit.cover),
                      ),
                    ),
                  if (text.isNotEmpty)
                    MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(ctx)).copyWith(
                        p: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                        strong: TextStyle(
                            color: Theme.of(ctx).colorScheme.onSurface,
                            fontWeight: FontWeight.bold),
                      ),
                      onTapLink: (text, href, title) async {
                        if (href != null) {
                          final url = Uri.parse(href);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                    ),
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(ctx).colorScheme.primary),
                      ),
                    ),
                ],
              ),
            );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(
      BuildContext context, AiNotifier notifier, AppLocalizations? l10n) {
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
                        child: Image.memory(notifier.selectedImageBytes!,
                            width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.white),
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
                icon: Icon(Icons.add_photo_alternate_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: () => notifier.pickImage(ImageSource.gallery),
                tooltip: l10n?.uploadImageTooltip ?? 'Rasm yuklash',
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n?.writeMessageHint ?? 'Xabar yozing...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(notifier),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final hasInput = value.text.trim().isNotEmpty ||
                      notifier.selectedImageBytes != null;
                  final accent = Theme.of(context).colorScheme.primary;
                  return Container(
                    decoration: BoxDecoration(
                      color: hasInput
                          ? accent
                          : Theme.of(context).colorScheme.outline,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20),
                      onPressed: (notifier.isLoading || !hasInput)
                          ? null
                          : () => _sendMessage(notifier),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
