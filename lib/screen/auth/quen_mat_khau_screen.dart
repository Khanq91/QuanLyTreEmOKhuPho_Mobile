import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../other/app_color.dart';
import '../other/app_text.dart';
import '../other/app_dimension.dart';
import '../other/splash_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sdtController = TextEditingController();

  bool _isSuccess = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _sdtController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.forgotPassword(
      _sdtController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.successMessage ?? 'Đặt lại mật khẩu thành công!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Đặt lại mật khẩu thất bại'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          ),
          action: SnackBarAction(
            label: 'Đóng',
            textColor: AppColors.textOnPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      authProvider.clearError();
    }
  }

  Future<void> _handleAutoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.loginWithResetPassword();

    if (!mounted) return;

    if (success) {
      // Navigate to SplashScreen để xử lý routing theo vai trò
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SplashScreen(auth: authProvider),
        ),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
          ),
        ),
      );
    }
  }

  void _handleBackToSplash() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearForgotPasswordResult();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SplashScreen(auth: authProvider),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: AppDimensions.iconMD,
          ),
          onPressed: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            authProvider.clearForgotPasswordResult();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Quên mật khẩu',
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (_isSuccess && auth.forgotPasswordResult?.data != null) {
                  return _buildSuccessView(auth);
                }
                return _buildFormView(auth);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            padding: AppDimensions.paddingAll(AppDimensions.spacingLG),
            decoration: BoxDecoration(
              color: AppColors.infoOverlay,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: AppDimensions.iconXXL,
              color: AppColors.info,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXXL),

          // Title
          Text(
            'Đặt lại mật khẩu',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXS),

          // Description
          Text(
            'Nhập số điện thoại đã đăng ký để đặt lại mật khẩu',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXXXL),

          // SĐT Field
          TextFormField(
            controller: _sdtController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleForgotPassword(),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              hintText: 'Nhập số điện thoại của bạn',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
                size: AppDimensions.iconMD,
              ),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
                borderSide: BorderSide(
                  color: AppColors.divider,
                  width: AppDimensions.borderThin,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
                borderSide: BorderSide(
                  color: AppColors.divider,
                  width: AppDimensions.borderThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: AppDimensions.borderThick,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: AppDimensions.borderThin,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.inputRadius),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: AppDimensions.borderThick,
                ),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: AppDimensions.paddingSymmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingMD,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (value.length < 10 || value.length > 11) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          SizedBox(height: AppDimensions.spacingXL),

          // Info Box
          Container(
            padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
            decoration: BoxDecoration(
              color: AppColors.warningOverlay,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: AppDimensions.borderThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppDimensions.iconMD,
                  color: AppColors.warning,
                ),
                SizedBox(width: AppDimensions.spacingMD),
                Expanded(
                  child: Text(
                    'Mật khẩu sẽ được đặt lại về mật khẩu mặc định của hệ thống',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spacingXXL),

          // Submit Button
          ElevatedButton(
            onPressed: auth.isLoading ? null : _handleForgotPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              padding: AppDimensions.paddingSymmetric(
                vertical: AppDimensions.buttonPaddingV + 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
              ),
              elevation: AppDimensions.elevationSM,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: auth.isLoading
                ? SizedBox(
              height: AppDimensions.iconSM,
              width: AppDimensions.iconSM,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            )
                : Text(
              'Đặt lại mật khẩu',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(AuthProvider auth) {
    final data = auth.forgotPasswordResult!.data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Container(
          padding: AppDimensions.paddingAll(AppDimensions.spacingLG),
          decoration: BoxDecoration(
            color: AppColors.successOverlay,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: AppDimensions.iconXXL,
            color: AppColors.success,
          ),
        ),
        SizedBox(height: AppDimensions.spacingXXL),

        // Success Title
        Text(
          'Đặt lại mật khẩu thành công!',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.success,
          ),
        ),
        SizedBox(height: AppDimensions.spacingMD),

        // User Info
        Container(
          padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: AppDimensions.borderThin,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.person_outline, 'Họ tên', data.hoTen),
              Divider(
                height: AppDimensions.spacingMD,
                color: AppColors.divider,
              ),
              _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', data.sdt),
              Divider(
                height: AppDimensions.spacingMD,
                color: AppColors.divider,
              ),
              _buildInfoRow(Icons.badge_outlined, 'Vai trò', data.vaiTro),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacingXL),

        // Password Display
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: AppDimensions.iconSM,
                    color: AppColors.info,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    'Mật khẩu mới',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: AppDimensions.iconSM,
                      color: AppColors.info,
                    ),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: data.matKhauMoi),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Đã copy mật khẩu vào clipboard"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacingSM),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _obscurePassword
                          ? '•' * data.matKhauMoi.length
                          : data.matKhauMoi,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        letterSpacing: _obscurePassword ? 4 : 1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.info,
                      size: AppDimensions.iconMD,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacingMD),

        // Warning
        Container(
          padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
          decoration: BoxDecoration(
            color: AppColors.warningOverlay,
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: AppDimensions.iconSM,
                color: AppColors.warning,
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: Text(
                  'Vui lòng ghi nhớ hoặc đổi mật khẩu sau khi đăng nhập',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacingXXL),

        // Login Button
        ElevatedButton.icon(
          onPressed: auth.isLoading ? null : _handleAutoLogin,
          icon: auth.isLoading
              ? SizedBox(
            height: AppDimensions.iconSM,
            width: AppDimensions.iconSM,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textOnPrimary,
              ),
            ),
          )
              : Icon(
            Icons.login,
            size: AppDimensions.iconSM,
          ),
          label: Text(
            'Đăng nhập',
            style: AppTextStyles.button,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
            padding: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.buttonPaddingV + 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
            ),
            elevation: AppDimensions.elevationSM,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
        ),
        SizedBox(height: AppDimensions.spacingMD),

        // Back Button
        OutlinedButton.icon(
          onPressed: _handleBackToSplash,
          icon: Icon(
            Icons.arrow_back,
            size: AppDimensions.iconSM,
          ),
          label: Text(
            'Trở về',
            style: AppTextStyles.button.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(
              color: AppColors.divider,
              width: AppDimensions.borderMedium,
            ),
            padding: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.buttonPaddingV + 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSM,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: AppDimensions.spacingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXXS),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}