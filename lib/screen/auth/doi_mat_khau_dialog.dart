import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../other/app_color.dart';
import '../other/app_text.dart';
import '../other/app_dimension.dart';
import '../../providers/phu_huynh.dart';

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
      backgroundColor: AppColors.surface,
      elevation: AppDimensions.elevationLG,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header với icon và title
                  _buildHeader(),

                  SizedBox(height: AppDimensions.spacingXXL),

                  // Mật khẩu cũ
                  _buildPasswordField(
                    controller: _matKhauCuController,
                    label: 'Mật khẩu cũ',
                    hint: 'Nhập mật khẩu hiện tại',
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

                  SizedBox(height: AppDimensions.spacingLG),

                  // Mật khẩu mới
                  _buildPasswordField(
                    controller: _matKhauMoiController,
                    label: 'Mật khẩu mới',
                    hint: 'Nhập mật khẩu mới',
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

                  SizedBox(height: AppDimensions.spacingLG),

                  // Xác nhận mật khẩu
                  _buildPasswordField(
                    controller: _xacNhanMatKhauController,
                    label: 'Xác nhận mật khẩu mới',
                    hint: 'Nhập lại mật khẩu mới',
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

                  SizedBox(height: AppDimensions.spacingXXL),

                  // Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            // Icon container
            Container(
              width: AppDimensions.iconXL,
              height: AppDimensions.iconXL,
              decoration: BoxDecoration(
                color: AppColors.primaryOverlay,
                borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: AppColors.primary,
                size: AppDimensions.iconMD,
              ),
            ),

            SizedBox(width: AppDimensions.spacingMD),

            // Title
            Text(
              'Đổi mật khẩu',
              style: AppTextStyles.displaySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // PASSWORD FIELD
  // ==========================================================================
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: AppDimensions.paddingOnly(
            left: AppDimensions.spacingXS,
            bottom: AppDimensions.spacingXS,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Text field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppDimensions.iconSM,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: AppDimensions.iconSM,
              ),
              onPressed: onToggle,
              splashRadius: AppDimensions.iconMD,
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
            fillColor: AppColors.surfaceVariant,
            contentPadding: AppDimensions.paddingSymmetric(
              horizontal: AppDimensions.spacingMD,
              vertical: AppDimensions.spacingMD,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ==========================================================================
  // ACTION BUTTONS
  // ==========================================================================
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Nút Hủy
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(
                color: AppColors.divider,
                width: AppDimensions.borderMedium,
              ),
              padding: AppDimensions.paddingSymmetric(
                vertical: AppDimensions.spacingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.buttonRadius,
                ),
              ),
            ),
            child: Text(
              'Hủy',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),

        SizedBox(width: AppDimensions.spacingMD),

        // Nút Đổi mật khẩu
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _doiMatKhau,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: AppDimensions.paddingSymmetric(
                vertical: AppDimensions.spacingMD,
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
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
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
        child: Container(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
          ),
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
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
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.textOnPrimary,
                size: AppDimensions.iconSM,
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: Text(
                  'Đổi mật khẩu thành công',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusCircular(
              AppDimensions.radiusMD,
            ),
          ),
          margin: AppDimensions.paddingAll(AppDimensions.spacingMD),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading

      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ==========================================================================
  // ERROR DIALOG
  // ==========================================================================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusCircular(
            AppDimensions.dialogRadius,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.elevationLG,
        child: Padding(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: AppDimensions.iconXL,
                height: AppDimensions.iconXL,
                decoration: BoxDecoration(
                  color: AppColors.errorOverlay,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconLG,
                  color: AppColors.error,
                ),
              ),

              SizedBox(height: AppDimensions.spacingLG),

              // Title
              Text(
                'Không thể đổi mật khẩu',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.spacingSM),

              // Message
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.spacingXXL),

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
                          width: AppDimensions.borderMedium,
                        ),
                        padding: AppDimensions.paddingSymmetric(
                          vertical: AppDimensions.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.buttonRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Đóng',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: AppDimensions.spacingMD),

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
                          vertical: AppDimensions.spacingMD,
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
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
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