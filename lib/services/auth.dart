import '../data/data_repository.dart';

class AuthService {
  final DataRepository _repository = DataRepository();

  Map<String, dynamic>? login(String email, String password) {
    return _repository.authenticateUser(email, password);
  }

  bool logout() {
    return true;
  }
}