import 'package:flutter/foundation.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/register_with_email_and_password.dart';
import '../domain/usecases/send_password_reset_email.dart';
import '../domain/usecases/sign_in_with_email_and_password.dart';
import '../domain/usecases/sign_in_with_google.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required SignInWithEmailAndPassword signInWithEmailAndPassword,
    required RegisterWithEmailAndPassword registerWithEmailAndPassword,
    required SignInWithGoogle signInWithGoogle,
    required SendPasswordResetEmail sendPasswordResetEmail,
  })  : _repository = repository,
        _signInWithEmailAndPassword = signInWithEmailAndPassword,
        _registerWithEmailAndPassword = registerWithEmailAndPassword,
        _signInWithGoogle = signInWithGoogle,
        _sendPasswordResetEmail = sendPasswordResetEmail {
    _subscription = repository.authStateChanges().listen((userId) {
      _userId = userId;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  final SignInWithEmailAndPassword _signInWithEmailAndPassword;
  final RegisterWithEmailAndPassword _registerWithEmailAndPassword;
  final SignInWithGoogle _signInWithGoogle;
  final SendPasswordResetEmail _sendPasswordResetEmail;

  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasCompletedReset = false;
  late final StreamSubscription<dynamic> _subscription;

  String? get userId => _userId;
  bool get isAuthenticated => _userId != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCompletedReset => _hasCompletedReset;
  String? get currentUserEmail => _repository.currentUserEmail;

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _signInWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      _errorMessage = _messageFromError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailAndPassword({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registerWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      _errorMessage = _messageFromError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _signInWithGoogle();
    } catch (error) {
      _errorMessage = _messageFromError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    _hasCompletedReset = false;
    notifyListeners();

    try {
      await _sendPasswordResetEmail(email: email);
      _hasCompletedReset = true;
    } catch (error) {
      _errorMessage = _messageFromError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.signOut();
      _userId = null;
    } catch (error) {
      _errorMessage = _messageFromError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String _messageFromError(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? 'Authentication failed.';
    }
    return 'Authentication failed.';
  }
}
