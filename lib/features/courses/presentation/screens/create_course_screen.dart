import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../data/models/course_module_model.dart';
import '../../data/models/course_lesson_model.dart';
import '../providers/course_provider.dart';
import '../../../../core/constants/app_colors.dart';

// ── Muvaqqat ma'lumot tashuvchilar (mutable, TextEditingController bilan) ──

class _LessonData {
  final String id;
  final TextEditingController titleCtrl;
  final TextEditingController refIdCtrl;
  final TextEditingController minutesCtrl;
  LessonType type;
  bool isRequired;

  _LessonData({
    required this.id,
    String title = '',
    String refId = '',
    String minutes = '10',
    this.type = LessonType.video,
    this.isRequired = true,
  })  : titleCtrl = TextEditingController(text: title),
        refIdCtrl = TextEditingController(text: refId),
        minutesCtrl = TextEditingController(text: minutes);

  factory _LessonData.fromEntity(CourseLessonEntity e) => _LessonData(
        id: e.id,
        title: e.title,
        refId: e.refId,
        minutes: e.estimatedMinutes?.toString() ?? '10',
        type: e.type,
        isRequired: e.isRequired,
      );

  void dispose() {
    titleCtrl.dispose();
    refIdCtrl.dispose();
    minutesCtrl.dispose();
  }

  static String _sourceFor(LessonType t) {
    switch (t) {
      case LessonType.video:   return 'video_tutorials';
      case LessonType.article: return 'knowledge_base';
      case LessonType.pdf:     return 'resources';
      case LessonType.quiz:    return 'quizzes';
    }
  }

  CourseLessonModel toModel(int order) => CourseLessonModel(
        id: id.isEmpty ? _uid() : id,
        title: titleCtrl.text.trim(),
        order: order,
        type: type,
        refId: refIdCtrl.text.trim(),
        sourceCollection: _sourceFor(type),
        estimatedMinutes: int.tryParse(minutesCtrl.text) ?? 10,
        isRequired: isRequired,
      );
}

class _ModuleData {
  final String id;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final List<_LessonData> lessons;
  bool expanded;

  _ModuleData({
    required this.id,
    String title = '',
    String desc = '',
    List<_LessonData>? lessons,
    this.expanded = true,
  })  : titleCtrl = TextEditingController(text: title),
        descCtrl = TextEditingController(text: desc),
        lessons = lessons ?? [];

  factory _ModuleData.fromEntity(CourseModuleEntity e) => _ModuleData(
        id: e.id,
        title: e.title,
        desc: e.description,
        lessons: e.lessons.map(_LessonData.fromEntity).toList(),
        expanded: false,
      );

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    for (final l in lessons) { l.dispose(); }
  }

  CourseModuleModel toModel(int order) => CourseModuleModel(
        id: id.isEmpty ? _uid() : id,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        order: order,
        lessons: lessons
            .asMap()
            .entries
            .map((e) => e.value.toModel(e.key + 1))
            .toList(),
      );
}

String _uid() {
  final now = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
  return now.padLeft(20, '0').substring(0, 20);
}

// ─────────────────────────────────────────────────────────────────────────────

class CreateCourseScreen extends StatefulWidget {
  final CourseEntity? course;

  const CreateCourseScreen({super.key, this.course});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _thumbController;
  late TextEditingController _minutesController;
  late TextEditingController _orderController;
  late TextEditingController _certTitleController;

  CourseDifficulty _selectedDifficulty = CourseDifficulty.beginner;
  bool _isPublished = false;
  bool _hasCertificate = false;

  static const List<String> _availableRoles = [
    'judge', 'assistant', 'chancellery', 'archive', 'ict_specialist',
  ];
  static const Map<String, String> _roleLabels = {
    'judge': 'Sudya',
    'assistant': 'Yordamchi',
    'chancellery': 'Kotibiyat',
    'archive': 'Arxiv',
    'ict_specialist': 'IKT mutaxassis',
  };
  final Set<String> _selectedRoles = {};

  final List<_ModuleData> _modules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleController   = TextEditingController(text: c?.title ?? '');
    _descController    = TextEditingController(text: c?.description ?? '');
    _thumbController   = TextEditingController(text: c?.thumbnailUrl ?? '');
    _minutesController = TextEditingController(text: c?.estimatedMinutes.toString() ?? '60');
    _orderController   = TextEditingController(text: c?.order.toString() ?? '0');
    _certTitleController = TextEditingController(text: c?.certificateTitle ?? '');

