import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';
import '../teacher/teacher_dashboard.dart'; // For GalaxyPainter & GlassCard

class EditQuizListScreen extends StatelessWidget {
  const EditQuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Dummy Data ----
    final dummyQuizzes = [
      QuizModel(
        id: '1',
        title: 'General Knowledge',
        category: 'Trivia',
        createdBy: 'teacher_demo',
        questions: List.generate(
          10,
          (i) => QuestionModel(
            id: 'gk_${i + 1}',
            question: 'Question ${i + 1}?',
            options: ['A', 'B', 'C', 'D'],
            correctIndex: 0,
          ),
        ),
      ),
      QuizModel(
        id: '2',
        title: 'Science Quiz',
        category: 'Science',
        createdBy: 'teacher_demo',
        questions: List.generate(
          8,
          (i) => QuestionModel(
            id: 'sc_${i + 1}',
            question: 'Science question ${i + 1}?',
            options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
            correctIndex: 1,
          ),
        ),
      ),
      QuizModel(
        id: '3',
        title: 'History Challenge',
        category: 'History',
        createdBy: 'teacher_demo',
        questions: List.generate(
          5,
          (i) => QuestionModel(
            id: 'hs_${i + 1}',
            question: 'History question ${i + 1}?',
            options: ['True', 'False', 'Maybe', 'Unknown'],
            correctIndex: 0,
          ),
        ),
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text(
          '🧩 My Quizzes (Preview)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 20),
            builder: (context, value, _) =>
                CustomPaint(painter: GalaxyPainter(value), size: Size.infinite),
          ),

          // Dummy Quiz List
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 30),
            itemCount: dummyQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = dummyQuizzes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz_rounded,
                          color: Colors.amberAccent, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${quiz.questions.length} Questions • ${quiz.category}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                color: Colors.cyanAccent),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => const AlertDialog(
                                title: Text('Edit Quiz'),
                                content:
                                    Text('Editing feature not implemented.'),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever_rounded,
                                color: Colors.redAccent),
                            onPressed: () {
                              // simple deletion feedback (dummy)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${quiz.title} deleted'),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
