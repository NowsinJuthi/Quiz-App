import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/quiz_model.dart';
import '../../services/firestore_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _index = 0;
  Map<int, int> answers = {}; // questionIndex -> chosenOption
  int score = 0;

  void _submitAnswer() {
    setState(() {
      if (_index < widget.quiz.questions.length - 1)
        _index++;
      else
        _finishQuiz();
    });
  }

  void _finishQuiz() async {
    score = 0;
    final total = widget.quiz.questions.length;
    for (int i = 0; i < total; i++) {
      final q = widget.quiz.questions[i];
      final chosen = answers[i];
      if (chosen != null && chosen == q.correctIndex) score++;
    }
    final user = FirebaseAuth.instance.currentUser!;
    await FirestoreService().saveResult(
      studentId: user.uid,
      studentEmail: user.email ?? '',
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      score: score,
      total: total,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          score: score,
          total: total,
          quiz: widget.quiz,
          answers: answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[_index];
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / widget.quiz.questions.length,
            ),
            const SizedBox(height: 12),
            Text(
              'Q${_index + 1}. ${q.question}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(q.options.length, (i) {
              final selected = answers[_index] == i;
              return ListTile(
                title: Text(q.options[i]),
                leading: Radio<int>(
                  value: i,
                  groupValue: answers[_index],
                  onChanged: (v) => setState(() => answers[_index] = v!),
                ),
                tileColor: selected ? Colors.grey.shade100 : null,
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_index > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => _index--),
                    child: const Text('Previous'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: answers[_index] == null ? null : _submitAnswer,
                  child: Text(
                    _index == widget.quiz.questions.length - 1
                        ? 'Finish'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
