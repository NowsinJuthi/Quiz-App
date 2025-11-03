import 'dart:ui';
import 'package:flutter/material.dart';
import '../teacher/teacher_dashboard.dart'; // For GalaxyPainter & GlassCard

class ViewResultsScreen extends StatelessWidget {
  const ViewResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Dummy Data ----
    final dummyResults = [
      {
        'studentEmail': 'student1@email.com',
        'quizTitle': 'General Knowledge',
        'score': 8,
        'total': 10,
        'date': '2025-11-03 10:00 AM'
      },
      {
        'studentEmail': 'student2@email.com',
        'quizTitle': 'Science Quiz',
        'score': 6,
        'total': 8,
        'date': '2025-11-02 05:30 PM'
      },
      {
        'studentEmail': 'student3@email.com',
        'quizTitle': 'History Challenge',
        'score': 4,
        'total': 5,
        'date': '2025-11-01 02:15 PM'
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text(
          '📊 Student Results (Preview)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 20),
            builder: (context, value, _) =>
                CustomPaint(painter: GalaxyPainter(value), size: Size.infinite),
          ),

          // Dummy Results List
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 30),
            itemCount: dummyResults.length,
            itemBuilder: (context, index) {
              final r = dummyResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          color: Colors.cyanAccent, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (r['studentEmail'] as String?) ??
                                  'Unknown Student',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${r['quizTitle']} • ${r['score']}/${r['total']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        (r['date'] as String?) ?? '',
                        style: const TextStyle(
                            color: Colors.amberAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
