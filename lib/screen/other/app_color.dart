import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================
  static const Color primary = Color(0xFF3949AB);
  static const Color primaryLight = Color(0xFF6F74DD);
  static const Color primaryDark = Color(0xFF1A237E);

  // ==================== SECONDARY COLORS ====================
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00796B);

  // ==================== ACCENT COLORS ====================
  static const Color accent = Color(0xFFFFB74D);
  static const Color accentLight = Color(0xFFFFE082);
  static const Color accentDark = Color(0xFFF57C00);

  // ==================== SEMANTIC COLORS ====================
  /// Success - Xanh lá: Thành công, hoàn thành
  static const Color success = Color(0xFF66BB6A);
  static const Color successLight = Color(0xFFA5D6A7);
  static const Color successDark = Color(0xFF388E3C);

  /// Warning - Cam: Cảnh báo, cần chú ý
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color warningDark = Color(0xFFF57C00);

  /// Error - Đỏ: Lỗi, nguy hiểm
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFC62828);

  /// Info - Xanh dương: Thông tin
  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFF90CAF9);
  static const Color infoDark = Color(0xFF1976D2);

  // ==================== BACKGROUND & SURFACE ====================
  /// Background - Màu nền chính của app
  static const Color background = Color(0xFFFAFAFA);

  /// Surface - Màu nền của cards, dialogs
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface Variant - Màu nền phụ
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Divider - Đường phân cách
  static const Color divider = Color(0xFFE0E0E0);

  // ==================== TEXT COLORS ====================
  /// Text Primary - Màu chữ chính
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Text Secondary - Màu chữ phụ
  static const Color textSecondary = Color(0xFF666666);

  /// Text Disabled - Màu chữ disabled
  static const Color textDisabled = Color(0xFF9E9E9E);

  /// Text Hint - Màu chữ placeholder
  static const Color textHint = Color(0xFFBDBDBD);

  /// Text on Primary - Màu chữ trên nền primary (thường là trắng)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on Secondary - Màu chữ trên nền secondary
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // ==================== COMPONENT-SPECIFIC COLORS ====================

  /// Card background với subtle shadow
  static const Color cardBackground = surface;

  /// AppBar background
  static const Color appBarBackground = primary;

  /// AppBar text & icons
  static const Color appBarText = textOnPrimary;

  /// Notification badge background
  static const Color notificationBadge = error;

  /// Notification badge text
  static const Color notificationBadgeText = textOnPrimary;

  // ==================== OVERLAY COLORS ====================
  /// Overlay cho các màu nền highlight (10% opacity)
  static const Color primaryOverlay = Color(0x1A3949AB); // primary 10%
  static const Color secondaryOverlay = Color(0x1A26A69A); // secondary 10%
  static const Color accentOverlay = Color(0x1AFFB74D); // accent 10%
  static const Color successOverlay = Color(0x1A66BB6A); // success 10%
  static const Color warningOverlay = Color(0x1AFFA726); // warning 10%
  static const Color errorOverlay = Color(0x1AEF5350); // error 10%
  static const Color infoOverlay = Color(0x1A42A5F5); // info 10%

  // ==================== XẾP LOẠI HỌC TẬP COLORS ====================
  /// Màu cho các loại xếp loại học tập
  static const Color xepLoaiXuatSac = Color(0xFFFFD700); // Gold
  static const Color xepLoaiGioi = success;
  static const Color xepLoaiKha = info;
  static const Color xepLoaiTrungBinh = warning;
  static const Color xepLoaiYeu = error;

  // ==================== GRADIENT COLORS ====================
  /// Gradient cho background hoặc cards đặc biệt
  static const List<Color> primaryGradient = [
    Color(0xFF3949AB),
    Color(0xFF5E35B1),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFF8A65),
  ];

  // ==================== HELPER METHODS ====================

  /// Lấy màu theo xếp loại học tập
  static Color getXepLoaiColor(String xepLoai) {
    switch (xepLoai.toLowerCase()) {
      case 'xuất sắc':
        return xepLoaiXuatSac;
      case 'giỏi':
        return xepLoaiGioi;
      case 'khá':
        return xepLoaiKha;
      case 'trung bình':
        return xepLoaiTrungBinh;
      case 'yếu':
        return xepLoaiYeu;
      default:
        return textDisabled;
    }
  }

  /// Lấy màu overlay nhẹ từ màu gốc (10% opacity)
  static Color withLightOverlay(Color color) {
    return color.withOpacity(0.1);
  }

  /// Lấy màu border từ màu gốc (20% opacity)
  static Color withBorder(Color color) {
    return color.withOpacity(0.2);
  }
}