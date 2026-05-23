import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';
import 'package:sud_qollanma/features/library/domain/entities/video_entity.dart';
import 'package:sud_qollanma/features/library/presentation/screens/video_player_screen.dart';

/// Dars kontent ekrani.
/// [refId] + [sourceCollection] orqali Firestore'dan kontent yuklanadi.
class LessonViewerScreen extends StatefulWidget {
  final CourseLessonEntity lesson;

  const LessonViewerScreen({super.key, required this.lesson});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadContent();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(widget.lesson.sourceCollection)
          .doc(widget.lesson.refId)
          .get();
      if (!doc.exists) throw Exception('Kontent topilmadi');
      setState(() {
        _data = doc.data();
        _loading = false;
      });
      _fadeCtrl.forward();

    if (widget.lesson.type == LessonType.video && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openVideoDirectly());
    }
  } catch (e) {
    setState(() {
      _error = e.toString();
      _loading = false;
    });
  }
}

Future<void> _openVideoDirectly() async {
  if (!mounted || _data == null) return;
  final data = _data!;
  final video = VideoEntity(
    id: widget.lesson.refId,
    title: data['title'] as String? ?? widget.lesson.title,
    description: data['description'] as String? ?? '',
    youtubeId: data['youtubeId'] as String?,
    videoUrl: data['videoUrl'] as String?,
    durationSeconds: (data['duration'] as num?)?.toInt() ??
        (data['durationSeconds'] as num?)?.toInt() ??
        0,
    category: data['category'] as String? ?? 'beginner',
    systemId: data['systemId'] as String?,
    thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
    tags: List<String>.from(data['tags'] as List? ?? []),
    authorId: data['authorId'] as String? ?? '',
    authorName: data['authorName'] as String? ?? '',
    views: (data['views'] as num?)?.toInt() ?? 0,
    likes: (data['likes'] as num?)?.toInt() ?? 0,
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    order: (data['order'] as num?)?.toInt() ?? 0,
    timeCodes: (data['timeCodes'] as List?)
            ?.map((e) => VideoTimeCode.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoEntity: video)),
  );
  if (mounted) Navigator.pop(context, true);
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeConfig = _typeConfig(widget.lesson.type);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: typeConfig.color.withValues(alpha: isDark ? 0.25 : 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(typeConfig.icon, size: 12, color: typeConfig.color),
                  const SizedBox(width: 4),
                  Text(
                    typeConfig.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: typeConfig.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.lesson.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? _buildSkeleton(isDark)
          : _error != null
              ? _buildError(isDark)
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildContent(isDark),
                ),
    );
  }

  // ─── Skeleton ─────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    return _Shimmer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(
              height: 220, borderRadius: 0, isDark: isDark, margin: EdgeInsets.zero),
          const SizedBox(height: 20),
          _SkeletonBox(height: 14, isDark: isDark, widthFraction: 0.7),
          const SizedBox(height: 10),
          _SkeletonBox(height: 12, isDark: isDark, widthFraction: 0.9),
          const SizedBox(height: 6),
          _SkeletonBox(height: 12, isDark: isDark, widthFraction: 0.6),
        ],
      ),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Kontent yuklanmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadContent();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Content router ───────────────────────────────────────────────────────

  Widget _buildContent(bool isDark) {
    switch (widget.lesson.type) {
      case LessonType.video:
        return _buildVideoContent(isDark);
      case LessonType.article:
        return _buildArticleContent(isDark);
      case LessonType.pdf:
        return _buildPdfContent(isDark);
      case LessonType.quiz:
        return const SizedBox.shrink();
    }
  }

  // ─── Video ────────────────────────────────────────────────────────────────

  Widget _buildVideoContent(bool isDark) {
    final data = _data!;
    final video = VideoEntity(
      id: widget.lesson.refId,
      title: data['title'] as String? ?? widget.lesson.title,
      description: data['description'] as String? ?? '',
      youtubeId: data['youtubeId'] as String?,
      videoUrl: data['videoUrl'] as String?,
      durationSeconds: (data['duration'] as num?)?.toInt() ??
          (data['durationSeconds'] as num?)?.toInt() ??
          0,
      category: data['category'] as String? ?? 'beginner',
      systemId: data['systemId'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? []),
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: (data['order'] as num?)?.toInt() ?? 0,
      timeCodes: (data['timeCodes'] as List?)
              ?.map((e) => VideoTimeCode.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

    return _LessonShell(
      isDark: isDark,
      lessonType: widget.lesson.type,
      onVideoOpen: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoEntity: video)),
        );
        if (mounted) Navigator.pop(context, true);
      },
      onComplete: () => Navigator.pop(context, true),
      child: _VideoHero(video: video, isDark: isDark),
    );
  }

  // ─── Article ──────────────────────────────────────────────────────────────

  Widget _buildArticleContent(bool isDark) {
    final data = _data!;
    final title = data['title'] as String? ?? widget.lesson.title;
    final content =
        data['content'] as String? ?? data['text'] as String? ?? '';

    return _LessonShell(
      isDark: isDark,
      lessonType: widget.lesson.type,
      onComplete: () => Navigator.pop(context, true),
      child: _ArticleBody(
          title: title, content: content, isDark: isDark),
    );
  }

  // ─── PDF ──────────────────────────────────────────────────────────────────

  Widget _buildPdfContent(bool isDark) {
    final data = _data!;
    final title = data['title'] as String? ?? widget.lesson.title;
    final description = data['description'] as String? ?? '';
    final url = data['url'] as String? ?? data['pdfUrl'] as String?;

    return _LessonShell(
      isDark: isDark,
      lessonType: widget.lesson.type,
      onComplete: () => Navigator.pop(context, true),
      child: _PdfBody(
        title: title,
        description: description,
        url: url,
        isDark: isDark,
        onOpen: () => _openUrl(url!),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── Type config helper ───────────────────────────────────────────────────────

class _TypeConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _TypeConfig({required this.icon, required this.color, required this.label});
}

_TypeConfig _typeConfig(LessonType type) {
  switch (type) {
    case LessonType.video:
      return _TypeConfig(
          icon: Icons.play_circle_filled_rounded,
          color: const Color(0xFF3B82F6),
          label: 'Video');
    case LessonType.article:
      return _TypeConfig(
          icon: Icons.article_rounded,
          color: AppColors.success,
          label: 'Maqola');
    case LessonType.pdf:
      return _TypeConfig(
          icon: Icons.picture_as_pdf_rounded,
          color: AppColors.error,
          label: 'PDF');
    case LessonType.quiz:
      return _TypeConfig(
          icon: Icons.quiz_rounded,
          color: AppColors.warning,
          label: 'Test');
  }
}

// ─── Lesson Shell (layout + bottom actions) ───────────────────────────────────

class _LessonShell extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final LessonType lessonType;
  final VoidCallback onComplete;
  final VoidCallback? onVideoOpen;

  const _LessonShell({
    required this.child,
    required this.isDark,
    required this.lessonType,
    required this.onComplete,
    this.onVideoOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = lessonType == LessonType.video;
    final tc = _typeConfig(lessonType);

    return Column(
      children: [
        Expanded(child: SingleChildScrollView(child: child)),
        _BottomActionBar(
          isDark: isDark,
          isVideo: isVideo,
          typeColor: tc.color,
          onVideoOpen: onVideoOpen,
          onComplete: onComplete,
        ),
      ],
    );
  }
}

// ─── Bottom Action Bar ────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final bool isDark;
  final bool isVideo;
  final Color typeColor;
  final VoidCallback? onVideoOpen;
  final VoidCallback onComplete;

  const _BottomActionBar({
    required this.isDark,
    required this.isVideo,
    required this.typeColor,
    this.onVideoOpen,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (isVideo && onVideoOpen != null) ...[
            // Primary: Watch video
            _ActionButton(
              onTap: onVideoOpen!,
              gradient: LinearGradient(
                colors: [typeColor, typeColor.withValues(alpha: 0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              icon: Icons.play_arrow_rounded,
              label: 'Videoni ko\'rish',
              iconBg: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 10),
            // Secondary: Mark complete
            _ActionButton(
              onTap: onComplete,
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF1C2D42), Color(0xFF253545)])
                  : LinearGradient(colors: [
                      AppColors.primaryContainer,
                      AppColors.primaryContainer,
                    ]),
              icon: Icons.check_circle_rounded,
              label: 'Ko\'rdim, bajarildi',
              iconBg: isDark
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.12),
              labelColor: isDark ? AppColors.textPrimary : AppColors.primary,
              iconColor: AppColors.primary,
              hasBorder: true,
              borderColor: isDark
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ] else
            _ActionButton(
              onTap: onComplete,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              icon: Icons.check_circle_rounded,
              label: isVideo ? 'Ko\'rdim, bajarildi' : 'O\'qidim, bajarildi',
              iconBg: Colors.white.withValues(alpha: 0.18),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final Gradient gradient;
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color? labelColor;
  final Color? iconColor;
  final bool hasBorder;
  final Color? borderColor;

  const _ActionButton({
    required this.onTap,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.iconBg,
    this.labelColor,
    this.iconColor,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.972 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(14),
            border: widget.hasBorder && widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.iconColor ?? Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.labelColor ?? Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cinematic Video Hero ─────────────────────────────────────────────────────

class _VideoHero extends StatefulWidget {
  final VideoEntity video;
  final bool isDark;

  const _VideoHero({required this.video, required this.isDark});

  @override
  State<_VideoHero> createState() => _VideoHeroState();
}

class _VideoHeroState extends State<_VideoHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: false);
    _pulseAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final video = widget.video;

    // Hero gradient colors
    final heroGrad1 = isDark
        ? const Color(0xFF0C1520)
        : const Color(0xFF1E2A6E);
    final heroGrad2 = isDark
        ? const Color(0xFF152032)
        : const Color(0xFF3B4FCC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cinematic video card ──────────────────────────────────────────
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [heroGrad1, heroGrad2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Decorative noise / grid lines
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter()),
              ),

              // Thumbnail if available
              if (video.thumbnailUrl.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),

              // Vignette overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),

              // Pulsing ring + Play button (centered)
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse ring
                        Opacity(
                          opacity: (1 - _pulseAnim.value).clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 1.0 + _pulseAnim.value * 0.7,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Inner pulse ring
                        Opacity(
                          opacity: ((0.5 - _pulseAnim.value).abs() < 0.5
                                  ? 1.0 - (_pulseAnim.value * 2 - 1).abs()
                                  : 0.0)
                              .clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 1.0 + _pulseAnim.value * 0.35,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Play button circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 2),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Duration badge (bottom right)
              Positioned(
                bottom: 12,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 11, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        video.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category badge (bottom left)
              Positioned(
                bottom: 12,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smart_display_rounded,
                          size: 11,
                          color: Color(0xFF60A5FA)),
                      const SizedBox(width: 4),
                      const Text(
                        'Video dars',
                        style: TextStyle(
                          color: Color(0xFFBFDBFE),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Info section ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                video.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
              ),

              if (video.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  video.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.visibility_outlined,
                    label: '${video.views} ko\'rishlar',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.thumb_up_outlined,
                    label: '${video.likes}',
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Author row
              if (video.authorName.isNotEmpty)
                _AuthorRow(name: video.authorName, isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Grid painter for cinematic texture ──────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Diagonal accent lines
    final diagPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        diagPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ─── Stat chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevated
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Author row ───────────────────────────────────────────────────────────────

class _AuthorRow extends StatelessWidget {
  final String name;
  final bool isDark;

  const _AuthorRow({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Generate color from name hash
    final hue = (name.codeUnits.fold(0, (a, b) => a + b) % 360).toDouble();
    final avatarColor = HSLColor.fromAHSL(1, hue, 0.5, isDark ? 0.4 : 0.55).toColor();
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Muallif',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Article body ─────────────────────────────────────────────────────────────

class _ArticleBody extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _ArticleBody(
      {required this.title, required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type indicator
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withValues(alpha: 0.4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Maqola',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.6),
                  AppColors.success.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.8,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PDF body ─────────────────────────────────────────────────────────────────

class _PdfBody extends StatelessWidget {
  final String title;
  final String description;
  final String? url;
  final bool isDark;
  final VoidCallback onOpen;

  const _PdfBody({
    required this.title,
    required this.description,
    this.url,
    required this.isDark,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PDF hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withValues(alpha: isDark ? 0.2 : 0.08),
                  AppColors.error.withValues(alpha: isDark ? 0.08 : 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.error, size: 36),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.65,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (url != null && url!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Hujjatni ochish',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Fayl havolasi mavjud emas',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _Shimmer({required this.child, required this.isDark});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_anim.value - 0.5, 0),
              end: Alignment(_anim.value + 0.5, 0),
              colors: widget.isDark
                  ? [
                      const Color(0xFF152032),
                      const Color(0xFF253545),
                      const Color(0xFF152032),
                    ]
                  : [
                      const Color(0xFFE9EBF4),
                      const Color(0xFFF5F6FB),
                      const Color(0xFFE9EBF4),
                    ],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final bool isDark;
  final double widthFraction;
  final double borderRadius;
  final EdgeInsets margin;

  const _SkeletonBox({
    required this.height,
    required this.isDark,
    this.widthFraction = 1.0,
    this.borderRadius = 8,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      width: widthFraction < 1.0
          ? MediaQuery.of(context).size.width * widthFraction
          : null,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152032) : const Color(0xFFE9EBF4),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
