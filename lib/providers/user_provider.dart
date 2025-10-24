import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  String? uid;
  String? email;
  String? role;

  final AuthService _auth = AuthService();

  Future<void> loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    uid = user.uid;
    email = user.email;
    role = await _auth.getRole(uid!);
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadUserRole();
  }
}
