import 'dart:async';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

// Minimal in-memory FirestoreService mock for offline/dev mode.
class FirestoreService {
  final List<QuizModel> _quizzes = [
    QuizModel(
      id: 'demo_local_1',
      title: 'Local Demo Quiz',
      category: 'General',
      createdBy: 'local',
      questions: [
        QuestionModel(
            id: 'q1',
            question: 'What is 2+2?',
            options: ['1', '2', '3', '4'],
            correctIndex: 3),
        QuestionModel(
            id: 'q2',
            question: 'Which color is the sky?',
            options: ['Red', 'Blue', 'Green', 'Yellow'],
            correctIndex: 1),
      ],
    )
  ];

  final StreamController<List<QuizModel>> _ctrl =
      StreamController<List<QuizModel>>.broadcast();

  FirestoreService() {
    _ctrl.add(List<QuizModel>.from(_quizzes));
  }

  Stream<List<QuizModel>> allQuizzes() => _ctrl.stream;

  Future<void> createQuiz(QuizModel quiz) async {
    _quizzes.add(quiz);
    _ctrl.add(List<QuizModel>.from(_quizzes));
    await Future<void>.value();
  }

  Future<void> saveResult(
      QuizModel quiz, int score, int total, Map<int, int> answers) async {
    // no-op for local mode (you can store results in-memory if needed)
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  void dispose() {
    _ctrl.close();
  }
}
