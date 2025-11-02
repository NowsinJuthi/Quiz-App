import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of Firebase auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current signed-in user
  User? get currentUser => _auth.currentUser;

  // Sign in
  Future<User?> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // rethrow with readable message
      throw Exception(e.message ?? 'Login failed');
    }
  }

  // Register (now accepts optional role and name)
  Future<User?> register({
    required String email,
    required String password,
    String role = 'student',
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': role,
          'name': name ?? email.split('@')[0],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  // alias used by signup_screen (matches expected params)
  Future<User?> signup({
    required String email,
    required String password,
    String role = 'student',
    String? name,
  }) async {
    return register(email: email, password: password, role: role, name: name);
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // used by UserProvider to load role
  Future<String?> getRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data();
      return data != null ? (data['role'] as String?) : null;
    } catch (_) {
      return null;
    }
  }
}
