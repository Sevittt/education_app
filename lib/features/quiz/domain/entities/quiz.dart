// lib/features/quiz/domain/entities/quiz.dart
import 'package:equatable/equatable.dart';
import 'question.dart';

class Quiz extends Equatable {
  final String id;
  final String title;
  final String description;
  final String resourceId;
  final List<Question> questions;
  final int questionCount; // Cached count to avoid subcollection fetch in list view

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.resourceId,
    required this.questions,
    int? questionCount,
  }) : questionCount = questionCount ?? questions.length;

  @override
  List<Object?> get props => [id, title, description, resourceId, questions, questionCount];
}
