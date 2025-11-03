import 'dart:math';
import 'dart:ui';
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

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  Map<int, int> answers = {};
  int score = 0;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    const accent = Colors.purpleAccent;
    const bg = Color(0xFF0A0F2C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: accent,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GalaxyPainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / widget.quiz.questions.length,
                    color: accent,
                    backgroundColor: Colors.white12,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 20),

                // Question Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Q${_index + 1}. ${q.question}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: q.options.length,
                    itemBuilder: (context, i) {
                      final selected = answers[_index] == i;
                      return GestureDetector(
                        onTap: () => setState(() => answers[_index] = i),
                        child: GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: selected
                              ? accent.withOpacity(0.2)
                              : Colors.white10,
                          border: Border.all(
                              color: selected ? accent : Colors.transparent,
                              width: 1.5),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected ? accent : Colors.white70,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  q.options[i],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Buttons
                Row(
                  children: [
                    if (_index > 0)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _index--),
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌌 GLASS CARD
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Border? border;

  const GlassCard(
      {super.key,
      required this.child,
      this.padding,
      this.margin,
      this.color,
      this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: border ?? Border.all(color: Colors.white24),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 🌌 GALAXY PAINTER
class GalaxyPainter extends CustomPainter {
  final double t;
  final Random rand = Random();
  GalaxyPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Rect rect = Offset.zero & size;

    paint.shader = RadialGradient(
      colors: [Colors.purple.withOpacity(0.3), Colors.transparent],
      radius: 1.2,
      center: Alignment(0.3 * sin(t * 2 * pi), -0.4 * cos(t * 2 * pi)),
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    paint.shader = RadialGradient(
      colors: [Colors.blueAccent.withOpacity(0.25), Colors.transparent],
      radius: 1.5,
      center: Alignment(-0.4 * cos(t * 2 * pi), 0.2 * sin(t * 2 * pi)),
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    _drawStars(canvas, size, 60, 1.0, Colors.white70, 0.8);
    _drawStars(canvas, size, 40, 1.5, Colors.cyanAccent, 1.2);
    _drawStars(canvas, size, 25, 2.0, Colors.amberAccent, 1.5);

    if ((t * 100).toInt() % 30 == 0) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height / 2;
      final end = Offset(dx - 60, dy + 40);
      final start = Offset(dx, dy);
      final shootPaint = Paint()
        ..shader = LinearGradient(colors: [Colors.white, Colors.transparent])
            .createShader(Rect.fromPoints(start, end))
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, shootPaint);
    }
  }

  void _drawStars(Canvas canvas, Size size, int count, double speed,
      Color color, double scale) {
    final Paint paint = Paint()..color = color.withOpacity(0.7);
    for (int i = 0; i < count; i++) {
      final double x = (i * 37 + t * speed * 500) % size.width;
      final double y =
          (i * 97 + sin(t * pi * speed + i) * 20 + i * 5) % size.height;
      final double radius = 0.8 + (i % 3) * 0.6 * scale;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyPainter oldDelegate) => true;
}
