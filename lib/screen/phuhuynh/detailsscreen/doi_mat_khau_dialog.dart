import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../providers/phu_huynh.dart';

class DoiMatKhauDialog extends StatefulWidget {
  const DoiMatKhauDialog({Key? key}) : super(key: key);

  @override
  State<DoiMatKhauDialog> createState() => _DoiMatKhauDialogState();
}

class _DoiMatKhauDialogState extends State<DoiMatKhauDialog> {
  final _formKey = GlobalKey<FormState>();
  final _matKhauCuController = TextEditingController();
  final _matKhauMoiController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _matKhauCuController.dispose();
    _matKhauMoiController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.radiusCircular(AppDimensions.dialogRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với icon
                  Row(
                    children: [
                      Container(
                        padding: AppDimensions.paddingAll(
                          AppDimensions.spacingSM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_reset,
                          color: AppColors.primary,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Text(
                          'Đổi mật khẩu',
                          style: AppTextStyles.headingMedium,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.spacingXL),

                  // Mật khẩu cũ
                  _buildPasswordField(
                    controller: _matKhauCuController,
                    label: 'Mật khẩu cũ',
                    icon: Icons.lock_outline,
                    obscureText: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu cũ';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppDimensions.spacingMD),

                  // Mật khẩu mới
                  _buildPasswordField(
                    controller: _matKhauMoiController,
                    label: 'Mật khẩu mới',
                    icon: Icons.lock,
                    obscureText: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppDimensions.spacingMD),

                  // Xác nhận mật khẩu
                  _buildPasswordField(
                    controller: _xacNhanMatKhauController,
                    label: 'Xác nhận mật khẩu mới',
                    icon: Icons.lock_clock,
                    obscureText: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _matKhauMoiController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppDimensions.spacingXL),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(
                              color: AppColors.divider,
                              width: AppDimensions.borderThin,
                            ),
                            padding: AppDimensions.paddingSymmetric(
                              vertical: AppDimensions.spacingSM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.radiusCircular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _doiMatKhau,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: AppDimensions.paddingSymmetric(
                              vertical: AppDimensions.spacingSM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.radiusCircular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                            elevation: AppDimensions.elevationSM,
                          ),
                          child: Text(
                            'Đổi mật khẩu',
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PASSWORD FIELD
  // ==========================================================================
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconSM,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
            size: AppDimensions.iconSM,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.inputRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.inputRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.inputRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.inputRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.inputRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThick,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppDimensions.paddingSymmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingSM,
        ),
      ),
      validator: validator,
    );
  }

  // ==========================================================================
  // ĐỔI MẬT KHẨU
  // ==========================================================================
  Future<void> _doiMatKhau() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );

    try {
      await context.read<PhuHuynhProvider>().doiMatKhau(
        _matKhauCuController.text,
        _matKhauMoiController.text,
      );

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đổi mật khẩu thành công'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(
              AppDimensions.radiusSM,
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(
              AppDimensions.dialogRadius,
            ),
          ),
          child: Padding(
            padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.errorOverlay,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: AppDimensions.iconXL,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingMD),

                // Title
                Text(
                  'Lỗi',
                  style: AppTextStyles.headingMedium,
                ),
                SizedBox(height: AppDimensions.spacingXS),

                // Message
                Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacingXL),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(
                            color: AppColors.divider,
                            width: AppDimensions.borderThin,
                          ),
                          padding: AppDimensions.paddingSymmetric(
                            vertical: AppDimensions.spacingSM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.radiusCircular(
                              AppDimensions.buttonRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          'Đóng',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _doiMatKhau(); // Retry
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: AppDimensions.paddingSymmetric(
                            vertical: AppDimensions.spacingSM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.radiusCircular(
                              AppDimensions.buttonRadius,
                            ),
                          ),
                          elevation: AppDimensions.elevationSM,
                        ),
                        child: Text(
                          'Thử lại',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}