    if (c != null) {
      _selectedDifficulty = c.difficulty;
      _isPublished        = c.isPublished;
      _hasCertificate     = c.hasCertificate;
      _selectedRoles.addAll(c.targetRole);
      _modules.addAll(c.modules.map(_ModuleData.fromEntity));
    } else {
      _selectedRoles.add('judge');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _thumbController.dispose();
    _minutesController.dispose();
    _orderController.dispose();
    _certTitleController.dispose();
    for (final m in _modules) { m.dispose(); }
    super.dispose();
  }

  // ── Saqlash ───────────────────────────────────────────────────────────────

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      _snack('Kamida bitta rol tanlang!');
      return;
    }
    if (_hasCertificate && _certTitleController.text.trim().isEmpty) {
      _snack('Sertifikat sarlavhasini kiriting!');
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<CourseProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    final builtModules = _modules
        .asMap()
        .entries
        .map((e) => e.value.toModel(e.key + 1))
        .toList();

    final newCourse = CourseEntity(
      id: widget.course?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      thumbnailUrl: _thumbController.text.trim().isEmpty ? null : _thumbController.text.trim(),
      targetRole: _selectedRoles.toList(),
      difficulty: _selectedDifficulty,
      estimatedMinutes: int.tryParse(_minutesController.text) ?? 60,
      modules: builtModules,
      isPublished: _isPublished,
      createdAt: widget.course?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      authorId: widget.course?.authorId ?? user?.uid ?? 'system',
      order: int.tryParse(_orderController.text) ?? 0,
      hasCertificate: _hasCertificate,
      certificateTitle: _hasCertificate && _certTitleController.text.isNotEmpty
          ? _certTitleController.text.trim()
          : null,
    );

    final nav = Navigator.of(context);
    try {
      bool success;
      if (widget.course == null) {
        final id = await provider.createCourse(newCourse);
        success = id != null;
      } else {
        success = await provider.updateCourse(newCourse);
      }
      if (success) {
        nav.pop(true);
      } else {
        _snack('Xatolik: ${provider.error}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Modul operatsiyalari ──────────────────────────────────────────────────

  void _addModule() {
    setState(() => _modules.add(_ModuleData(id: '', expanded: true)));
  }

  void _removeModule(int idx) {
    setState(() {
      _modules[idx].dispose();
      _modules.removeAt(idx);
    });
  }

  void _addLesson(int moduleIdx) {
    setState(() => _modules[moduleIdx].lessons.add(_LessonData(id: '')));
  }

  void _removeLesson(int moduleIdx, int lessonIdx) {
    setState(() {
      _modules[moduleIdx].lessons[lessonIdx].dispose();
      _modules[moduleIdx].lessons.removeAt(lessonIdx);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.course != null;

    final bgColor    = isDark ? AppColors.scaffoldDark : AppColors.backgroundLight;
    final fillColor  = isDark ? AppColors.surfaceDark  : AppColors.surfaceLight;
    final labelColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final textColor  = isDark ? AppColors.textPrimary  : AppColors.textPrimaryLight;
    final activeColor = isDark ? AppColors.amber : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Kursni tahrirlash' : 'Yangi kurs yaratish'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              tooltip: "O'chirish",
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: activeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Asosiy ma'lumotlar ─────────────────────────────────
                    _field(_titleController, 'Sarlavha', fillColor, labelColor, textColor, activeColor,
                        validator: (v) => v!.trim().isEmpty ? 'Majburiy' : null),
                    const SizedBox(height: 14),
                    _field(_descController, 'Tavsif', fillColor, labelColor, textColor, activeColor, maxLines: 3),
                    const SizedBox(height: 14),
                    _field(_thumbController, 'Rasm URL (ixtiyoriy)', fillColor, labelColor, textColor, activeColor),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _field(_minutesController, 'Davomiylik (daqiqa)', fillColor, labelColor, textColor, activeColor,
                          keyboard: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_orderController, 'Tartib', fillColor, labelColor, textColor, activeColor,
                          keyboard: TextInputType.number)),
                    ]),
                    const SizedBox(height: 14),

                    // ── Qiyinlik ───────────────────────────────────────────
                    _label('Qiyinlik darajasi', labelColor),
                    const SizedBox(height: 6),
                    _difficultyDropdown(fillColor, textColor, activeColor, isDark),
                    const SizedBox(height: 16),

                    // ── Rollar ─────────────────────────────────────────────
                    _label('Kimlar uchun?', labelColor),
                    const SizedBox(height: 8),
                    _rolesWrap(activeColor, fillColor, labelColor),
                    const SizedBox(height: 16),

                    // ── Nashr / Sertifikat ─────────────────────────────────
                    _switchTile('Nashr etilgan', "Foydalanuvchilarga ko'rinadimi",
                        _isPublished, (v) => setState(() => _isPublished = v),
                        AppColors.success, fillColor, textColor, labelColor, isDark),
                    const SizedBox(height: 10),
                    _switchTile('Sertifikat beriladi', 'Kurs yakunida PDF sertifikat',
                        _hasCertificate, (v) => setState(() => _hasCertificate = v),
                        activeColor, fillColor, textColor, labelColor, isDark),
                    if (_hasCertificate) ...[
                      const SizedBox(height: 12),
                      _field(_certTitleController, 'Sertifikat sarlavhasi', fillColor, labelColor, textColor, activeColor,
                          validator: (v) => _hasCertificate && v!.trim().isEmpty ? 'Majburiy' : null),
                    ],
                    const SizedBox(height: 28),

                    // ── Modullar ───────────────────────────────────────────
                    _buildModulesSection(fillColor, labelColor, textColor, activeColor, isDark),
                    const SizedBox(height: 28),

                    // ── Saqlash tugmasi ────────────────────────────────────
                    ElevatedButton(
                      onPressed: _saveCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Saqlash' : 'Kurs yaratish',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Modullar sektsiyasi ───────────────────────────────────────────────────

  Widget _buildModulesSection(Color fill, Color label, Color text, Color active, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.view_module_rounded, color: active, size: 20),
            const SizedBox(width: 8),
            Text('Modullar (${_modules.length})',
                style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton.icon(
              onPressed: _addModule,
              icon: Icon(Icons.add, size: 18, color: active),
              label: Text('Modul qo\'shish', style: TextStyle(color: active, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_modules.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Center(
              child: Text('Hozircha modullar yo\'q. "Modul qo\'shish" tugmasini bosing.',
                  style: TextStyle(color: label, fontSize: 13), textAlign: TextAlign.center),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _modules.length,
            onReorder: (oldIdx, newIdx) {
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final m = _modules.removeAt(oldIdx);
                _modules.insert(newIdx, m);
              });
            },
            itemBuilder: (ctx, i) {
              return _buildModuleCard(i, fill, label, text, active, isDark,
                  key: ValueKey('module_$i'));
            },
          ),
      ],
    );
  }

  Widget _buildModuleCard(int mi, Color fill, Color label, Color text, Color active, bool isDark,
      {required Key key}) {
    final mod = _modules[mi];
    return Card(
      key: key,
      color: fill,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: mod.expanded,
          onExpansionChanged: (v) => setState(() => mod.expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: ReorderableDragStartListener(
            index: mi,
            child: Icon(Icons.drag_handle_rounded, color: label, size: 20),
          ),
          title: mod.titleCtrl.text.isEmpty
              ? Text('Modul ${mi + 1}', style: TextStyle(color: label, fontSize: 14))
              : Text(mod.titleCtrl.text, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${mod.lessons.length} dars', style: TextStyle(color: label, fontSize: 12)),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _removeModule(mi),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(mod.titleCtrl, 'Modul nomi', fill, label, text, active,
                      validator: (v) => v!.trim().isEmpty ? 'Majburiy' : null,
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 10),
                  _field(mod.descCtrl, 'Tavsif (ixtiyoriy)', fill, label, text, active),
                  const SizedBox(height: 14),

                  // ── Darslar ──────────────────────────────────────────────
                  Row(children: [
                    Text('Darslar', style: TextStyle(color: label, fontSize: 13, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _addLesson(mi),
                      icon: Icon(Icons.add, size: 16, color: active),
                      label: Text('Dars qo\'shish', style: TextStyle(color: active, fontSize: 12)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  if (mod.lessons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Bu modulda hozircha darslar yo\'q.',
                          style: TextStyle(color: label, fontSize: 12), textAlign: TextAlign.center),
                    )
                  else
                    ...mod.lessons.asMap().entries.map((e) =>
                        _buildLessonCard(mi, e.key, fill, label, text, active, isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(int mi, int li, Color fill, Color label, Color text, Color active, bool isDark) {
    final les = _modules[mi].lessons[li];
    final cardColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.5)
        : AppColors.backgroundLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sarlavha + o'chirish
          Row(children: [
            Expanded(
              child: _field(les.titleCtrl, 'Dars nomi ${li + 1}', fill, label, text, active,
                  validator: (v) => v!.trim().isEmpty ? 'Majburiy' : null,
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
              onPressed: () => _removeLesson(mi, li),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
          const SizedBox(height: 8),

          // Tur dropdown + refId
          Row(children: [
            Expanded(
              flex: 2,
              child: _lessonTypeDropdown(les, fill, text, label, active, isDark),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _field(les.refIdCtrl, 'Firestore Doc ID', fill, label, text, active,
                  validator: (v) => v!.trim().isEmpty ? 'Majburiy' : null),
            ),
          ]),
          const SizedBox(height: 8),

          // Daqiqa + isRequired
          Row(children: [
            SizedBox(
              width: 110,
              child: _field(les.minutesCtrl, 'Daqiqa', fill, label, text, active,
                  keyboard: TextInputType.number),
            ),
            const Spacer(),
            Text('Majburiy', style: TextStyle(color: label, fontSize: 12)),
            const SizedBox(width: 4),
            Switch(
              value: les.isRequired,
              onChanged: (v) => setState(() => les.isRequired = v),
              activeThumbColor: active,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _lessonTypeDropdown(_LessonData les, Color fill, Color text, Color label, Color active, bool isDark) {
    const typeIcons = {
      LessonType.video:   Icons.play_circle_outline,
      LessonType.article: Icons.article_outlined,
      LessonType.pdf:     Icons.picture_as_pdf_outlined,
      LessonType.quiz:    Icons.quiz_outlined,
    };
    const typeLabels = {
      LessonType.video:   'Video',
      LessonType.article: 'Maqola',
      LessonType.pdf:     'PDF',
      LessonType.quiz:    'Quiz',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LessonType>(
          value: les.type,
          dropdownColor: fill,
          style: TextStyle(color: text, fontSize: 13),
          isExpanded: true,
          items: LessonType.values.map((t) => DropdownMenuItem(
            value: t,
            child: Row(children: [
              Icon(typeIcons[t], size: 16, color: active),
              const SizedBox(width: 6),
              Text(typeLabels[t]!),
            ]),
          )).toList(),
          onChanged: (v) { if (v != null) setState(() => les.type = v); },
        ),
      ),
    );
  }

  // ── O'chirish tasdiqlash ──────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("O'chirish"),
        content: const Text("Rostdan ham ushbu kursni o'chirasizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Yo'q")),
          TextButton(onPressed: () => Navigator.pop(c, true),
              child: const Text('Ha', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _isLoading = true);
    final provider = Provider.of<CourseProvider>(context, listen: false);
    await provider.deleteCourse(widget.course!.id);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kurs muvaffaqiyatli o'chirildi")));
      Navigator.of(context).pop(true);
    }
  }

  // ── Yordamchi widget qurichilar ───────────────────────────────────────────

  Widget _label(String t, Color c) => Text(t,
      style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _field(
    TextEditingController ctrl,
    String label,
    Color fill,
    Color labelColor,
    Color textColor,
    Color active, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: TextStyle(color: textColor, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor, fontSize: 13),
        filled: true,
        fillColor: fill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: active, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      ),
      validator: validator,
    );
  }

  Widget _difficultyDropdown(Color fill, Color text, Color active, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CourseDifficulty>(
          value: _selectedDifficulty,
          dropdownColor: fill,
          style: TextStyle(color: text),
          isExpanded: true,
          items: CourseDifficulty.values
              .map((d) => DropdownMenuItem(value: d, child: Text(d.displayName)))
              .toList(),
          onChanged: (v) { if (v != null) setState(() => _selectedDifficulty = v); },
        ),
      ),
    );
  }

  Widget _rolesWrap(Color active, Color fill, Color label) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableRoles.map((role) {
        final sel = _selectedRoles.contains(role);
        return FilterChip(
          label: Text(_roleLabels[role] ?? role),
          selected: sel,
          showCheckmark: sel,
          selectedColor: active.withValues(alpha: 0.18),
          checkmarkColor: active,
          backgroundColor: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: sel ? active : Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          labelStyle: TextStyle(
            color: sel ? active : label,
            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
          ),
          onSelected: (v) => setState(() => v ? _selectedRoles.add(role) : _selectedRoles.remove(role)),
        );
      }).toList(),
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, ValueChanged<bool> onChange,
      Color active, Color fill, Color text, Color label, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: text, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: label, fontSize: 12)),
        activeThumbColor: active,
        activeTrackColor: active.withValues(alpha: 0.5),
        value: value,
        onChanged: onChange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
