import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';
import '../../services/firestore_service.dart';
import 'quiz_play_screen.dart';

class StudentQuizzesPage extends StatelessWidget {
  const StudentQuizzesPage({super.key});

  List<QuizModel> _demoQuizzes() {
    return [
      QuizModel(
        id: 'demo1',
        title: 'General Knowledge Demo',
        category: 'General',
        createdBy: 'system',
        questions: [
          QuestionModel(
            question: 'What is the capital of France?',
            options: ['Paris', 'London', 'Berlin', 'Madrid'],
            correctIndex: 0,
          ),
          QuestionModel(
            question: 'What is 5 x 6?',
            options: ['11', '30', '56', '20'],
            correctIndex: 1,
          ),
        ],
      ),
      QuizModel(
        id: 'demo2',
        title: 'Math Quickies',
        category: 'Math',
        createdBy: 'system',
        questions: [
          QuestionModel(
            question: 'Solve: 9 - 3 = ?',
            options: ['3', '6', '9', '12'],
            correctIndex: 1,
          ),
          QuestionModel(
            question: 'What is sqrt(16)?',
            options: ['2', '3', '4', '5'],
            correctIndex: 2,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final demo = _demoQuizzes();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quizzes'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Open demo quiz',
            icon: const Icon(Icons.play_circle_fill),
            onPressed: () {
              // open first demo quiz
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => QuizPlayScreen(quiz: demo.first)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QuizModel>>(
        stream: FirestoreService().allQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizzes = snapshot.data ?? [];

          // if no quizzes from backend, show demo quizzes
          final listToShow = quizzes.isEmpty ? demo : quizzes;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: listToShow.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final q = listToShow[index];
              final isDemo = quizzes.isEmpty;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text(isDemo ? 'D${index + 1}' : 'Q${index + 1}')),
                  title: Text(q.title),
                  subtitle:
                      Text('${q.questions.length} questions • ${q.category}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => QuizPlayScreen(quiz: q)),
                      );
                    },
                    child: const Text('Start'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
