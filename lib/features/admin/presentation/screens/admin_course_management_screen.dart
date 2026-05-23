import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/providers/course_provider.dart';
import 'package:sud_qollanma/features/courses/presentation/screens/create_course_screen.dart';

class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({super.key});

  @override
  State<AdminCourseManagementScreen> createState() =>
      _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState
    extends State<AdminCourseManagementScreen> {
  List<CourseEntity> _courses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final provider = context.read<CourseProvider>();
    final courses = await provider.loadAllCoursesAdmin();
    if (mounted) {
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreateScreen({CourseEntity? course}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCourseScreen(course: course),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Kurslar boshqaruvi'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Yangilash',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateScreen(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yangi kurs'),
        backgroundColor: isDark ? AppColors.amber : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? _buildEmpty(isDark)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _CourseAdminTile(
                          course: _courses[i],
                          isDark: isDark,
                          onEdit: () => _openCreateScreen(course: _courses[i]),
                        ),
                  ),
                ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Hali kurs yo\'q',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+ tugmasini bosib birinchi kursni yarating',
            style: TextStyle(
              color: (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)
                  .withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseAdminTile extends StatelessWidget {
  final CourseEntity course;
  final bool isDark;
  final VoidCallback onEdit;

  const _CourseAdminTile({
    required this.course,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: course.isPublished
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            course.isPublished ? Icons.school_rounded : Icons.edit_note_rounded,
            color: course.isPublished ? AppColors.success : AppColors.warning,
            size: 22,
          ),
        ),
        title: Text(
          course.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _StatusBadge(
                label: course.isPublished ? 'Nashr qilingan' : 'Qoralama',
                color: course.isPublished ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                '${course.modules.length} modul · ${course.totalLessonsCount} dars',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.edit_rounded,
            color: isDark ? AppColors.amber : AppColors.primary,
            size: 20,
          ),
          onPressed: onEdit,
          tooltip: 'Tahrirlash',
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
