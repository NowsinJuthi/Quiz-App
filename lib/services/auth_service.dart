<<<<<<< HEAD
class MockUser {
  final String uid;
  final String email;

  MockUser({required this.uid, required this.email});
}

class AuthService {
  // Mock user storage
  static final Map<String, String> _users = {
    'test@example.com': 'password123',
  };

  // Mock user roles storage
  static final Map<String, String> _userRoles = {
    'test@example.com': 'student',
  };

  static MockUser? _currentUser;

  // Mock login
  Future<MockUser?> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    if (_users.containsKey(email) && _users[email] == password) {
      _currentUser = MockUser(uid: 'mock_${email.hashCode}', email: email);
      print('Mock Login Success: $email');
      return _currentUser;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  // Mock signup
  Future<MockUser?> signup({
    required String email,
    required String password,
    String? name,
    String? role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_users.containsKey(email)) {
      throw Exception('User already exists');
    }

    _users[email] = password;
    _userRoles[email] = role ?? 'student';
    _currentUser = MockUser(uid: 'mock_${email.hashCode}', email: email);
    print('Mock Signup Success: $email with role: ${role ?? 'student'}');
    return _currentUser;
  }

  // Get user role
  Future<String> getRole(String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find email by uid
    final email = _currentUser?.email;
    if (email != null && _userRoles.containsKey(email)) {
      return _userRoles[email]!;
    }
    
    return 'student'; // Default role
  }

  // Mock logout
  Future<void> logout() async {
    _currentUser = null;
    print('Mock Logout Success');
  }

  // Get current user
  MockUser? get currentUser => _currentUser;
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred.user;
  }

  Future<User?> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }
>>>>>>> 7258c644030baf4ef8de0d43d5ec1249a9a5a455
}
