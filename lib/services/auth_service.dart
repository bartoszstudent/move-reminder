import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});
}

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Hasło jest za słabe. Użyj co najmniej 6 znaków.';
        case 'email-already-in-use':
          return 'Ten email jest już zarejestrowany.';
        case 'invalid-email':
          return 'Adres email jest nieprawidłowy.';
        case 'user-not-found':
          return 'Użytkownik nie znaleziony.';
        case 'wrong-password':
          return 'Hasło jest nieprawidłowe.';
        case 'too-many-requests':
          return 'Zbyt wiele prób logowania. Spróbuj później.';
        case 'operation-not-allowed':
          return 'Rejestracja nie jest dostępna. Skontaktuj się z administratorem.';
        case 'network-request-failed':
          return 'Błąd połączenia. Sprawdź swoje połączenie internetowe.';
        default:
          return 'Błąd: ${error.code} - ${error.message ?? "Nieznany błąd"}';
      }
    }
    return 'Nieznany błąd. Spróbuj ponownie. Szczegóły: $error';
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult(errorMessage: 'Nie udało się utworzyć użytkownika.');
      }

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return AuthResult(user: userModel);
    } catch (e) {
      return AuthResult(errorMessage: _getErrorMessage(e));
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult(errorMessage: 'Nie udało się zalogować.');
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.data()!, user.uid);
        return AuthResult(user: userModel);
      }
      return AuthResult(errorMessage: 'Profil użytkownika nie znaleziony.');
    } catch (e) {
      return AuthResult(errorMessage: _getErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    }
    return null;
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> updateUserPreferences({
    required String uid,
    required int dailyActivityGoal,
    required int inactivityThreshold,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'dailyActivityGoal': dailyActivityGoal,
      'inactivityThreshold': inactivityThreshold,
    });
  }
}
