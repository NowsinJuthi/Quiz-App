import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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

  Future<void> _saveQuiz() async {
    if (_title.text.trim().isEmpty) {
      showToast('Provide a quiz title');
      return;
    }
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
    final user = AuthService().currentUser;
    final uid = user?.uid ?? 'local_user';
    final quiz = QuizModel(
      title: _title.text.trim(),
      category: _category.text.trim(),
      createdBy: uid,
      questions: _questions,
    );

    await FirestoreService().createQuiz(quiz);
    setState(() => _loading = false);
    showToast('Quiz created');
    Navigator.pop(context);
  }

  Widget _questionCard(int idx) {
    final q = _questions[idx];
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: q.question,
            onChanged: (v) => q.question = v,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Question ${idx + 1}',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amberAccent)),
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                initialValue: q.options[i],
                onChanged: (v) => q.options[i] = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Option ${i + 1}',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Correct:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                dropdownColor: const Color(0xFF2A1B5A),
                value: q.correctIndex,
                items: List.generate(
                  4,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text('Option ${i + 1}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                onChanged: (v) => setState(() => q.correctIndex = v!),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () => setState(() => _questions.removeAt(idx)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text('✨ Create New Quiz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // animated nebula backdrop (simple gradient, optional)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A104B), Color(0xFF0A0F2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _title,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Quiz Title',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.amberAccent)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _category,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.cyanAccent)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        ...List.generate(_questions.length, _questionCard),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Question',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _loading
                      ? const CircularProgressIndicator(
                          color: Colors.amberAccent)
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _saveQuiz,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save Quiz',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// GLASS CARD COMPONENT
/// =====================
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
