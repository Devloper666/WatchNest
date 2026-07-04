abstract class AuthRepository {
  Stream<String?> authStateChanges();
  Future<void> signInWithEmailAndPassword({required String email, required String password});
  Future<void> registerWithEmailAndPassword({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
  String? get currentUserId;
  String? get currentUserEmail;
}
