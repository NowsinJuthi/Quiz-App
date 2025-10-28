import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Score: $score / $total',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                  return Card(
                    child: ListTile(
                      title: Text(q.question),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text('Your answer: $chosenText'),
                          Text('Correct: $correctText'),
                        ],
                      ),
                      trailing: Icon(
                        chosen == correct ? Icons.check_circle : Icons.cancel,
                        color: chosen == correct ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
