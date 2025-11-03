import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _controller;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _TeacherHomePage(),
      _QuizListPage(),
      _ProfilePage(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _handleLogout() async {
    await AuthService().logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text(
          '🌌 Teacher Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GalaxyPainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
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
              icon: Icon(Icons.list_alt_rounded), label: 'Quizzes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

/// ====================
/// GALAXY PAINTER
/// ====================
class GalaxyPainter extends CustomPainter {
  final double t;
  GalaxyPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Rect rect = Offset.zero & size;

    // Purple gradient
    paint.shader = RadialGradient(
      colors: [Colors.purple.withOpacity(0.3), Colors.transparent],
      radius: 1.2,
      center: Alignment(0.3 * sin(t * 2 * pi), -0.4 * cos(t * 2 * pi)),
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Blue gradient
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

/// ====================
/// HOME PAGE
/// ====================
class _TeacherHomePage extends StatelessWidget {
  const _TeacherHomePage();

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Create Quiz',
        'icon': Icons.add_circle_outline,
        'route': '/teacher-create-quiz'
      },
      {
        'title': 'View Quizzes',
        'icon': Icons.list_alt_rounded,
        'route': '/teacher-view-quiz'
      },
      {
        'title': 'Results',
        'icon': Icons.assessment_rounded,
        'route': '/teacher-results'
      },
      {
        'title': 'Profile',
        'icon': Icons.person_rounded,
        'route': '/teacher-profile'
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back, Teacher 👩‍🏫',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Manage quizzes, check student results, and track progress.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Column(
            children: features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, f['route'] as String);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.purpleAccent,
                              Colors.blueAccent
                            ]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(f['icon'] as IconData,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 20),
                        Text(f['title'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// ====================
/// QUIZ LIST PAGE
/// ====================
class _QuizListPage extends StatelessWidget {
  const _QuizListPage();

  @override
  Widget build(BuildContext context) {
    final quizzes = List.generate(
      8,
      (i) => QuizModel(
        id: 'quiz_$i',
        title: 'Quiz #${i + 1}',
        category: 'General',
        createdBy: 'Teacher',
        questions: List.generate(
          5 + i,
          (index) => QuestionModel(
            id: 'quiz_${i}_q_${index}',
            question: 'Sample question ${index + 1} for Quiz ${i + 1}',
            options: ['Option A', 'Option B', 'Option C', 'Option D'],
            correctIndex: 0,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text('Your Quizzes'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${quiz.questions.length} Questions • ${quiz.category}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              color: Colors.cyanAccent),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditQuizScreen(quiz: quiz)));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_rounded,
                              color: Colors.redAccent),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${quiz.title} deleted')),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ====================
/// EDIT QUIZ SCREEN
/// ====================
class EditQuizScreen extends StatefulWidget {
  final QuizModel quiz;
  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz.title);
    _categoryController = TextEditingController(text: widget.quiz.category);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Quiz updated successfully!")),
    );
    Navigator.pop(context);
  }

  void _removeQuiz() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Quiz removed successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amberAccent)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amberAccent)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _removeQuiz,
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// ====================
/// PROFILE PAGE
/// ====================
class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purpleAccent, Colors.blueAccent],
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurpleAccent,
                  child:
                      Icon(Icons.person_rounded, color: Colors.white, size: 70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Teacher Name',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('teacher@example.com',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _ProfileStat(
                    label: 'Quizzes', value: '8', color: Colors.cyanAccent),
                _ProfileStat(
                    label: 'Completed', value: '12', color: Colors.greenAccent),
                _ProfileStat(
                    label: 'Avg. Score',
                    value: '82%',
                    color: Colors.orangeAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ProfileStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

/// ====================
/// GLASS COMPONENT
/// ====================
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
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: _ProfilePage()),
    );
  }
}
