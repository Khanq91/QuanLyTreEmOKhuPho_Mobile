import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/auth.dart';
import '../services/auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? _hoTen;
  String? _vaiTro;
  int? _userId;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  String? _successMessage;
  ForgotPasswordResponse? _forgotPasswordResult;

  String? get token => _token;
  String? get hoTen => _hoTen;
  String? get vaiTro => _vaiTro;
  int? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;
  bool get rememberMe => _rememberMe;

  String? get successMessage => _successMessage;
  ForgotPasswordResponse? get forgotPasswordResult => _forgotPasswordResult;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.getSavedUserData();

      if (userData != null) {
        _token = userData['token'];
        _vaiTro = userData['vaiTro'];
        _hoTen = userData['hoTen'];
        _userId = userData['userId'];
        _rememberMe = userData['rememberMe'] ?? false;

        print('SUCCESS: Restored user data:');
        print('   Token: $_token');
        print('   VaiTro: $_vaiTro');
        print('   HoTen: $_hoTen');
        print('   UserId: $_userId');
        print('   RememberMe: $_rememberMe');

        // TODO: Tùy chọn - Validate token với server
        // await _validateToken();
      } else {
        print('INFO: No saved user data found');
      }
    } catch (e) {
      print('ERROR: Error loading user data: $e');
      clearAuth();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _validateToken() async {
    try {
      // Gọi API để kiểm tra token còn hợp lệ không
      // Nếu không hợp lệ thì clearAuth()
      // await _authService.validateToken();
    } catch (e) {
      print('Token validation failed: $e');
      clearAuth();
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password, rememberMe: rememberMe);
      _token = response.token;
      _hoTen = response.hoTen;
      _vaiTro = response.vaiTro;
      _userId = response.userId;
      _rememberMe = rememberMe;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String hoTen) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(email, password, hoTen);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      clearAuth();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> forgotPassword(String sdt) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _forgotPasswordResult = null;
    notifyListeners();

    try {
      final result = await _authService.forgotPassword(sdt);

      _forgotPasswordResult = result;

      if (result.success) {
        _successMessage = result.message;
      } else {
        _errorMessage = result.message;
      }

      _isLoading = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng nhập tự động sau khi reset password
  Future<bool> loginWithResetPassword() async {
    if (_forgotPasswordResult?.data == null) {
      _errorMessage = 'Không có thông tin đăng nhập';
      notifyListeners();
      return false;
    }

    final sdt = _forgotPasswordResult!.data!.sdt;
    final matKhau = _forgotPasswordResult!.data!.matKhauMoi;

    return await login(sdt, matKhau, rememberMe: false);
  }

  void clearError() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearForgotPasswordResult() {
    _forgotPasswordResult = null;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearAuth() {
    _token = null;
    _userId = null;
    _hoTen = null;
    _vaiTro = null;
    _rememberMe = false;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _forgotPasswordResult = null;
    notifyListeners();
  }
}