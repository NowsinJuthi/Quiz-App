import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'auth/login_screen.dart';
import 'student/student_dashboard.dart';
import 'teacher/teacher_dashboard.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    if (userProv.uid == null) return const LoginScreen();
    if (userProv.role == 'teacher') return const TeacherDashboard();
    return const StudentDashboard();
  }
}
