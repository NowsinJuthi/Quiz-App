// Simple local AuthService for offline/dev mode — no Firebase.

class SimpleUser {
  final String uid;
  final String? email;
  SimpleUser({required this.uid, this.email});
}

class AuthService {
  SimpleUser? _user;

  // mimic FirebaseAuth.currentUser
  SimpleUser? get currentUser => _user;

  // login used by UI
  Future<SimpleUser?> login(
      {required String email, required String password}) async {
    _user = SimpleUser(uid: 'local_${email.hashCode}', email: email);
    return _user;
  }

  // signup used by UI
  Future<SimpleUser?> signup(
      {required String email,
      required String password,
      String? name,
      String? role}) async {
    _user = SimpleUser(uid: 'local_${email.hashCode}', email: email);
    return _user;
  }

  // used by UserProvider
  Future<String> getRole(String uid) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'Student';
  }

  Future<void> logout() async {
    _user = null;
    await Future<void>.value();
  }
}
