import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';
import 'quiz_play_screen.dart' show QuizPlayScreen;
import 'quiz_result_screen.dart' show QuizResultScreen;
// add import for the external profile page
import 'profile_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  late final List<Widget> _pages;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardHomePage(),
      AvailableQuizzesPage(),
      MyResultsPage(),
      StudentProfilePage(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(); // infinite galaxy motion
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Quizzes -> /studentdashboard/quizzes
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/studentdashboard/quizzes');
      return;
    }

    // Results -> /studentdashboard/result (pass demo data as arguments)
    if (index == 2) {
      final demoQuiz = QuizModel(
        id: 'demo_for_nav',
        title: 'Demo Quiz (from nav)',
        category: 'Demo',
        createdBy: 'system',
        questions: [
          QuestionModel(
              id: 'd1',
              question: 'Demo Q1?',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0),
          QuestionModel(
              id: 'd2',
              question: 'Demo Q2?',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1),
        ],
      );
      final answers = <int, int>{};
      for (var i = 0; i < demoQuiz.questions.length; i++)
        answers[i] = demoQuiz.questions[i].correctIndex;

      Navigator.pushReplacementNamed(
        context,
        '/studentdashboard/result',
        arguments: {
          'quiz': demoQuiz,
          'score': demoQuiz.questions.length,
          'total': demoQuiz.questions.length,
          'answers': answers,
        },
      );
      return;
    }

    // Profile -> open profile route (no login required)
    if (index == 3) {
      Navigator.pushNamed(context, '/studentdashboard/profile');
      return;
    }

    // Otherwise just switch the bottom nav tab
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1440),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('🌌 Student Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.amberAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Stack(
        children: [
          /// 🌌 Animated Galaxy Background with Parallax
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GalaxyPainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),

          /// Main content
          IndexedStack(index: _selectedIndex, children: _pages),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF281B62), Color(0xFF432D92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black54, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.quiz_rounded), label: 'Quizzes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment_rounded), label: 'Results'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

/// ============================
/// 🌠 DYNAMIC GALAXY PAINTER
/// ============================
class GalaxyPainter extends CustomPainter {
  final double t;
  final Random rand = Random();
  GalaxyPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Rect rect = Offset.zero & size;

