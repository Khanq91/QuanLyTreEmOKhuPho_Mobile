import 'package:flutter/material.dart';
import 'package:mobile/screen/auth/quen_mat_khau_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../providers/phu_huynh.dart';
import '../../providers/tinh_nguyen_vien.dart';
import '../other/app_color.dart';
import '../other/app_text.dart';
import '../other/app_dimension.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      if (authProvider.vaiTro == 'Phụ huynh') {
        final phuHuynhProvider =
        Provider.of<PhuHuynhProvider>(context, listen: false);
        await phuHuynhProvider.loadDashboard();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chào mừng ${authProvider.hoTen}!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
            ),
          ),
        );
      } else if (authProvider.vaiTro == 'Tình nguyện viên') {
        final tnvProvider =
        Provider.of<VolunteerProvider>(context, listen: false);
        try {
          await tnvProvider.loadHome();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chào mừng ${authProvider.hoTen}!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
              ),
            ),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thành công nhưng không thể tải dữ liệu: $e'),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
              ),
            ),
          );
        }
      }
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingLG),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOverlay,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.child_care,
                      size: AppDimensions.iconXXL + 16,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXXL),

                  // Title
                  Text(
                    'Quản lý Trẻ em Khu phố',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    'Đăng nhập để tiếp tục',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXXXL),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
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
                        return 'Vui lòng nhập Số điện thoại';
                      }
                      // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      //     .hasMatch(value)) {
                      //   return 'Email không hợp lệ';
                      // }
                      return null;
                    },
                  ),
                  SizedBox(height: AppDimensions.formFieldGap),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: AppColors.primary,
                        size: AppDimensions.iconMD,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: AppDimensions.iconMD,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
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
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppDimensions.spacingXS),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Checkbox(
                          //   value: _rememberMe,
                          //   onChanged: (value) {
                          //     setState(() => _rememberMe = value ?? false);
                          //   },
                          //   activeColor: AppColors.primary,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusXS),
                          //   ),
                          // ),
                          // Text(
                          //   'Ghi nhớ đăng nhập',
                          //   style: AppTextStyles.bodySmall,
                          // ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: const Text('Tính năng đang phát triển'),
                          //     backgroundColor: AppColors.info,
                          //     behavior: SnackBarBehavior.floating,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                          //     ),
                          //   ),
                          // );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: AppDimensions.paddingSymmetric(
                            horizontal: AppDimensions.spacingMD,
                            vertical: AppDimensions.spacingXS,
                          ),
                        ),
                        child: Text(
                          'Quên mật khẩu?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingXL),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
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
                          'Đăng nhập',
                          style: AppTextStyles.button,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppDimensions.spacingXL),

                  // // Divider
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(
                  //         color: AppColors.divider,
                  //         thickness: AppDimensions.dividerThickness,
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: AppDimensions.paddingSymmetric(
                  //         horizontal: AppDimensions.spacingMD,
                  //       ),
                  //       child: Text(
                  //         'hoặc',
                  //         style: AppTextStyles.bodySmall.copyWith(
                  //           color: AppColors.textSecondary,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: AppColors.divider,
                  //         thickness: AppDimensions.dividerThickness,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: AppDimensions.spacingXL),
                  //
                  // // Register Button
                  // OutlinedButton(
                  //   onPressed: () {
                  //     // TODO: Navigate to register screen
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: const Text('Tính năng đăng ký đang phát triển'),
                  //         backgroundColor: AppColors.info,
                  //         behavior: SnackBarBehavior.floating,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   style: OutlinedButton.styleFrom(
                  //     foregroundColor: AppColors.primary,
                  //     side: BorderSide(
                  //       color: AppColors.primary,
                  //       width: AppDimensions.borderMedium,
                  //     ),
                  //     padding: AppDimensions.paddingSymmetric(
                  //       vertical: AppDimensions.buttonPaddingV + 4,
                  //     ),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     'Tạo tài khoản mới',
                  //     style: AppTextStyles.button.copyWith(
                  //       color: AppColors.primary,
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: AppDimensions.spacingXL + AppDimensions.spacingXS),

                  // App Version
                  Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}