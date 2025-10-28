import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/quiz_model.dart';
import '../student/quiz_play_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QuizModel>>(
        stream: FirestoreService().allQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          if (list.isEmpty)
            return const Center(child: Text('No quizzes found'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) {
              final q = list[i];
              return ListTile(
                title: Text(q.title),
                subtitle: Text('${q.category} • ${q.questions.length} Qs'),
                trailing: ElevatedButton(
                  child: const Text('Start'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizPlayScreen(quiz: q)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