    // 1️⃣ Flowing Nebula Layers
    paint.shader = RadialGradient(
      colors: [Colors.deepPurple.withOpacity(0.25), Colors.transparent],
      radius: 1.2,
      center: Alignment(0.4 * sin(t * 2 * pi), -0.3 * cos(t * 2 * pi)),
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    paint.shader = RadialGradient(
      colors: [Colors.indigo.withOpacity(0.2), Colors.transparent],
      radius: 1.5,
      center: Alignment(-0.5 * cos(t * 2 * pi), 0.4 * sin(t * 2 * pi)),
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    // 2️⃣ Twinkling Stars
    _drawTwinklingStars(canvas, size, 80, 1.5, Colors.white70, t);
    _drawTwinklingStars(canvas, size, 50, 2.0, Colors.cyanAccent, t);
    _drawTwinklingStars(canvas, size, 30, 2.5, Colors.amberAccent, t);

    // 3️⃣ Flowing Particles
    _drawParticles(canvas, size, 40, t);
  }

  void _drawTwinklingStars(Canvas canvas, Size size, int count, double speed,
      Color color, double t) {
    final Paint paint = Paint()..color = color;
    for (int i = 0; i < count; i++) {
      final double x = (i * 53 + t * speed * 400) % size.width;
      final double y =
          (i * 97 + sin(t * pi * speed + i) * 25 + i * 7) % size.height;
      final double radius =
          0.5 + 0.5 * sin(t * 2 * pi * speed + i) + (i % 3) * 0.3;
      paint.color = color.withOpacity(0.5 + 0.5 * sin(t * 2 * pi * speed + i));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawParticles(Canvas canvas, Size size, int count, double t) {
    final Paint paint = Paint()..color = Colors.white24;
    for (int i = 0; i < count; i++) {
      final double x = (i * 73 + t * 200) % size.width;
      final double y = (i * 91 + t * 180) % size.height;
      final double radius = 1 + (i % 2) * 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyPainter oldDelegate) => true;
}

/// ============================
/// HOME PAGE
/// ============================
class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  QuizModel _demoQuiz() {
    return QuizModel(
      id: 'demo1',
      title: 'Space Knowledge Quiz',
      category: 'Astronomy',
      createdBy: 'demo',
      questions: [
        QuestionModel(
          question: 'Which planet is known as the Red Planet?',
          options: ['Mars', 'Earth', 'Venus', 'Jupiter'],
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
    final demoQuiz = _demoQuiz();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.cyanAccent, Colors.purpleAccent],
            ).createShader(bounds),
            child: const Text(
              '👩‍🚀 Welcome, Explorer!',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Test your cosmic knowledge and climb the galaxy leaderboard 🌠',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => QuizPlayScreen(quiz: demoQuiz)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch,
                      color: Colors.purpleAccent, size: 38),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '✨ Try Demo Quiz\nTap to Start Your Journey!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 18)
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: const [
              GlassStatCard(
                  icon: Icons.quiz_rounded,
                  title: 'Quizzes',
                  value: '5',
                  color: Colors.cyanAccent),
              GlassStatCard(
                  icon: Icons.star_rounded,
                  title: 'Avg. Score',
                  value: '82%',
                  color: Colors.orangeAccent),
              GlassStatCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Rank',
                  value: '12',
                  color: Colors.greenAccent),
              GlassStatCard(
                  icon: Icons.timer_rounded,
                  title: 'Time',
                  value: '3h',
                  color: Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class GlassStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const GlassStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                radius: 20,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================
/// QUIZZES PAGE
/// ============================
class AvailableQuizzesPage extends StatelessWidget {
  const AvailableQuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuizModel>>(
      stream: FirestoreService().allQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent));
        }
        final quizzes = snapshot.data ?? [];
        if (quizzes.isEmpty) {
          return const Center(
            child: Text('No quizzes available 🌑',
                style: TextStyle(color: Colors.white70, fontSize: 18)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: quizzes.length,
          itemBuilder: (context, i) {
            final q = quizzes[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                  child: Text('${i + 1}',
                      style: const TextStyle(color: Colors.amberAccent)),
                ),
                title: Text(q.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('${q.questions.length} Questions',
                    style: const TextStyle(color: Colors.white60)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // open QuizResultScreen for demo (replace with real args when available)
                    final answers = <int, int>{};
                    for (var i = 0; i < q.questions.length; i++)
                      answers[i] = q.questions[i].correctIndex;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizResultScreen(
                          score: q.questions.length,
                          total: q.questions.length,
                          quiz: q,
                          answers: answers,
                        ),
                      ),
                    );
                  },
                  child: const Text('Start'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ============================
/// RESULTS PAGE
/// ============================
class MyResultsPage extends StatelessWidget {
  const MyResultsPage({super.key});
  @override
  Widget build(BuildContext context) {
    // demo quiz for result preview
    final demo = QuizModel(
      id: 'demo_result',
      title: 'Demo Result Quiz',
      category: 'Demo',
      createdBy: 'demo',
      questions: [
        QuestionModel(
            question: 'A?', options: ['A', 'B', 'C', 'D'], correctIndex: 0),
        QuestionModel(
            question: 'B?', options: ['A', 'B', 'C', 'D'], correctIndex: 1),
      ],
    );
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.assessment_rounded),
        label: const Text('View Demo Result'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizResultScreen(
                score: 1,
                total: demo.questions.length,
                quiz: demo,
                answers: <int, int>{0: 0, 1: 2},
              ),
            ),
          );
        },
      ),
    );
  }
}
