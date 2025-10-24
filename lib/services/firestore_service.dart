import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // quizzes CRUD
  Future<String> createQuiz(QuizModel quiz) async {
    final doc = _db.collection('quizzes').doc();
    quiz.id = doc.id;
    await doc.set(quiz.toMap());
    return doc.id;
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    await _db.collection('quizzes').doc(quiz.id).update(quiz.toMap());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _db.collection('quizzes').doc(quizId).delete();
    // Optionally delete related results
  }

  Stream<List<QuizModel>> teacherQuizzes(String teacherId) {
    return _db
        .collection('quizzes')
        .where('createdBy', isEqualTo: teacherId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => QuizModel.fromMap(d.data())).toList(),
        );
  }

  Stream<List<QuizModel>> allQuizzes() {
    return _db
        .collection('quizzes')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => QuizModel.fromMap(d.data())).toList(),
        );
  }

  // results
  Future<void> saveResult({
    required String studentId,
    required String studentEmail,
    required String quizId,
    required String quizTitle,
    required int score,
    required int total,
  }) async {
    await _db.collection('results').add({
      'studentId': studentId,
      'studentEmail': studentEmail,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'total': total,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getResultsForTeacher(String teacherId) {
    // teacherId optional filter if results store teacher info; for simplicity just return all and teacher filters client-side
    return _db
        .collection('results')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) {
            final m = d.data();
            m['id'] = d.id;
            return m;
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getResultsForStudent(String studentId) {
    return _db
        .collection('results')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) {
            final m = d.data();
            m['id'] = d.id;
            return m;
          }).toList(),
        );
  }
}
