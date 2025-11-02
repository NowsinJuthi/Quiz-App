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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Colors.blueAccent;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff0f172a) : const Color(0xfff9fbff),
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.transparent,
        foregroundColor: accent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: (_index + 1) / widget.quiz.questions.length,
                color: accent,
                backgroundColor: isDark ? Colors.white10 : Colors.blue.shade50,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 20),

            /// Question
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1e293b) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Q${_index + 1}. ${q.question}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Options
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (context, i) {
                  final selected = answers[_index] == i;
                  return GestureDetector(
                    onTap: () => setState(() => answers[_index] = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withOpacity(0.15)
                            : (isDark
                                ? const Color(0xff1e293b)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? accent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected ? accent : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Buttons
            Row(
              children: [
                if (_index > 0)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _index--),
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.blueGrey : accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: answers[_index] == null ? null : _submitAnswer,
                  icon: Icon(
                    _index == widget.quiz.questions.length - 1
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  label: Text(
                    _index == widget.quiz.questions.length - 1
                        ? 'Finish'
                        : 'Next',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
