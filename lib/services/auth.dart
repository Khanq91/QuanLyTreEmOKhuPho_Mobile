import '../models/login_response.dart';
import 'api.dart';

class AuthService extends ApiService {
  Future<LoginResponse> login(String sdt, String password) async {
    return Post(
      '/mobile/Auth/login',
      {'SDT': sdt, 'MatKhau': password},
          (response) {
        final loginResponse = LoginResponse.fromJson(response);
        setAuthToken(loginResponse.token);
        print('Saved Token: ${loginResponse.token}');
        return loginResponse;
      },
    );
  }

  Future<bool> register(String email, String password, String hoTen) async {
    return Post(
      '/Auth/register',
      {
        'email': email,
        'matKhau': password,
        'hoTen': hoTen,
        'vaiTro': 'PhuHuynh',
      },
          (response) => response['success'] ?? true,
    );
  }

  Future<void> logout() async {
    await clearAuthToken();
  }

  Future<bool> changePassword(
      String currentPassword,
      String newPassword,
      ) async {
    return Post(
      '/Auth/change-password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
          (response) => response['success'] ?? true,
    );
  }
}