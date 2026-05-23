// lib/features/quiz/data/datasources/quiz_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/quiz_attempt_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getQuizzes();
  Future<List<QuizModel>> getQuizzesByResourceId(String resourceId);
  Future<QuizModel?> getQuizById(String id);
  Future<void> submitQuizAttempt(QuizAttemptModel attempt);
  Future<List<QuizAttemptModel>> getUserAttempts(String userId);
  Future<List<QuizAttemptModel>> getRecentUserAttempts(String userId,
      {int limit = 3});

  Future<void> deleteQuiz(String id);
  Future<String> createQuiz(QuizModel quiz);
  Future<void> updateQuiz(QuizModel quiz);
  Future<void> addQuestion(String quizId, QuestionModel question);
  Future<void> deleteQuestion(String quizId, String questionId);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuizRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _quizzes =>
      _firestore.collection('quizzes');
  CollectionReference<Map<String, dynamic>> get _attempts =>
      _firestore.collection('quiz_attempts');

  @override
  Future<List<QuizModel>> getQuizzes() async {
    final snapshot = await _quizzes.get();
    // Note: This fetches quizzes without questions initially for list view optimization
    // unless we decide to always fetch questions.
    // The previous implementation fetched only quiz details in list.
    return snapshot.docs
        .map((doc) => QuizModel.fromFirestore(doc, []))
        .toList();
  }

  @override
  Future<List<QuizModel>> getQuizzesByResourceId(String resourceId) async {
    final snapshot =
        await _quizzes.where('resourceId', isEqualTo: resourceId).get();
    return snapshot.docs
        .map((doc) => QuizModel.fromFirestore(doc, []))
        .toList();
  }

  @override
  Future<QuizModel?> getQuizById(String id) async {
    final doc = await _quizzes.doc(id).get();
    if (!doc.exists) return null;

    final questionsSnapshot =
        await _quizzes.doc(id).collection('questions').get();
    final questions = questionsSnapshot.docs
        .map((qDoc) => QuestionModel.fromFirestore(qDoc))
        .toList();

    // Auto-heal questionCount for legacy quizzes
    final data = doc.data();
    final storedCount = (data?['questionCount'] as num?)?.toInt() ?? 0;
    if (storedCount != questions.length) {
      try {
        await _quizzes.doc(id).update({'questionCount': questions.length});
        // We don't need to re-fetch, QuizModel.fromFirestore will use the passed questions.length anyway
      } catch (_) {}
    }

    return QuizModel.fromFirestore(doc, questions);
  }

  @override
  Future<void> submitQuizAttempt(QuizAttemptModel attempt) async {
    await _attempts.add(attempt.toFirestore());
  }

  @override
  Future<List<QuizAttemptModel>> getUserAttempts(String userId) async {
    final snapshot = await _attempts
        .where('userId', isEqualTo: userId)
        .orderBy('attemptedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => QuizAttemptModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<QuizAttemptModel>> getRecentUserAttempts(String userId,
      {int limit = 3}) async {
    final snapshot = await _attempts
        .where('userId', isEqualTo: userId)
        .orderBy('attemptedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => QuizAttemptModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> deleteQuiz(String id) async {
    // Delete questions subcollection first
    final questionsSnapshot =
        await _quizzes.doc(id).collection('questions').get();
    for (final doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }
    // Delete quiz document
    await _quizzes.doc(id).delete();
  }

  @override
  Future<String> createQuiz(QuizModel quiz) async {
    await _quizzes.doc(quiz.id).set(quiz.toFirestore());
    return quiz.id;
  }

  @override
  Future<void> updateQuiz(QuizModel quiz) async {
    await _quizzes.doc(quiz.id).update(quiz.toFirestore());
  }

  @override
  Future<void> addQuestion(String quizId, QuestionModel question) async {
    // Add question to subcollection
    await _quizzes
        .doc(quizId)
        .collection('questions')
        .add(question.toFirestore());
    // Atomically increment questionCount on parent quiz document
    await _quizzes
        .doc(quizId)
        .update({'questionCount': FieldValue.increment(1)});
  }

  @override
  Future<void> deleteQuestion(String quizId, String questionId) async {
    // Delete question from subcollection
    await _quizzes
        .doc(quizId)
        .collection('questions')
        .doc(questionId)
        .delete();
    // Atomically decrement questionCount on parent quiz document
    await _quizzes
        .doc(quizId)
        .update({'questionCount': FieldValue.increment(-1)});
  }
}
