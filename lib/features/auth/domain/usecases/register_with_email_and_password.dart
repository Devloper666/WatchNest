import '../repositories/auth_repository.dart';

class RegisterWithEmailAndPassword {
  const RegisterWithEmailAndPassword(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.registerWithEmailAndPassword(email: email, password: password);
  }
}
