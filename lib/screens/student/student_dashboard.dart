import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/quiz_model.dart';
import 'quiz_play_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      StudentHomePage(),
      AvailableQuizzesPage(),
      MyResultsPage(),
      StudentProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0f172a) : const Color(0xfff9fbff),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Student Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1e293b) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: isDark ? const Color(0xff1e293b) : Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
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
        ),
      ),
    );
  }
}

/// ====================
/// HOME PAGE
/// ====================
class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff4facfe), Color(0xff00f2fe)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back 👋',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Let’s continue learning today!',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text("Your Progress",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.quiz_rounded,
                title: 'Quizzes Taken',
                value: '5',
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                icon: Icons.star_rounded,
                title: 'Avg. Score',
                value: '82%',
                color: Colors.orangeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_rounded,
                title: 'Rank',
                value: '12',
                color: Colors.green,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                icon: Icons.timer_rounded,
                title: 'Study Time',
                value: '3h',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
        ],
      ),
    );
  }
}

/// ====================
/// QUIZZES PAGE
/// ====================
class AvailableQuizzesPage extends StatelessWidget {
  const AvailableQuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<QuizModel>>(
      stream: FirestoreService().allQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        final quizzes = snapshot.data ?? [];
        if (quizzes.isEmpty) {
          return Center(
              child: Text('No quizzes available',
                  style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final q = quizzes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1e293b) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: Text('Q${index + 1}',
                      style: const TextStyle(color: Colors.blueAccent)),
                ),
                title: Text(q.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('${q.questions.length} Questions',
                    style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPlayScreen(quiz: q),
                      ),
                    );
                  },
                  child: const Text('Start',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ====================
/// RESULTS PAGE
/// ====================
class MyResultsPage extends StatelessWidget {
  const MyResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_rounded,
                size: 90, color: isDark ? Colors.white54 : Colors.grey),
            const SizedBox(height: 20),
            Text('No Results Yet',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 10),
            Text('Take a quiz to see your results here',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// ====================
/// PROFILE PAGE
/// ====================
class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person_rounded, size: 70, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(currentUser?.email ?? 'Student',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Chip(
            label: Text(userProvider.role ?? 'student'),
            backgroundColor: isDark
                ? Colors.blueAccent.withOpacity(0.25)
                : Colors.blueAccent.withOpacity(0.15),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            color: isDark ? const Color(0xff1e293b) : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.quiz_rounded, color: Colors.blueAccent),
                  title: Text('Quizzes Taken'),
                  trailing:
                      Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.star_rounded, color: Colors.orange),
                  title: Text('Total Score'),
                  trailing: Text('410',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.timer_rounded, color: Colors.purple),
                  title: Text('Total Time'),
                  trailing: Text('3h 15m',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}