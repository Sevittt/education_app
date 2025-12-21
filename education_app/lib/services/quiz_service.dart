import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';
import 'xapi_service.dart';

class QuizService {
  final CollectionReference<Map<String, dynamic>> _quizzesCollection =
      FirebaseFirestore.instance.collection('quizzes');
  final CollectionReference<Map<String, dynamic>> _attemptsCollection =
      FirebaseFirestore.instance.collection('quiz_attempts');

  // --- Admin Dashboard uchun hamma testlarni olish ---
  Stream<List<Quiz>> getAllQuizzesStream() {
    return _quizzesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // --- Yangi test qo'shish ---
  Future<String> addQuiz(Quiz quiz) async {
    final docRef = await _quizzesCollection.add(quiz.toMap());
    return docRef.id;
  }

  // --- Yangi test yaratish (createQuiz alias) ---
  Future<String> createQuiz(Quiz quiz) async {
    return await addQuiz(quiz);
  }

  // --- Barcha testlarni olish ---
  Stream<List<Quiz>> getQuizzes() {
    return _quizzesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // --- Resurs ID bo'yicha testlarni olish ---
  Stream<List<Quiz>> getQuizzesByResourceId(String resourceId) {
    return _quizzesCollection
        .where('resourceId', isEqualTo: resourceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // --- Resurs uchun testlarni olish (Future versiyasi) ---
  Future<List<Quiz>> getQuizzesForResource(String resourceId) async {
    final snapshot = await _quizzesCollection
        .where('resourceId', isEqualTo: resourceId)
        .get();
    
    return snapshot.docs.map((doc) {
      return Quiz.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // --- Test va uning savollarini olish ---
  Future<Quiz?> getQuizWithQuestions(String quizId) async {
    try {
      final quizDoc = await _quizzesCollection.doc(quizId).get();
      
      if (!quizDoc.exists) return null;
      
      // Savollar sub-collection dan olinadi
      final questionsSnapshot = await _quizzesCollection
          .doc(quizId)
          .collection('questions')
          .get();
      
      final questions = questionsSnapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
      
      return Quiz.fromFirestore(quizDoc, questions);
    } catch (e) {
      print("Error getting quiz with questions: $e");
      return null;
    }
  }

  // --- Testga savol qo'shish ---
  Future<void> addQuestionToQuiz(String quizId, Question question) async {
    await _quizzesCollection
        .doc(quizId)
        .collection('questions')
        .add(question.toFirestore());
  }

  // --- Test savollarini olish (Stream) ---
  Stream<List<Question>> getQuestionsForQuiz(String quizId) {
    return _quizzesCollection
        .doc(quizId)
        .collection('questions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    });
  }

  // --- Test urinishini saqlash ---
  Future<void> saveQuizAttempt(QuizAttempt attempt) async {
    await _attemptsCollection.add(attempt.toMap());
    
    // xAPI Tracking
    try {
      final double percentage = attempt.totalQuestions > 0 
          ? (attempt.score / attempt.totalQuestions) * 100 
          : 0.0;
      
      final bool passed = percentage >= 70.0; // Assuming 70% is passing

      await XApiService().trackQuizCompleted(
        quizId: attempt.quizId,
        title: attempt.quizTitle,
        score: percentage, // Sending percentage as score (0-100)
        passed: passed,
        timeTakenSeconds: attempt.timeTakenSeconds,
      );
    } catch (e) {
      print("xAPI Error in saveQuizAttempt: $e");
    }
  }

  // --- Foydalanuvchi urinishlarini olish ---
  Stream<List<QuizAttempt>> getAttemptsForUser(String userId) {
    return _attemptsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('attemptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuizAttempt.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // --- NEW: Gets only recent attempts (for Profile Preview) ---
  Stream<List<QuizAttempt>> getRecentAttempts(String userId, {int limit = 3}) {
    return _attemptsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('attemptedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuizAttempt.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // --- Testni o'chirish ---
  Future<void> deleteQuiz(String quizId) async {
    // Avval barcha savollarni o'chirish
    final questionsSnapshot = await _quizzesCollection
        .doc(quizId)
        .collection('questions')
        .get();
    
    for (var doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Keyin testning o'zini o'chirish
    await _quizzesCollection.doc(quizId).delete();
  }

  // --- Test ma'lumotlarini yangilash ---
  Future<void> updateQuizDetails(String quizId, Map<String, dynamic> data) async {
    await _quizzesCollection.doc(quizId).update(data);
  }
}
