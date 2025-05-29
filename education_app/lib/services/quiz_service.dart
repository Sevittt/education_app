// lib/services/quiz_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a list of quiz metadata for a specific learning resource.
  /// Note: This does NOT fetch the questions to keep the payload light.
  Future<List<Quiz>> getQuizzesForResource(String resourceId) async {
    try {
      QuerySnapshot quizSnapshot =
          await _firestore
              .collection('quizzes')
              .where('resourceId', isEqualTo: resourceId)
              .get();

      // Map the documents to Quiz objects, but with an empty questions list for now.
      // The full questions will be loaded only when the user selects a specific quiz.
      return quizSnapshot.docs.map((doc) {
        return Quiz.fromFirestore(doc, []);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches a single, complete quiz document along with all its questions from the sub-collection.
  Future<Quiz?> getQuizWithQuestions(String quizId) async {
    try {
      DocumentSnapshot quizDoc =
          await _firestore.collection('quizzes').doc(quizId).get();

      if (quizDoc.exists) {
        // Fetch the 'questions' sub-collection for this quiz
        QuerySnapshot questionsSnapshot =
            await _firestore
                .collection('quizzes')
                .doc(quizId)
                .collection('questions')
                .get();

        List<Question> questions =
            questionsSnapshot.docs
                .map((doc) => Question.fromFirestore(doc))
                .toList();

        // Assemble the full Quiz object with its questions
        return Quiz.fromFirestore(quizDoc, questions);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Saves a user's quiz attempt to the 'quiz_attempts' collection.
  Future<void> saveQuizAttempt(QuizAttempt attempt) async {
    try {
      await _firestore.collection('quiz_attempts').add(attempt.toFirestore());
    } catch (e) {
      // Rethrow the error so it can be handled in the UI if needed
      rethrow;
    }
  }

  /// Creates a new quiz document and returns its ID.
  /// Questions are not saved here, they will be added to a sub-collection later.
  Future<String> createQuiz(Quiz quiz) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('quizzes')
          .add(quiz.toFirestore());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }
  // Add these two functions inside the QuizService class in lib/services/quiz_service.dart
  // Add this function inside the QuizService class

  /// Retrieves a live stream of quiz attempts for a specific user.
  Stream<List<QuizAttempt>> getAttemptsForUser(String userId) {
    return _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: userId)
        .orderBy('attemptedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => QuizAttempt.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Adds a Question document to the sub-collection of a specific Quiz.
  Future<void> addQuestionToQuiz(String quizId, Question question) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .add(question.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves a live stream of questions for a specific quiz.
  Stream<List<Question>> getQuestionsForQuiz(String quizId) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList(),
        );
  }
}
