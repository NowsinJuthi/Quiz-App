import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/quiz_model.dart';
import 'add_quiz_screen.dart';

class EditQuizListScreen extends StatelessWidget {
  const EditQuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('My Quizzes')),
      body: StreamBuilder<List<QuizModel>>(
        stream: FirestoreService().teacherQuizzes(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No quizzes yet'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) {
              final q = list[i];
              return ListTile(
                title: Text(q.title),
                subtitle: Text(
                  '${q.questions.length} questions • ${q.category}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // For brevity reuse AddQuizScreen for editing by passing existing data
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddQuizScreen()),
                        ); // You can create dedicated Edit screen
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirestoreService().deleteQuiz(q.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deleted')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
