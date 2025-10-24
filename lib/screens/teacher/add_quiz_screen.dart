import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/question_model.dart';
import '../../models/quiz_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/simple_widgets.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});
  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _title = TextEditingController();
  final _category = TextEditingController();
  List<QuestionModel> _questions = [];
  bool _loading = false;

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionModel(question: '', options: ['', '', '', ''], correctIndex: 0),
      );
    });
  }

  void _saveQuiz() async {
    if (_title.text.trim().isEmpty) {
      showToast('Provide a quiz title');
      return;
    }
    // simple validation for questions
    if (_questions.isEmpty) {
      showToast('Add at least one question');
      return;
    }
    for (var q in _questions) {
      if (q.question.trim().isEmpty) {
        showToast('Fill all question text');
        return;
      }
      if (q.options.any((o) => o.trim().isEmpty)) {
        showToast('Fill all options');
        return;
      }
    }
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final quiz = QuizModel(
      title: _title.text.trim(),
      category: _category.text.trim(),
      createdBy: user.uid,
      questions: _questions,
    );
    await FirestoreService().createQuiz(quiz);
    setState(() => _loading = false);
    showToast('Quiz created');
    Navigator.pop(context);
  }

  Widget _questionCard(int idx) {
    final q = _questions[idx];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: q.question,
              onChanged: (v) => q.question = v,
              decoration: InputDecoration(labelText: 'Question ${idx + 1}'),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextFormField(
                  initialValue: q.options[i],
                  onChanged: (v) => q.options[i] = v,
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Correct:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: q.correctIndex,
                  items: List.generate(
                    4,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text('Option ${i + 1}'),
                    ),
                  ),
                  onChanged: (v) => setState(() => q.correctIndex = v!),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => setState(() => _questions.removeAt(idx)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Quiz Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ...List.generate(_questions.length, (i) => _questionCard(i)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                ],
              ),
            ),
            _loading
                ? const CircularProgressIndicator()
                : AppButton(label: 'Save Quiz', onPressed: _saveQuiz),
          ],
        ),
      ),
    );
  }
}
