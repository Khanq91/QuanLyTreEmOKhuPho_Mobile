import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/mainscreen/main_screen.dart';
import 'package:mobile/screen/tinhnguyenvien/mainscreen/main_screen.dart';
import '../../providers/auth.dart';
import '../../services/api.dart';
import '../auth/auth.dart';
import '../other/app_color.dart';
import '../other/app_text.dart';
import '../other/app_dimension.dart';

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
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _checkApiAndNavigate();
  }

  Future<void> _checkApiAndNavigate() async {
    setState(() {
      _statusMessage = _retryCount > 0
          ? 'Đang thử lại... (${_retryCount + 1}/$_maxRetries)'
          : 'Đang kiểm tra kết nối...';
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
        _retryCount = 0;
        _navigateToHomeScreen();
      } else {
        final errorType = result['errorType'];

        if (_retryCount < _maxRetries &&
            (errorType == 'TIMEOUT' || errorType == 'NETWORK')) {
          _retryCount++;
          await Future.delayed(Duration(seconds: _retryCount * 2));
          if (mounted) {
            _checkApiAndNavigate();
          }
        } else {
          _showConnectionErrorDialog(result);
        }
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
    print(auth.token);
    print(auth.vaiTro);

    // Đang load thông tin user
    if (auth.token != null && auth.vaiTro == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Đã có đầy đủ thông tin
    if (auth.isAuthenticated && auth.vaiTro != null) {
      // Danh sách vai trò được phép dùng mobile app
      const allowedRoles = ['Phụ huynh', 'Tình nguyện viên'];

      if (!allowedRoles.contains(auth.vaiTro)) {
        // Vai trò không được phép -> Hiển thị màn hình thông báo
        return _buildUnauthorizedRoleScreen(auth);
      }

      // Navigate theo vai trò
      if (auth.vaiTro == 'Phụ huynh') {
        return const ParentMainScreen();
      } else if (auth.vaiTro == 'Tình nguyện viên') {
        return const VolunteerMainScreen();
      }
    }

    // Chưa đăng nhập
    return const LoginScreen();
  }

  Widget _buildUnauthorizedRoleScreen(AuthProvider auth) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon cảnh báo
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
                decoration: BoxDecoration(
                  color: AppColors.warningOverlay,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warning,
                    width: AppDimensions.borderMedium,
                  ),
                ),
                child: Icon(
                  Icons.phone_android_outlined,
                  size: AppDimensions.iconXXL + 16,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXXL),

              // Tiêu đề
              Text(
                'Không hỗ trợ trên Mobile',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Thông báo vai trò
              Container(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: AppDimensions.iconSM,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppDimensions.spacingXS),
                    Text(
                      'Vai trò: ${auth.vaiTro}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacingXL),

              // Mô tả
              Text(
                'Tài khoản của bạn có vai trò "${auth.vaiTro}" chỉ có thể được sử dụng trên hệ thống web.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spacingSM),

              Text(
                'Ứng dụng mobile chỉ hỗ trợ cho:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Danh sách vai trò được hỗ trợ
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
                decoration: BoxDecoration(
                  color: AppColors.infoOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRoleItem(Icons.family_restroom, 'Phụ huynh'),
                    SizedBox(height: AppDimensions.spacingSM),
                    _buildRoleItem(Icons.volunteer_activism, 'Tình nguyện viên'),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacingXXL),

              // Gợi ý
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
                decoration: BoxDecoration(
                  color: AppColors.primaryOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.computer,
                      size: AppDimensions.iconMD,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: Text(
                        'Vui lòng truy cập hệ thống web để sử dụng các tính năng dành cho vai trò của bạn.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacingXXL),

              // Nút đăng xuất
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.logout,
                    size: AppDimensions.iconSM,
                  ),
                  label: Text(
                    'Đăng xuất',
                    style: AppTextStyles.labelLargeConverter,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: AppDimensions.paddingSymmetric(
                      vertical: AppDimensions.spacingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.spacingMD),

              // Nút đăng nhập tài khoản khác
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.person_outline,
                    size: AppDimensions.iconSM,
                  ),
                  label: Text(
                    'Đăng nhập tài khoản khác',
                    style: AppTextStyles.labelLarge,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary,
                      width: AppDimensions.borderMedium,
                    ),
                    padding: AppDimensions.paddingSymmetric(
                      vertical: AppDimensions.spacingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleItem(IconData icon, String roleName) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: AppDimensions.iconSM,
          color: AppColors.success,
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Icon(
          icon,
          size: AppDimensions.iconSM,
          color: AppColors.textPrimary,
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Text(
          roleName,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  void _showConnectionErrorDialog(Map<String, dynamic> result) {
    final errorType = result['errorType'] ?? 'UNKNOWN';

    // Icon và màu dựa trên loại lỗi
    IconData errorIcon;
    Color errorColor;
    String errorTitle;
    List<String> suggestions;

    switch (errorType) {
      case 'TIMEOUT':
        errorIcon = Icons.access_time;
        errorColor = AppColors.warning;
        errorTitle = 'Kết nối chậm';
        suggestions = [
          '• Kết nối mạng của bạn có thể chậm',
          '• Server đang xử lý chậm',
          '• Thử kết nối lại sau vài giây',
        ];
        break;
      case 'NETWORK':
        errorIcon = Icons.signal_wifi_off;
        errorColor = AppColors.error;
        errorTitle = 'Lỗi mạng';
        suggestions = [
          '• Kiểm tra kết nối Wi-Fi hoặc 4G/5G',
          '• Thử bật/tắt chế độ máy bay',
          '• Kiểm tra địa chỉ server trong cấu hình',
        ];
        break;
      case 'SSL':
        errorIcon = Icons.https;
        errorColor = AppColors.error;
        errorTitle = 'Lỗi bảo mật';
        suggestions = [
          '• Kiểm tra cấu hình HTTPS của server',
          '• Certificate có thể không hợp lệ',
          '• Liên hệ admin để kiểm tra',
        ];
        break;
      case 'SERVER_ERROR':
        errorIcon = Icons.storage;
        errorColor = AppColors.error;
        errorTitle = 'Lỗi server';
        suggestions = [
          '• Server đang gặp sự cố',
          '• Liên hệ admin để kiểm tra',
          '• Thử lại sau vài phút',
        ];
        break;
      default:
        errorIcon = Icons.error_outline;
        errorColor = AppColors.error;
        errorTitle = 'Lỗi kết nối';
        suggestions = [
          '• Kiểm tra kết nối internet',
          '• Đảm bảo server đang chạy',
          '• Xem chi tiết lỗi bên dưới',
        ];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background, // ✅ Thêm dòng này
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.dialogRadius),
        ),
        title: Row(
          children: [
            Icon(
              errorIcon,
              color: errorColor,
              size: AppDimensions.iconLG - 4,
            ),
            SizedBox(width: AppDimensions.spacingSM),
            Expanded(
              child: Text(
                errorTitle,
                style: AppTextStyles.headingMedium,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message chính
              Text(
                result['message'],
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Thông tin số lần retry
              if (_retryCount >= _maxRetries) ...[
                SizedBox(height: AppDimensions.spacingSM),
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.warningOverlay,
                    borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusXS),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.replay,
                        size: AppDimensions.iconXS,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                      Expanded(
                        child: Text(
                          'Đã thử $_retryCount lần',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppDimensions.spacingMD),

              // Chi tiết lỗi
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.warningOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                  border: Border.all(
                    color: errorColor.withOpacity(0.2),
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: AppDimensions.iconXS,
                          color: errorColor,
                        ),
                        SizedBox(width: AppDimensions.spacingXXS),
                        Text(
                          'Chi tiết kỹ thuật',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: errorColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingXXS),
                    Text(
                      result['error']?.toString() ?? 'Không xác định',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Gợi ý khắc phục
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.infoOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.2),
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: AppDimensions.iconXS,
                          color: AppColors.info,
                        ),
                        SizedBox(width: AppDimensions.spacingXXS),
                        Text(
                          'Gợi ý khắc phục',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    ...suggestions.map((suggestion) => Padding(
                      padding: AppDimensions.paddingOnly(
                        bottom: AppDimensions.spacingXXS,
                      ),
                      child: Text(
                        suggestion,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _retryCount = 0;
              _checkApiAndNavigate();
            },
            icon: Icon(
              Icons.refresh,
              size: AppDimensions.iconSM,
            ),
            label: Text(
              'Thử lại',
              style: AppTextStyles.labelLarge,
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: AppDimensions.paddingSymmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingXS,
              ),
            ),
          ),
          if (errorType != 'SSL')
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _retryCount = 0;
                _navigateToHomeScreen();
              },
              icon: Icon(
                Icons.arrow_forward,
                size: AppDimensions.iconSM,
              ),
              label: Text(
                'Vẫn tiếp tục',
                style: AppTextStyles.labelLarge,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingXS,
                ),
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
          color: AppColors.primary,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc icon của app
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.child_care,
                  size: AppDimensions.iconXXL + 16,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXXL),

              Text(
                'Quản lý Trẻ em Khu phố',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXXXL),

              // Loading indicator with animation
              SizedBox(
                width: AppDimensions.iconLG + 8,
                height: AppDimensions.iconLG + 8,
                child: _isConnected == false
                    ? Icon(
                  Icons.error_outline,
                  color: AppColors.textOnPrimary,
                  size: AppDimensions.iconLG + 8,
                )
                    : CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary,
                  ),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXL),

              // Status message
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.15),
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusXL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isConnected == true) ...[
                      Icon(
                        Icons.check_circle,
                        color: AppColors.textOnPrimary,
                        size: AppDimensions.iconSM,
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                    ],
                    if (_isConnected == false) ...[
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.textOnPrimary,
                        size: AppDimensions.iconSM,
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                    ],
                    Flexible(
                      child: Text(
                        _statusMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
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