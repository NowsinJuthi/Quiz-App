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

  // Toggle to allow browsing routes without auth
  static const bool allowBrowsingWithoutAuth = true;

  @override
  Widget build(BuildContext context) {
    // central routes map so RouteExplorer can read them
    final Map<String, WidgetBuilder> appRoutes = {
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignupScreen(),
      '/home': (context) => const RootPage(),
      '/student-dashboard': (context) => const StudentDashboard(),
      '/teacher-dashboard': (context) => const TeacherDashboard(),
      '/teacher/add-quiz': (context) => const AddQuizScreen(),
      '/teacher/edit-quizzes': (context) => const EditQuizListScreen(),
      '/teacher/view-results': (context) => const ViewResultsScreen(),
      // student quiz play/result use args; builder shows helpful fallback
      '/student/quiz-play': (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map && args['quiz'] is QuizModel) {
          return QuizPlayScreen(quiz: args['quiz'] as QuizModel);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Quiz Play')),
          body: const Center(
              child: Text('This route requires a "quiz" argument')),
        );
      },
      '/student/quiz-result': (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map && args['quiz'] is QuizModel) {
          final quiz = args['quiz'] as QuizModel;
          final score = args['score'] as int? ?? 0;
          final total = args['total'] as int? ?? (quiz.questions.length);
          final answers = args['answers'] as Map<int, int>? ?? <int, int>{};
          return QuizResultScreen(
              score: score, total: total, quiz: quiz, answers: answers);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Quiz Result')),
          body: const Center(
              child:
                  Text('This route requires arguments (quiz, score, total)')),
        );
      },
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quiz App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: allowBrowsingWithoutAuth
            ? RouteExplorer(routes: appRoutes)
            : const AuthWrapper(),
        routes: appRoutes,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    Text('Route not found: ${settings.name}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Wrapper to listen auth changes and load user role (kept for normal flow)
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _auth = AuthService();
  late final Stream _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = _auth.authStateChanges;
    _authStream.listen((user) async {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      if (user != null) {
        await userProv.loadUserRole(user.uid);
      } else {
        userProv.clearUser();
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    if (userProv.uid == null) return const LoginScreen();
    return const RootPage();
  }
}

// Simple route explorer UI to browse named routes (useful for web/dev)
class RouteExplorer extends StatelessWidget {
  final Map<String, WidgetBuilder> routes;
  const RouteExplorer({super.key, required this.routes});

  QuizModel _demoQuiz() {
    return QuizModel(
      id: 'demo1',
      title: 'Demo Quiz',
      category: 'General',
      createdBy: 'demo',
      questions: [
        QuestionModel(
          question: 'Capital of France?',
          options: ['Paris', 'London', 'Rome', 'Madrid'],
          correctIndex: 0,
        ),
        QuestionModel(
          question: '2 + 2 = ?',
          options: ['3', '4', '5', '6'],
          correctIndex: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeNames = routes.keys.toList();
    final demo = _demoQuiz();

    return Scaffold(
      appBar: AppBar(title: const Text('Route Explorer (no login)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: routeNames.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (c, i) {
            final name = routeNames[i];
            final requiresArgs =
                name == '/student/quiz-play' || name == '/student/quiz-result';
            return ListTile(
              title: Text(name),
              subtitle: requiresArgs
                  ? const Text('Route expects arguments — use Demo')
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await Navigator.pushNamed(context, name);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cannot navigate without args')),
                        );
                      }
                    },
                    child: const Text('Open'),
                  ),
                  const SizedBox(width: 8),
                  if (requiresArgs)
                    ElevatedButton(
                      onPressed: () async {
                        if (name == '/student/quiz-play') {
                          await Navigator.pushNamed(context, name,
                              arguments: {'quiz': demo});
                        } else if (name == '/student/quiz-result') {
                          await Navigator.pushNamed(context, name, arguments: {
                            'quiz': demo,
                            'score': 1,
                            'total': demo.questions.length,
                            'answers': <int, int>{0: 0, 1: 1},
                          });
                        }
                      },
                      child: const Text('Open Demo'),
                    ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open $name or Open Demo')));
              },
            );
          },
        ),
      ),
    );
  }
}

