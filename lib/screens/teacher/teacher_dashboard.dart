import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/simple_widgets.dart';
import 'add_quiz_screen.dart';
import 'edit_quiz_list_screen.dart';
import 'view_results_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Quiz'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddQuizScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('View / Edit Quizzes'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditQuizListScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Student Results'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewResultsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
