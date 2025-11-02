import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final QuizModel quiz;
  final Map<int, int> answers;
  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.quiz,
    required this.answers,
  });

  // demo helper to quickly open this screen with dummy data
  static Widget demo() {
    final demoQuiz = QuizModel(
      id: 'demo1',
      title: 'Demo Quiz Result',
      category: 'Demo',
      createdBy: 'system',
      questions: [
        QuestionModel(
          question: 'Capital of France?',
          options: ['Paris', 'London', 'Rome', 'Madrid'],
          correctIndex: 0,
        ),
        QuestionModel(
          question: '2 + 2 = ?',
          options: ['3', '4', '5', '6'],
          correctIndex: 1,
        ),
      ],
    );
    final demoAnswers = <int, int>{0: 0, 1: 1}; // both correct
    return QuizResultScreen(
        score: 2,
        total: demoQuiz.questions.length,
        quiz: demoQuiz,
        answers: demoAnswers);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Colors.blueAccent;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0f172a) : const Color(0xfff9fbff),
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: accent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Score Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    'Your Score',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$score / $total',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accuracy: ${(score / total * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Question-wise Review
            Expanded(
              child: ListView.builder(
                itemCount: quiz.questions.length,
                itemBuilder: (c, i) {
                  final q = quiz.questions[i];
                  final chosen = answers[i];
                  final correct = q.correctIndex;
                  final correctText = q.options[correct];
                  final chosenText =
                      chosen != null ? q.options[chosen] : 'Not answered';
                  final correctAnswer = chosen == correct;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff1e293b) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: correctAnswer
                            ? Colors.greenAccent
                            : Colors.redAccent.withOpacity(0.6),
                        width: 1.2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      title: Text(
                        q.question,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            'Your answer: $chosenText',
                            style: TextStyle(
                                color: correctAnswer
                                    ? Colors.greenAccent
                                    : Colors.redAccent),
                          ),
                          Text('Correct answer: $correctText',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      trailing: Icon(
                          correctAnswer
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: correctAnswer
                              ? Colors.greenAccent
                              : Colors.redAccent),
                    ),
                  );
                },
              ),
            ),

            /// Back Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
