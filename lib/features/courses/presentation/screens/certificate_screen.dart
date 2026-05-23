import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/domain/entities/user_course_progress_entity.dart';

/// Kurs tugallanganda sertifikat ekrani.
/// Agar certificateUrl bor bo'lsa — PDF yuklash tugmasi chiqadi.
/// Agar yo'q bo'lsa — generatsiya tayyorlanmoqda xabari ko'rinadi.
class CertificateScreen extends StatefulWidget {
  final CourseEntity course;
  final UserCourseProgressEntity progress;

  const CertificateScreen({
    super.key,
    required this.course,
    required this.progress,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _openCertificate() async {
    final url = widget.progress.certificateUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPdf = widget.progress.certificateUrl?.isNotEmpty == true;
    final completedDate = widget.progress.completedAt;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
        title: const Text('Sertifikat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ─── Muvaffaqiyat belgisi ────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isDark ? AppColors.amberGradient : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppColors.amber : AppColors.primary)
                            .withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 56,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Tabriklaymiz!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Siz kursni muvaffaqiyatli tamomlladingiz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 32),

              // ─── Sertifikat kartochkasi ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? AppColors.amber : AppColors.primary)
                        .withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.amber : AppColors.primary)
                          .withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sertifikat nomi
                    Text(
                      widget.course.certificateTitle ?? widget.course.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    const SizedBox(height: 16),

                    // Statistika qatori
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          icon: Icons.star_rounded,
                          value: '${widget.progress.earnedXp} XP',
                          label: 'Qozonilgan',
                          isDark: isDark,
                        ),
                        _StatItem(
                          icon: Icons.check_circle_rounded,
                          value: '${widget.progress.completedLessonIds.length}',
                          label: 'Dars',
                          isDark: isDark,
                        ),
                        if (completedDate != null)
                          _StatItem(
                            icon: Icons.calendar_today_rounded,
                            value: _formatDate(completedDate),
                            label: 'Sana',
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── PDF tugmasi yoki kutish xabari ─────────────────────
              if (hasPdf) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.amber : AppColors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _openCertificate,
                    icon: const Icon(Icons.download_rounded, size: 22),
                    label: const Text(
                      'Sertifikatni yuklab olish (PDF)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.warning),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Sertifikat tayyorlanmoqda. Bir necha daqiqadan so\'ng qayta kiring.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Orqaga qaytish
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(context)
                      .popUntil((r) => r.isFirst || r.settings.name == '/courses'),
                  child: const Text('Kurslarga qaytish'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.amber : AppColors.primary;
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
