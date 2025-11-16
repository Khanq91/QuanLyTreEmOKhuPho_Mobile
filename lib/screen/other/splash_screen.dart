import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/mainscreen/main_screen.dart';
import 'package:mobile/screen/tinhnguyenvien/mainscreen/main_screen.dart';
import '../../providers/auth.dart';
import '../../services/api.dart';
import '../auth/auth.dart';

class SplashScreen extends StatefulWidget {
  final AuthProvider auth;

  const SplashScreen({Key? key, required this.auth}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _apiService = ApiService();
  String _statusMessage = 'Đang kiểm tra kết nối...';
  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    _checkApiAndNavigate();
  }

  Future<void> _checkApiAndNavigate() async {
    setState(() {
      _statusMessage = 'Đang kiểm tra kết nối...';
      _isConnected = null;
    });

    // Kiểm tra kết nối API
    final result = await _apiService.checkApiStatus();

    setState(() {
      _isConnected = result['connected'];
      _statusMessage = result['message'];
    });

    // Đợi 1 giây để user đọc message
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (_isConnected == true) {
        // Kết nối thành công, chuyển sang màn hình phù hợp
        _navigateToHomeScreen();
      } else {
        // Kết nối thất bại, hiển thị dialog
        _showConnectionErrorDialog(result);
      }
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _buildHomeScreen(widget.auth),
      ),
    );
  }

  Widget _buildHomeScreen(AuthProvider auth) {
    // Show loading while checking authentication
    // if (auth.token != null && auth.vaiTro == null) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    // Navigate based on authentication and role
    if (auth.isAuthenticated && auth.vaiTro != null) {
      if (auth.vaiTro == 'Phụ huynh') {
        return const ParentMainScreen();
      } else if (auth.vaiTro == 'Tình nguyện viên') {
        return const VolunteerMainScreen();
      }
    }

    return const LoginScreen();
  }

  void _showConnectionErrorDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Lỗi kết nối',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result['message'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết lỗi:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['error']?.toString() ?? 'Không xác định',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng kiểm tra:\n'
                  '• Kết nối internet\n'
                  '• Server đang chạy\n'
                  '• Địa chỉ IP trong ApiService',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _checkApiAndNavigate();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToHomeScreen();
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Tiếp tục'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[400]!,
              Colors.blue[700]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc icon của app
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.child_care,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Quản lý Trẻ em Khu phố',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),

              // Status message
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isConnected == true)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    if (_isConnected == true)
                      const SizedBox(width: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
