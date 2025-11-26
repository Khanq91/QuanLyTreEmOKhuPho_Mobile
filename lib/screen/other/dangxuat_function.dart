import 'package:flutter/material.dart';
import 'package:mobile/providers/tinh_nguyen_vien.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../providers/phu_huynh.dart';
import 'app_color.dart';
import 'app_dimension.dart';
import 'app_text.dart';


void showErrorDialog(BuildContext context, String message) {
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
              message,
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
// Retry logic can be added here
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


Future<void> clearAllUserData(BuildContext context, String provider) async {
  // Clear PhuHuynhProvider
  if(provider == "PH") {
    context.read<PhuHuynhProvider>().clearAll();
  }
  else if(provider == "TNV") {
    context.read<VolunteerProvider>().clear();
  }

  // QUAN TRỌNG: Clear AuthProvider
  final authProvider = context.read<AuthProvider>();
  authProvider.clearAuth();
}