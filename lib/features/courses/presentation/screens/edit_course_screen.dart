// edit_course_screen.dart
//
// Bu fayl CreateCourseScreen ning edit rejimiga qulay shortcut hisoblanadi.
// CreateCourseScreen allaqachon `course` parametrini qabul qiladi:
//   - course == null  → Yangi kurs yaratish
//   - course != null  → Mavjud kursni tahrirlash
//
// Foydalanish:
//   Navigator.pushNamed(context, '/edit_course', arguments: courseEntity)
//
// yoki to'g'ridan-to'g'ri:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => EditCourseScreen(course: courseEntity),
//   ));

import 'package:flutter/material.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_entity.dart';
import 'package:sud_qollanma/features/courses/presentation/screens/create_course_screen.dart';

/// Mavjud kursni tahrirlash ekrani.
///
/// [CreateCourseScreen] ni `course` argumenti bilan chaqiruvchi wrapper.
class EditCourseScreen extends StatelessWidget {
  final CourseEntity course;

  const EditCourseScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return CreateCourseScreen(course: course);
  }
}
