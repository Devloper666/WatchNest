import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  Stream<String?> authStateChanges() => _dataSource.authStateChanges();

  @override
  Future<void> signInWithEmailAndPassword({required String email, required String password}) {
    return _dataSource.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> registerWithEmailAndPassword({required String email, required String password}) {
    return _dataSource.registerWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _dataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  String? get currentUserId => _dataSource.currentUserId;

  @override
  String? get currentUserEmail => _dataSource.currentUserEmail;
}
