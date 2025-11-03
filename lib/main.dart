import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/quiz_model.dart';
import 'models/question_model.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/teacher/add_quiz_screen.dart';
import 'screens/teacher/edit_quiz_list_screen.dart';
import 'screens/teacher/view_results_screen.dart';
import 'screens/teacher/teacher_dashboard.dart' show TeacherProfilePage;
import 'screens/student/student_dashboard.dart';
import 'screens/student/quizzes_page.dart';
import 'screens/student/quiz_play_screen.dart';
import 'screens/student/quiz_result_screen.dart';
import 'screens/student/profile_page.dart';

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
        title: 'Quiz App',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurpleAccent,
          scaffoldBackgroundColor: const Color(0xFF0A0F2C),
          useMaterial3: true,
        ),
        home: NavbarScaffold(child: const HomePage(), routeName: '/'),
        routes: {
          '/studentdashboard/profile': (context) => NavbarScaffold(
                child: const StudentProfilePage(),
                routeName: '/studentdashboard/profile',
              ),

          // student quizzes: show QuizPlayScreen when a QuizModel arg is provided, otherwise StudentQuizzesPage
          '/studentdashboard/quizzes': (context) => NavbarScaffold(
                routeName: '/studentdashboard/quizzes',
                child: Builder(builder: (ctx) {
                  final args = ModalRoute.of(ctx)!.settings.arguments
                      as Map<String, dynamic>?;
                  final quiz = args?['quiz'] as QuizModel?;
                  if (quiz != null) return QuizPlayScreen(quiz: quiz);
                  return StudentQuizzesPage();
                }),
              ),

          // student result route (reads arguments and shows QuizResultScreen)
          '/studentdashboard/result': (context) => NavbarScaffold(
                routeName: '/studentdashboard/result',
                child: Builder(builder: (ctx) {
                  final args = ModalRoute.of(ctx)!.settings.arguments
                      as Map<String, dynamic>?;
                  final demoQuiz = QuizModel(
                    id: 'demo1',
                    title: 'Demo Result Quiz',
                    category: 'Demo',
                    createdBy: 'system',
                    questions: [
                      QuestionModel(
                          id: 'r1',
                          question: 'Q1?',
                          options: ['A', 'B', 'C', 'D'],
                          correctIndex: 0),
                      QuestionModel(
                          id: 'r2',
                          question: 'Q2?',
                          options: ['A', 'B', 'C', 'D'],
                          correctIndex: 1),
                    ],
                  );
                  final quiz = args?['quiz'] as QuizModel? ?? demoQuiz;
                  final score = args?['score'] as int? ?? 0;
                  final total = args?['total'] as int? ?? quiz.questions.length;
                  final answers =
                      (args?['answers'] as Map?)?.cast<int, int>() ??
                          <int, int>{};
                  return QuizResultScreen(
                      score: score, total: total, quiz: quiz, answers: answers);
                }),
              ),

          // auth / dashboards / teacher pages
          '/login': (context) =>
              NavbarScaffold(child: const LoginScreen(), routeName: '/login'),
          '/signup': (context) =>
              NavbarScaffold(child: const SignupScreen(), routeName: '/signup'),
          '/student-dashboard': (context) => NavbarScaffold(
              child: const StudentDashboard(), routeName: '/student-dashboard'),
          '/teacher-dashboard': (context) => NavbarScaffold(
              child: const TeacherDashboard(), routeName: '/teacher-dashboard'),
          '/teacher-create-quiz': (context) => NavbarScaffold(
                child: AddQuizScreen(),
                routeName: '/teacher-create-quiz',
              ),
          '/teacher-view-quiz': (context) => NavbarScaffold(
                child: EditQuizListScreen(),
                routeName: '/teacher-view-quiz',
              ),
          '/teacher-results': (context) => NavbarScaffold(
                child: ViewResultsScreen(),
                routeName: '/teacher-results',
              ),
          '/teacher-profile': (context) => NavbarScaffold(
                child: TeacherProfilePage(),
                routeName: '/teacher-profile',
              ),
        },
      ),
    );
  }
}

/// Simple Navbar wrapper used by routes (keeps top UI consistent)
class NavbarScaffold extends StatelessWidget {
  final Widget child;
  final String routeName;
  const NavbarScaffold(
      {super.key, required this.child, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: TopNavbar(activeRoute: routeName)),
      body: child,
    );
  }
}

class TopNavbar extends StatelessWidget {
  final String activeRoute;
  const TopNavbar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 750;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF281B62), Color(0xFF432D92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 26),
          const SizedBox(width: 8),
          const Text('Galaxy Quiz',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          if (isWide) ...[
            _NavButton(label: 'Home', route: '/', activeRoute: activeRoute),
            _NavButton(
                label: 'Login', route: '/login', activeRoute: activeRoute),
            _NavButton(
                label: 'Signup', route: '/signup', activeRoute: activeRoute),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              color: const Color(0xFF2E237A),
              offset: const Offset(0, 40),
              onSelected: (route) => Navigator.pushNamed(context, route),
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                    value: '/student-dashboard',
                    child: Text('Student Dashboard',
                        style: TextStyle(color: Colors.white))),
                PopupMenuItem(
                    value: '/teacher-dashboard',
                    child: Text('Teacher Dashboard',
                        style: TextStyle(color: Colors.white))),
              ],
              child: Row(children: const [
                Icon(Icons.person, color: Colors.white),
                SizedBox(width: 6),
                Text('Account', style: TextStyle(color: Colors.white))
              ]),
            ),
          ] else
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white),
              onSelected: (route) => Navigator.pushNamed(context, route),
              itemBuilder: (context) => const [
                PopupMenuItem(value: '/', child: Text('Home')),
                PopupMenuItem(value: '/login', child: Text('Login')),
                PopupMenuItem(value: '/signup', child: Text('Signup')),
                PopupMenuDivider(),
                PopupMenuItem(
                    value: '/student-dashboard',
                    child: Text('Student Dashboard')),
                PopupMenuItem(
                    value: '/teacher-dashboard',
                    child: Text('Teacher Dashboard')),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String route;
  final String activeRoute;
  const _NavButton(
      {required this.label, required this.route, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final isActive = route == activeRoute;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color:
                  isActive ? Colors.deepPurpleAccent.withOpacity(0.35) : null,
              borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: TextStyle(
                  color: isActive ? Colors.amberAccent : Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

/// Home page with Launch Quiz button that routes to /studentdashboard/quizzes with quiz argument
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
            id: 'q1',
            question: 'Which planet is known as the Red Planet?',
            options: ['Mars', 'Earth', 'Venus', 'Jupiter'],
            correctIndex: 0),
        QuestionModel(
            id: 'q2',
            question: 'How many moons does Earth have?',
            options: ['1', '2', '3', '4'],
            correctIndex: 0),
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
            end: Alignment.bottomRight),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 72, color: Colors.amberAccent),
              const SizedBox(height: 12),
              const Text('Galaxy of knowledge 🌌',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('✨ Try the Demo Quiz',
                  style: TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.rocket_launch, color: Colors.white),
                label: const Text('Launch Quiz'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () => Navigator.pushNamed(
                    context, '/studentdashboard/quizzes',
                    arguments: {'quiz': quiz}),
              ),
              const SizedBox(height: 24),
              const Text('⚠️ Please login to unlock more missions!',
                  style: TextStyle(
                      color: Colors.orangeAccent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
