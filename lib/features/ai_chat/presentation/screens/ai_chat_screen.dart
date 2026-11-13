import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';
import 'package:sud_qollanma/features/ai_chat/presentation/providers/ai_notifier.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/shared/widgets/design_system.dart';

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
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notifier.isLoading) _scrollToBottom();
    });

    final isEmpty = notifier.messages.isEmpty && !notifier.isLoading;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.s16, AppSpace.s8, AppSpace.s16, AppSpace.s8),
              child: Row(
                children: [
                  CircleIconButton(
                    Icons.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  Expanded(
                    child: Text(
                      l10n?.aiAssistantName ?? 'AI Yordamchi "Sodiq"',
                      style: text.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  CircleIconButton(
                    Icons.delete_outline_rounded,
                    tooltip: l10n?.clearChatTooltip ?? 'Tozalash',
                    onPressed: notifier.clearChat,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: t.borderDefault),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: isEmpty
                      ? _buildWelcomeState(context, notifier, l10n)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpace.s16),
                          itemCount: notifier.messages.length + (notifier.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == notifier.messages.length) {
                              return _buildMessageBubble(
                                context: context,
                                text: notifier.currentStreamingMessage ?? '...',
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
              ),
            ),
            _buildInputArea(context, notifier, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState(
    BuildContext context,
    AiNotifier notifier,
    AppLocalizations? l10n,
  ) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    final actions = [
      (
        Icons.key_outlined,
        'E-IMZO ishlamayapti',
        'E-IMZO kaliti koʻrinmayapti yoki xatolik beryapti, qanday toʻgʻrilayman?',
      ),
      (
        Icons.wifi_off_rounded,
        l10n?.noInternetLabel ?? 'Internet yoʻq',
        l10n?.noInternetQuery ?? 'Internet ishlamayapti, nima qilay?',
      ),
      (
        Icons.description_outlined,
        l10n?.fileNotOpeningLabel ?? 'Fayl ochilmayapti',
        l10n?.fileNotOpeningQuery ?? 'PDF fayl ochilmayapti, yordam bering.',
      ),
      (
        Icons.print_disabled_outlined,
        l10n?.printerNotWorkingLabel ?? 'Printer ishlamayapti',
        l10n?.printerNotWorkingQuery ?? 'Printer chop etmayapti, nima qilish kerak?',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.s24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpace.s16),
          AppCard(
            padding: const EdgeInsets.all(AppSpace.s24),
            radius: AppRadius.xl,
            child: Column(
              children: [
                IconTile(
                  Icons.auto_awesome_rounded,
                  size: 64,
                  circle: true,
                  background: t.brandContainer,
                  foreground: t.brandPrimary,
                ),
                const SizedBox(height: AppSpace.s16),
                Text(
                  l10n?.aiMentorName ?? 'Sodiq — Sud AKT AI Yordamchisi',
                  style: text.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpace.s8),
                Text(
                  'E-SUD, EDO, E-IMZO, Adolat tizimlari va ofis texnikasi boʻyicha savolingizni yozing yoki xatolik skrinshotini yuklang.',
                  style: text.bodyMedium?.copyWith(color: t.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpace.s20),
                OutlinedButton.icon(
                  onPressed: () => notifier.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: Text(l10n?.uploadImageTooltip ?? 'Xatolik skrinshotini yuklash'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tezkor savollar:',
              style: text.labelLarge?.copyWith(color: t.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpace.s12),
          Wrap(
            spacing: AppSpace.s8,
            runSpacing: AppSpace.s8,
            children: [
              for (final (icon, label, query) in actions)
                ActionChip(
                  avatar: Icon(icon, size: 16, color: t.brandPrimary),
                  label: Text(
                    label,
                    style: text.labelLarge?.copyWith(color: t.textPrimary),
                  ),
                  backgroundColor: t.bgSurface,
                  side: BorderSide(color: t.borderDefault),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  onPressed: () => notifier.sendMessage(query),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required String text,
    required bool isUser,
    Uint8List? imageBytes,
    bool isStreaming = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    final bubbleBg = isUser ? t.brandContainer : t.bgSurface;
    final textColor = isUser ? t.brandOnContainer : t.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(AppSpace.s16),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUser ? t.brandPrimary.withValues(alpha: 0.25) : t.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: t.brandPrimary, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.aiMentorName ?? 'Sodiq (AI Mentor)',
                    style: textTheme.labelSmall?.copyWith(
                      color: t.brandPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (imageBytes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.memory(imageBytes, width: 220, fit: BoxFit.cover),
                ),
              ),
            if (text.isNotEmpty)
              MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: textTheme.bodyMedium?.copyWith(color: textColor, height: 1.55),
                  strong: textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTapLink: (_, href, __) async {
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
                padding: const EdgeInsets.only(top: 6.0),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: t.brandPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    AiNotifier notifier,
    AppLocalizations? l10n,
  ) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.borderDefault)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpace.s12,
        AppSpace.s8,
        AppSpace.s16,
        AppSpace.s8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (notifier.selectedImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.memory(
                              notifier.selectedImageBytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: IconButton(
                              icon: Icon(Icons.cancel_rounded, size: 18, color: t.dangerSolid),
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
                    icon: Icon(Icons.add_photo_alternate_outlined, color: t.textSecondary),
                    onPressed: () => notifier.pickImage(ImageSource.gallery),
                    tooltip: l10n?.uploadImageTooltip ?? 'Rasm yuklash',
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.bgSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: t.borderDefault),
                      ),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        style: text.bodyMedium?.copyWith(color: t.textPrimary),
                        decoration: InputDecoration(
                          hintText: l10n?.writeMessageHint ?? 'Xabar yozing...',
                          hintStyle: text.bodyMedium?.copyWith(color: t.textTertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.s16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(notifier),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final hasInput = value.text.trim().isNotEmpty ||
                          notifier.selectedImageBytes != null;
                      return Material(
                        color: hasInput ? t.brandPrimary : t.bgSubtle,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: hasInput ? t.textOnBrand : t.textTertiary,
                            size: 18,
                          ),
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
        ),
      ),
    );
  }
}
