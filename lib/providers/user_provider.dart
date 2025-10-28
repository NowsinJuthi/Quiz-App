import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  String? uid;
  String? role;
  final AuthService _auth = AuthService();

  Future<void> loadUserRole(String userId) async {
    uid = userId;
    role = await _auth.getRole(uid!);
    notifyListeners();
  }

  void clearUser() {
    uid = null;
    role = null;
    notifyListeners();
  }
}
