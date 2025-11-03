import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'add_quiz_screen.dart';
import 'edit_quiz_list_screen.dart';
import 'view_results_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHome(),
    AddQuizScreen(),
    ViewResultsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: Colors.purpleAccent),
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _pages[_selectedIndex],
      ),

      // 🌈 Frosted Glass Bottom Navigation Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.dashboard_rounded, "Dashboard", 0),
                  _buildNavItem(
                      Icons.add_circle_outline_rounded, "Add Quiz", 1),
                  _buildNavItem(Icons.insights_rounded, "Results", 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.purpleAccent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.15 : 1.0,
              child: Icon(
                icon,
                color: isActive ? Colors.purpleAccent : Colors.white70,
                size: isActive ? 30 : 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.purpleAccent : Colors.white60,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✨ Soft Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF232344),
                Color(0xFF0F0F1A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // 🌫️ Subtle Glass Effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.white.withOpacity(0.03)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth < 1000) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 4;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back 👋',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your quizzes and students effortlessly.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 📊 Stats Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        _StatsCard(
                          title: 'Total Quizzes',
                          value: '12',
                          icon: Icons.assignment,
                          gradient: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                        ),
                        SizedBox(width: 16),
                        _StatsCard(
                          title: 'Students',
                          value: '87',
                          icon: Icons.people,
                          gradient: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                        SizedBox(width: 16),
                        _StatsCard(
                          title: 'Avg. Score',
                          value: '76%',
                          icon: Icons.show_chart,
                          gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🧩 Feature Cards Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 1.05,
                      children: const [
                        _DashboardCard(
                          title: 'Add Quiz',
                          icon: Icons.add_circle_outline,
                          gradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        ),
                        _DashboardCard(
                          title: 'Edit Quizzes',
                          icon: Icons.edit_note_rounded,
                          gradient: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        ),
                        _DashboardCard(
                          title: 'View Results',
                          icon: Icons.insights_rounded,
                          gradient: [Color(0xFFFF512F), Color(0xFFF09819)],
                        ),
                        _DashboardCard(
                          title: 'Profile Settings',
                          icon: Icons.settings_rounded,
                          gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 180,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(_hover ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.last.withOpacity(0.4),
              blurRadius: _hover ? 25 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 55, color: Colors.white),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
