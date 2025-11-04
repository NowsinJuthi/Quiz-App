import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authService = AuthService();
    final currentUser = authService.currentUser;

    // safe provider extraction (compatible with different provider implementations)
    String? providerEmail;
    String? providerRole;
    try {
      providerEmail = (userProvider as dynamic).email as String?;
    } catch (_) {}
    try {
      providerRole = (userProvider as dynamic).role as String?;
    } catch (_) {}

    final email = currentUser?.email ?? providerEmail ?? 'Guest User';
    final role = providerRole ?? 'Student';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 70),
            ),
            const SizedBox(height: 18),
            Text(
              email,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(role),
              backgroundColor: Colors.purpleAccent.withOpacity(0.18),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Stats card (keeps glass style consistent)
            const GlassProfileStats(),

            const SizedBox(height: 24),

            // If logged in show logout, otherwise a note
            if (currentUser != null)
              ElevatedButton.icon(
                onPressed: () async {
                  await authService.logout();
                  if (!context.mounted) return;
                  try {
                    Provider.of<UserProvider>(context, listen: false)
                        .clearUser();
                  } catch (_) {}
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              )
            else
              const Text('You are not logged in.',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class GlassProfileStats extends StatelessWidget {
  const GlassProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.quiz_rounded, color: Colors.cyanAccent),
                title: Text('Quizzes Taken',
                    style: TextStyle(color: Colors.white)),
                trailing: Text('—',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 16)),
              ),
              Divider(color: Colors.white24, height: 0),
              ListTile(
                leading: Icon(Icons.emoji_events_rounded,
                    color: Colors.orangeAccent),
                title:
                    Text('Total Score', style: TextStyle(color: Colors.white)),
                trailing: Text('—',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 16)),
              ),
              Divider(color: Colors.white24, height: 0),
              ListTile(
                leading: Icon(Icons.timer_rounded, color: Colors.purpleAccent),
                title:
                    Text('Study Time', style: TextStyle(color: Colors.white)),
                trailing: Text('—',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
