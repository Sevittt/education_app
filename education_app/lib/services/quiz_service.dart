// lib/services/quiz_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
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
        // Assuming Quiz.fromFirestore can handle potential issues or is robust
        return Quiz.fromFirestore(doc, []);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error in getQuizzesForResource for resource ID $resourceId: $e");
      }
      return []; // Return empty list on error
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
                // It's good practice to order questions if their order matters
                // For example, by a dedicated 'order' field or by document ID if that's acceptable
                // .orderBy('orderIndex') // Example: if you have an 'orderIndex' field
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
      if (kDebugMode) {
        print("Error in getQuizWithQuestions for quiz ID $quizId: $e");
      }
      return null;
    }
  }

  /// Saves a user's quiz attempt to the 'quiz_attempts' collection.
  Future<void> saveQuizAttempt(QuizAttempt attempt) async {
    try {
      await _firestore.collection('quiz_attempts').add(attempt.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print(
          "Error in saveQuizAttempt for quiz ID ${attempt.quizId}, user ${attempt.userId}: $e",
        );
      }
      rethrow; // Rethrow so the UI can handle it
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
      if (kDebugMode) {
        print("Error in createQuiz for title '${quiz.title}': $e");
      }
      rethrow;
    }
  }

  /// Retrieves a live stream of quiz attempts for a specific user.
  Stream<List<QuizAttempt>> getAttemptsForUser(String userId) {
    return _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: userId)
        .orderBy('attemptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          List<QuizAttempt> attempts = [];
          for (var doc in snapshot.docs) {
            try {
              // Attempt to parse each document.
              attempts.add(QuizAttempt.fromFirestore(doc));
            } catch (e) {
              // If QuizAttempt.fromFirestore throws an error (e.g., FormatException for null data),
              // log it and skip this problematic document.
              if (kDebugMode) {
                print(
                  "Error parsing QuizAttempt from Firestore doc ID ${doc.id}: $e. Skipping this item.",
                );
              }
              // Optionally, report this error to a more robust logging service in production.
            }
          }
          return attempts; // Return the list of successfully parsed attempts.
        });
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
      if (kDebugMode) {
        print(
          "Error in addQuestionToQuiz for quiz ID $quizId, question text '${question.questionText}': $e",
        );
      }
      rethrow;
    }
  }

  /// Retrieves a live stream of questions for a specific quiz.
  Stream<List<Question>> getQuestionsForQuiz(String quizId) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        // Consider ordering questions if their display order is important
        // .orderBy('questionOrder') // Example
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList(),
        )
        .handleError((error) {
          // Catch errors from the stream itself or from Question.fromFirestore if not caught internally
          if (kDebugMode) {
            print(
              "Error in getQuestionsForQuiz stream for quiz ID $quizId: $error",
            );
          }
          // Depending on UI needs, you might want to return an empty list or rethrow
          // For StreamBuilder, rethrowing will allow snapshot.hasError to be true.
          throw error;
        });
  }

  /// Fetches a stream of all quizzes. Intended for admin use.
  /// Note: This fetches quiz metadata only (questions are not eagerly loaded).
  Stream<List<Quiz>> getAllQuizzesStream({
    String? orderByField,
    bool descending = false,
  }) {
    Query query = _firestore.collection('quizzes');
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    return query
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Quiz.fromFirestore(doc, []);
                } catch (e) {
                  if (kDebugMode) {
                    print(
                      "Error parsing Quiz from Firestore doc ID ${doc.id}: $e. Skipping.",
                    );
                  }
                  return null;
                }
              })
              .where((quiz) => quiz != null)
              .cast<Quiz>()
              .toList();
        })
        .handleError((error) {
          if (kDebugMode) {
            print("Error in getAllQuizzesStream: $error");
          }
          throw error;
        });
  }

  /// Deletes a quiz and all its questions
  Future<void> deleteQuizAndQuestions(String quizId) async {
    try {
      final questionsSnapshot =
          await _firestore
              .collection('quizzes')
              .doc(quizId)
              .collection('questions')
              .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in questionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _firestore.collection('quizzes').doc(quizId).delete();

      if (kDebugMode) {
        print("Quiz $quizId and its questions deleted successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting quiz $quizId and its questions: $e");
      }
      rethrow;
    }
  }

  /// Updates quiz details
  Future<void> updateQuizDetails(
    String quizId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update(data);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating quiz details for $quizId: $e");
      }
      rethrow;
    }
  }
}
