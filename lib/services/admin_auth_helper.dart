import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_options.dart';

class AdminAuthHelper {
  static FirebaseApp? _secondaryApp;
  static FirebaseAuth? _secondaryAuth;

  static Future<FirebaseAuth> _getAuth() async {
    if (_secondaryAuth != null) return _secondaryAuth!;

    _secondaryApp ??= await Firebase.initializeApp(
      name: 'admin-helper',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _secondaryAuth = FirebaseAuth.instanceFor(app: _secondaryApp!);
    return _secondaryAuth!;
  }

  static Future<String> createUser({
    required String email,
    required String password,
  }) async {
    final auth = await _getAuth();
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await auth.signOut();

    return cred.user!.uid;
  }
}
