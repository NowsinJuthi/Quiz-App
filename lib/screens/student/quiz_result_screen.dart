import 'dart:ui';
import 'dart:math';
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
    const accent = Colors.purpleAccent;
    const bg = Color(0xFF0A0F2C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: accent,
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: GalaxyPainter(0.2),
            size: Size.infinite,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Score Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: Colors.amberAccent, size: 60),
                      const SizedBox(height: 10),
                      const Text('Your Score',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('$score / $total',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                          'Accuracy: ${(score / total * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Question-wise Review
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

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        border: Border.all(
                          color: correctAnswer
                              ? Colors.greenAccent
                              : Colors.redAccent.withOpacity(0.6),
                          width: 1.2,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          title: Text(q.question,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Your answer: $chosenText',
                                  style: TextStyle(
                                      color: correctAnswer
                                          ? Colors.greenAccent
                                          : Colors.redAccent)),
                              Text('Correct answer: $correctText',
                                  style:
                                      const TextStyle(color: Colors.white70)),
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

                // Back Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌌 GLASS CARD (reuse)
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

/// 🌌 GALAXY PAINTER (reuse)
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
