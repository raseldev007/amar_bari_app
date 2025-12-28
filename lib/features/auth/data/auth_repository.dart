import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_repository.dart';
import '../../../models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final Ref _ref; // To access UserRepository

  FirebaseAuthRepository(this._auth, this._ref);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  // Code provided by user to stop People API calls absolutely
  Future<void> signInWithGoogle() async {
    // WEB: Use Firebase Auth directly (bypass google_sign_in plugin behavior causing People API 403)
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      // Add explicit params to force simple profile only
      googleProvider.addScope('email');
      googleProvider.addScope('openid');
      googleProvider.addScope('profile');
      
      final userCred = await _auth.signInWithPopup(googleProvider);
      
      final user = userCred.user;
      print("WEB LOGIN OK: ${user?.email} | ${user?.displayName}");
      
      // Save minimal profile as requested
      if (user != null) {
          await _saveUserToFirestore(user);
      }
      return;
    }

    // MOBILE (Android/iOS): Use GoogleSignIn plugin
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user;
    
    // Save minimal profile
    if (user != null) {
        await _saveUserToFirestore(user);
    }
    
    print("MOBILE LOGIN OK: ${user?.email} | ${user?.displayName}");
  }

  Future<void> _saveUserToFirestore(User user) async {
      final userRepo = _ref.read(userRepositoryProvider);
      final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
          createdAt: DateTime.now(),
          role: '', 
          lastSeenAt: DateTime.now(),
      );
      final existingUser = await userRepo.getUser(user.uid);
      if (existingUser == null) {
          await userRepo.createUser(newUser);
      }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance, ref);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
