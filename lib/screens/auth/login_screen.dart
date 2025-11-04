import 'package:flutter/material.dart';
import '../student/quiz_play_screen.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  QuizModel _demoQuiz() {
    return QuizModel(
      id: 'space_demo',
      title: 'Space Knowledge Quiz',
      category: 'Astronomy',
      createdBy: 'Demo',
      questions: [
        QuestionModel(
          question: 'Which planet is known as the Red Planet?',
          options: ['Mars', 'Venus', 'Earth', 'Jupiter'],
          correctIndex: 0,
        ),
        QuestionModel(
          question: 'How many moons does Earth have?',
          options: ['1', '2', '3', '4'],
          correctIndex: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _demoQuiz();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark background
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            // 🌌 Animated star background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0A0F2C),
                      Color(0xFF1E215D),
                      Color(0xFF442F8A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 40,
              child: _buildGlowingStar(Colors.blueAccent),
            ),
            Positioned(
              bottom: 120,
              right: 60,
              child: _buildGlowingStar(Colors.purpleAccent),
            ),
            Positioned(
              top: 200,
              right: 40,
              child: _buildGlowingStar(Colors.cyanAccent),
            ),

            // 🌠 Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo or Icon
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent,
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.lightBlueAccent,
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.blueAccent],
                      ).createShader(bounds),
                      child: const Text(
                        'Welcome to Galaxy Quiz!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Explore knowledge across the stars 🌟',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Glass-style quiz card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '✨ Demo Space Quiz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Take a quick journey through space knowledge!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // 🚀 Glowing launch button
                          ElevatedButton.icon(
                            icon: const Icon(Icons.rocket_launch, size: 22),
                            label: const Text(
                              'Launch Quiz',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 10,
                              shadowColor: Colors.blueAccent,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      QuizPlayScreen(quiz: quiz),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Footer text
                    const Text(
                      '⚡ Login or Sign Up to unlock your missions!',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingStar(Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.7, end: 1.3),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () => setState(() {}),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.8), blurRadius: 25),
          ],
        ),
      ),
    );
  }
}
