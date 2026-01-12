import 'package:firebase_auth/firebase_auth.dart';

class ReAuthService {
  static Future<void> reAuthenticate(String password) async {
    final user = FirebaseAuth.instance.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
  }

  static Future<void> deleteAccount(String password) async {
    await reAuthenticate(password);
    await FirebaseAuth.instance.currentUser!.delete();
  }
}
