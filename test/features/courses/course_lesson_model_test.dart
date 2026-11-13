import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/features/courses/data/models/course_lesson_model.dart';
import 'package:sud_qollanma/features/courses/domain/entities/course_lesson_entity.dart';

void main() {
  group('CourseLessonModel.fromJson', () {
    test('resolves missing refId and durationMinutes from DarsCurriculumSeed', () {
      final lesson = CourseLessonModel.fromJson({
        'id': 'm5_l1',
        'title': "Masofaviy sud majlislarini VKA tizimida o'tkazish tartibi",
        'type': 'article',
        'order': 1,
        'isRequired': true,
        'durationMinutes': 20,
        'xpReward': 20,
      });

      expect(lesson.id, 'm5_l1');
      expect(lesson.type, LessonType.article);
      expect(lesson.refId, 'dars_5_modul_bo_yicha_to_liq_amaliy_qo_llanma_1');
      expect(lesson.sourceCollection, 'knowledge_base');
      expect(lesson.estimatedMinutes, 20);
    });
  });
}
