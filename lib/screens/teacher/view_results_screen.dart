import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // এই লাইনটা যোগ করো
import '../../services/firestore_service.dart';

class ViewResultsScreen extends StatelessWidget {
  const ViewResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Results')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getResultsForTeacher(''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No results yet'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (c, i) {
              final r = items[i];
              final date = r['date'] != null
                  ? (r['date'] as Timestamp).toDate().toString()
                  : '';
              return ListTile(
                title: Text(r['studentEmail'] ?? 'Unknown'),
                subtitle: Text(
                  '${r['quizTitle'] ?? ''} • ${r['score']}/${r['total']}',
                ),
                trailing: Text(date.split('.').first),
              );
            },
          );
        },
      ),
    );
  }
}
