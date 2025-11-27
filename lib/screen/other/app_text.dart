import 'package:flutter/material.dart';
import 'app_color.dart';

/// Định nghĩa tất cả text styles sử dụng trong app
class AppTextStyles {
  AppTextStyles._();

  // ==================== DISPLAY STYLES ====================
  /// Display Large - 32px, Bold - Dùng cho hero sections, splash screens
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Display Medium - 28px, Bold - Dùng cho page headers
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Display Small - 24px, SemiBold - Dùng cho section headers
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  // ==================== HEADING STYLES ====================
  /// Heading Large - 20px, SemiBold - Dùng cho card titles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Heading Medium - 18px, SemiBold - Dùng cho subheadings
  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Heading Small - 16px, SemiBold - Dùng cho small headers
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ==================== BODY STYLES ====================
  /// Body Large - 16px, Regular - Dùng cho main content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body Medium - 14px, Regular - Dùng cho default body text
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body Small - 13px, Regular - Dùng cho secondary info
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ==================== LABEL STYLES ====================
  /// Label Large - 14px, Medium - Dùng cho buttons, labels quan trọng
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  /// Label Large - 14px, Medium - Dùng cho buttons, labels quan trọng
  static const TextStyle labelLargeConverter = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );

  /// Label Medium - 12px, Medium - Dùng cho chips, tags
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  /// Label Small - 11px, Medium - Dùng cho small labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ==================== CAPTION STYLES ====================
  /// Caption - 12px, Regular - Dùng cho hints, helpers
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Overline - 11px, Medium, Uppercase - Dùng cho category labels
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // ==================== SPECIALIZED STYLES ====================

  /// Button Text - 14px, Medium
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.75,
  );

  /// AppBar Title - 18px, SemiBold
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.appBarText,
    letterSpacing: 0.15,
  );

  /// Chip Text - 12px, Medium
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );

  /// Badge Text - 10px, Bold
  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.notificationBadgeText,
  );

  /// Number Large - 28px, Bold - Dùng cho số liệu quan trọng
  static const TextStyle numberLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Number Medium - 24px, Bold - Dùng cho statistics
  static const TextStyle numberMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Number Small - 20px, SemiBold - Dùng cho small numbers
  static const TextStyle numberSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // ==================== TEXT WITH COLOR VARIANTS ====================

  /// Body Medium Secondary - Màu chữ secondary
  static const TextStyle bodyMediumSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Body Small Hint - Màu hint
  static const TextStyle bodySmallHint = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textHint,
  );

  /// Caption Secondary - Màu secondary
  static const TextStyle captionSecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // ==================== HELPER METHODS ====================

  /// Tạo text style với màu custom
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Tạo text style với font weight custom
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Tạo text style với font size custom
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Tạo text style in đậm
  static TextStyle toBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Tạo text style in nghiêng
  static TextStyle toItalic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Tạo text style gạch dưới
  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }

  /// Tạo text style gạch ngang (line-through)
  static TextStyle withLineThrough(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.lineThrough);
  }
}