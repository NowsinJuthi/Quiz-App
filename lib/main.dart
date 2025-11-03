import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/root_page.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/teacher/view_results_screen.dart';
import 'screens/teacher/add_quiz_screen.dart';
import 'screens/teacher/edit_quiz_list_screen.dart';
import 'screens/student/quiz_play_screen.dart';
import 'screens/student/quiz_result_screen.dart';
import 'models/quiz_model.dart';
import 'models/question_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Galaxy Quiz App',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurpleAccent,
          scaffoldBackgroundColor: const Color(0xFF0A0F2C),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const NavbarScaffold(child: HomePage(), routeName: '/'),
        routes: {
          '/login': (context) =>
              const NavbarScaffold(child: LoginScreen(), routeName: '/login'),
          '/signup': (context) =>
              const NavbarScaffold(child: SignupScreen(), routeName: '/signup'),
          '/student-dashboard': (context) => const NavbarScaffold(
              child: StudentDashboard(), routeName: '/student-dashboard'),
          '/teacher-dashboard': (context) => const NavbarScaffold(
              child: TeacherDashboard(), routeName: '/teacher-dashboard'),
          '/teacher/add-quiz': (context) => const NavbarScaffold(
              child: AddQuizScreen(), routeName: '/teacher/add-quiz'),
          '/teacher/edit-quizzes': (context) => const NavbarScaffold(
              child: EditQuizListScreen(), routeName: '/teacher/edit-quizzes'),
          '/teacher/view-results': (context) => const NavbarScaffold(
              child: ViewResultsScreen(), routeName: '/teacher/view-results'),
        },
      ),
    );
  }
}

/// 🌌 Navbar wrapper for all pages
class NavbarScaffold extends StatelessWidget {
  final Widget child;
  final String routeName;
  const NavbarScaffold({super.key, required this.child, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: TopNavbar(activeRoute: routeName),
      ),
      body: child,
    );
  }
}

/// 🌠 Galaxy Navbar
class TopNavbar extends StatelessWidget {
  final String activeRoute;
  const TopNavbar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 750;

    return Container(
      height: 65,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF281B62), Color(0xFF432D92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 26),
              SizedBox(width: 8),
              Text(
                'Galaxy Quiz 🌠',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isWide)
            Row(
              children: [
                _NavButton(label: 'Home', route: '/', activeRoute: activeRoute),
                _NavButton(label: 'Login', route: '/login', activeRoute: activeRoute),
                _NavButton(label: 'Signup', route: '/signup', activeRoute: activeRoute),
                const SizedBox(width: 15),
                _DropdownMenu(
                  label: 'Student',
                  icon: Icons.school,
                  items: [
                    {'label': 'Dashboard', 'route': '/student-dashboard'},
                  ],
                  activeRoute: activeRoute,
                ),
                const SizedBox(width: 8),
                _DropdownMenu(
                  label: 'Teacher',
                  icon: Icons.person,
                  items: [
                    {'label': 'Dashboard', 'route': '/teacher-dashboard'},
                    {'label': 'Add Quiz', 'route': '/teacher/add-quiz'},
                    {'label': 'Edit Quizzes', 'route': '/teacher/edit-quizzes'},
                    {'label': 'View Results', 'route': '/teacher/view-results'},
                  ],
                  activeRoute: activeRoute,
                ),
              ],
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white),
              onSelected: (route) => Navigator.pushNamed(context, route),
              itemBuilder: (context) => [
                const PopupMenuItem(value: '/', child: Text('Home')),
                const PopupMenuItem(value: '/login', child: Text('Login')),
                const PopupMenuItem(value: '/signup', child: Text('Signup')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: '/student-dashboard', child: Text('Student Dashboard')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: '/teacher-dashboard', child: Text('Teacher Dashboard')),
              ],
            ),
        ],
      ),
    );
  }
}

/// ✨ Nav Button (with glow for active)
class _NavButton extends StatelessWidget {
  final String label;
  final String route;
  final String activeRoute;

  const _NavButton({
    required this.label,
    required this.route,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = route == activeRoute;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushNamed(context, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.deepPurpleAccent.withOpacity(0.4) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.amberAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🪐 Dropdown Menu for Student/Teacher
class _DropdownMenu extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Map<String, String>> items;
  final String activeRoute;

  const _DropdownMenu({
    required this.label,
    required this.icon,
    required this.items,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = items.any((item) => item['route'] == activeRoute);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: PopupMenuButton<String>(
        color: const Color(0xFF2E237A),
        offset: const Offset(0, 45),
        tooltip: label,
        onSelected: (route) => Navigator.pushNamed(context, route),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.amberAccent : Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.amberAccent : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
        itemBuilder: (context) => items
            .map(
              (item) => PopupMenuItem<String>(
                value: item['route'],
                child: Text(
                  item['label'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 🪄 Home Page (Galaxy Adventure for Kids)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    final quiz = _demoQuiz();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F2C), Color(0xFF1E215D), Color(0xFF442F8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/stars_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.purpleAccent],
                ).createShader(bounds),
                child: const Text(
                  '🚀 Welcome to Space Quiz!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Explore the galaxy of knowledge 🌌',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '✨ Try the Demo Quiz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Start your space adventure by answering fun quiz questions!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch, color: Colors.white),
                      label: const Text('Launch Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.purpleAccent,
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NavbarScaffold(
                              child: QuizPlayScreen(quiz: quiz),
                              routeName: '/student/quiz-play',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '⚠️ Please login to unlock more missions!',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
