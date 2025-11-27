import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth.dart';
import '../models/login_response.dart';
import 'api.dart';

class AuthService extends ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyVaiTro = 'vai_tro';
  static const String _keyHoTen = 'ho_ten';
  static const String _keyUserId = 'user_id';
  static const String _keyRememberMe = 'remember_me';

  Future<LoginResponse> login(String sdt, String password, {bool rememberMe = false}) async {
    final loginResponse = await Post(
      '/mobile/Auth/login',
      {'SDT': sdt, 'MatKhau': password},
          (response) => LoginResponse.fromJson(response),
    );

    await _saveUserData(loginResponse, rememberMe: rememberMe);

    print('Saved Token: ${loginResponse.token}');
    print('Saved vaiTro: ${loginResponse.vaiTro}');
    print('Saved hoTen: ${loginResponse.hoTen}');
    print('Saved userId: ${loginResponse.userId}');
    print('Remember Me: $rememberMe');

    return loginResponse;
  }

  Future<void> _saveUserData(LoginResponse loginResponse, {bool rememberMe = false}) async {
    await _storage.write(key: _keyRememberMe, value: rememberMe.toString());

    if (rememberMe) {
      await _storage.write(key: _keyToken, value: loginResponse.token);
      await _storage.write(key: _keyVaiTro, value: loginResponse.vaiTro);
      await _storage.write(key: _keyHoTen, value: loginResponse.hoTen);
      await _storage.write(key: _keyUserId, value: loginResponse.userId.toString());
    } else {
      await _storage.write(key: _keyToken, value: loginResponse.token);
      await _storage.write(key: _keyVaiTro, value: loginResponse.vaiTro);
      await _storage.write(key: _keyHoTen, value: loginResponse.hoTen);
      await _storage.write(key: _keyUserId, value: loginResponse.userId.toString());
      // await _storage.delete(key: _keyToken);
      // await _storage.delete(key: _keyVaiTro);
      // await _storage.delete(key: _keyHoTen);
      // await _storage.delete(key: _keyUserId);
    }
  }

  Future<Map<String, dynamic>?> getSavedUserData() async {
    final rememberMeStr = await _storage.read(key: _keyRememberMe);
    final rememberMe = rememberMeStr == 'true';

    final token = await _storage.read(key: _keyToken);

    if (token == null) return null;

    final vaiTro = await _storage.read(key: _keyVaiTro);
    final hoTen = await _storage.read(key: _keyHoTen);
    final userIdStr = await _storage.read(key: _keyUserId);

    return {
      'token': token,
      'vaiTro': vaiTro,
      'hoTen': hoTen,
      'userId': userIdStr != null ? int.tryParse(userIdStr) : null,
      'rememberMe': rememberMe,
    };
  }

  Future<bool> isRememberMeEnabled() async {
    final rememberMeStr = await _storage.read(key: _keyRememberMe);
    return rememberMeStr == 'true';
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
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyVaiTro);
    await _storage.delete(key: _keyHoTen);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyRememberMe);
    await clearAuthToken();
  }

  Future<ForgotPasswordResponse> forgotPassword(String sdt) async {
    try {
      final response = await Post(
        '/mobile/Auth/QuenMatKhau',
        {'SDT': sdt},
            (response) => ForgotPasswordResponse.fromJson(response),
        timeout: const Duration(seconds: 15),
      );

      return response;
    } catch (e) {
      print('ERROR in forgotPassword service: $e');
      rethrow;
    }
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