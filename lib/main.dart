import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/root_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const AuthWrapper(),
      ),
    );
  }
}

// Wrapper to listen auth changes
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges.listen((user) async {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      if (user != null) {
        await userProv.loadUserRole(user.uid);
      } else {
        userProv.clearUser();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    if (userProv.uid == null) return const LoginScreen();
    return const RootPage();
  }
}
