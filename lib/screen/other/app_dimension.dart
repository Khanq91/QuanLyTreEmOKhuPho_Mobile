import 'package:flutter/material.dart';

/// Định nghĩa tất cả spacing, sizes, radius sử dụng trong app
class AppDimensions {
  AppDimensions._();

  // ==================== SPACING SYSTEM ====================
  /// Base unit: 4px
  static const double baseUnit = 4.0;

  /// XXS - 4px - Minimal spacing
  static const double spacingXXS = 4.0;

  /// XS - 8px - Small gaps
  static const double spacingXS = 8.0;

  /// SM - 12px - Compact spacing
  static const double spacingSM = 12.0;

  /// MD - 16px - Default spacing (Most common)
  static const double spacingMD = 16.0;

  /// LG - 20px - Comfortable spacing
  static const double spacingLG = 20.0;

  /// XL - 24px - Section spacing
  static const double spacingXL = 24.0;

  /// XXL - 32px - Large sections
  static const double spacingXXL = 32.0;

  /// XXXL - 48px - Major sections
  static const double spacingXXXL = 48.0;

  // ==================== PADDING ====================
  /// Screen horizontal padding
  static const double screenPaddingH = spacingMD; // 16px

  /// Screen vertical padding
  static const double screenPaddingV = spacingMD; // 16px

  /// Card padding
  static const double cardPadding = spacingMD; // 16px

  /// Card padding large
  static const double cardPaddingLarge = spacingLG; // 20px

  /// Button padding horizontal
  static const double buttonPaddingH = spacingXL; // 24px

  /// Button padding vertical
  static const double buttonPaddingV = spacingSM; // 12px

  /// Chip padding horizontal
  static const double chipPaddingH = spacingSM; // 12px

  /// Chip padding vertical
  static const double chipPaddingV = spacingXS; // 8px

  // ==================== MARGIN / GAP ====================
  /// Gap between cards
  static const double cardGap = spacingMD; // 16px

  /// Gap between sections
  static const double sectionGap = spacingXL; // 24px

  /// Gap between list items
  static const double listItemGap = spacingSM; // 12px

  /// Gap between inline elements
  static const double inlineGap = spacingXS; // 8px

  /// Gap between form fields
  static const double formFieldGap = spacingMD; // 16px

  // ==================== BORDER RADIUS ====================
  /// XS - 4px - Minimal rounding
  static const double radiusXS = 4.0;

  /// SM - 8px - Small rounding
  static const double radiusSM = 8.0;

  /// MD - 12px - Default rounding for buttons
  static const double radiusMD = 12.0;

  /// LG - 16px - Default rounding for cards
  static const double radiusLG = 16.0;

  /// XL - 20px - Large rounding
  static const double radiusXL = 20.0;

  /// XXL - 24px - Extra large rounding
  static const double radiusXXL = 24.0;

  /// Full - 999px - Circular (pills, badges)
  static const double radiusFull = 999.0;

  // ==================== COMPONENT-SPECIFIC RADIUS ====================
  /// Card border radius
  static const double cardRadius = radiusLG; // 16px

  /// Button border radius
  static const double buttonRadius = radiusMD; // 12px

  /// Chip/Tag border radius
  static const double chipRadius = radiusXL; // 20px (pill shape)

  /// Input field border radius
  static const double inputRadius = radiusMD; // 12px

  /// Dialog border radius
  static const double dialogRadius = radiusXL; // 20px

  /// Bottom sheet border radius
  static const double bottomSheetRadius = radiusXL; // 20px

  // ==================== ICON SIZES ====================
  /// Icon XS - 16px - Small inline icons
  static const double iconXS = 16.0;

  /// Icon SM - 20px - Default icons
  static const double iconSM = 20.0;

  /// Icon MD - 24px - Standard icons (Most common)
  static const double iconMD = 24.0;

  /// Icon LG - 32px - Feature icons
  static const double iconLG = 32.0;

  /// Icon XL - 48px - Hero icons
  static const double iconXL = 48.0;

  /// Icon XXL - 64px - Large illustrations
  static const double iconXXL = 64.0;

  // ==================== AVATAR SIZES ====================
  /// Avatar XS - 24px
  static const double avatarXS = 24.0;

  /// Avatar SM - 32px
  static const double avatarSM = 32.0;

  /// Avatar MD - 40px
  static const double avatarMD = 40.0;

  /// Avatar LG - 60px - Default for profile
  static const double avatarLG = 60.0;

  /// Avatar XL - 80px
  static const double avatarXL = 80.0;

  /// Avatar XXL - 120px
  static const double avatarXXL = 120.0;

  // ==================== BUTTON SIZES ====================
  /// Button height small
  static const double buttonHeightSM = 36.0;

  /// Button height medium (default)
  static const double buttonHeightMD = 44.0;

  /// Button height large
  static const double buttonHeightLG = 52.0;

  /// Button min width
  static const double buttonMinWidth = 88.0;

  // ==================== INPUT FIELD SIZES ====================
  /// Input height default
  static const double inputHeight = 48.0;

  /// Input height small
  static const double inputHeightSM = 40.0;

  /// Input height large
  static const double inputHeightLG = 56.0;

  // ==================== BADGE/CHIP SIZES ====================
  /// Badge size (notification count)
  static const double badgeSize = 20.0;

  /// Badge size small
  static const double badgeSizeSM = 16.0;

  /// Chip height
  static const double chipHeight = 32.0;

  /// Chip height small
  static const double chipHeightSM = 24.0;

  // ==================== ELEVATION ====================
  /// No elevation
  static const double elevationNone = 0.0;

  /// Subtle elevation (cards)
  static const double elevationXS = 1.0;

  /// Small elevation
  static const double elevationSM = 2.0;

  /// Medium elevation (default)
  static const double elevationMD = 4.0;

  /// Large elevation (modals, dialogs)
  static const double elevationLG = 8.0;

  /// Extra large elevation (navigation drawer)
  static const double elevationXL = 16.0;

  // ==================== BORDER WIDTH ====================
  /// Thin border
  static const double borderThin = 1.0;

  /// Medium border
  static const double borderMedium = 1.5;

  /// Thick border
  static const double borderThick = 2.0;

  /// Extra thick border (emphasis)
  static const double borderExtraThick = 4.0;

  // ==================== DIVIDER ====================
  /// Divider thickness
  static const double dividerThickness = 1.0;

  /// Divider indent
  static const double dividerIndent = spacingMD; // 16px

  // ==================== APP BAR ====================
  /// AppBar height
  static const double appBarHeight = 56.0;

  /// AppBar elevation
  static const double appBarElevation = elevationXS; // 1.0

  // ==================== BOTTOM NAV BAR ====================
  /// Bottom navigation bar height
  static const double bottomNavHeight = 75.0;

  /// Bottom navigation bar elevation
  static const double bottomNavElevation = elevationSM; // 2.0

  // ==================== TOUCH TARGET ====================
  /// Minimum touch target size (accessibility)
  static const double minTouchTarget = 44.0;

  /// Recommended touch target size
  static const double recommendedTouchTarget = 48.0;

  /// Touch target padding (when element is smaller than minTouchTarget)
  static const double touchTargetPadding = 12.0;

  // ==================== MAX WIDTHS ====================
  /// Max width for readable text content
  static const double maxTextWidth = 600.0;

  /// Max width for forms
  static const double maxFormWidth = 480.0;

  /// Max width for cards
  static const double maxCardWidth = 400.0;

  // ==================== ANIMATION DURATION ====================
  /// Fast animation (150ms)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Normal animation (250ms)
  static const Duration animationNormal = Duration(milliseconds: 250);

  /// Slow animation (350ms)
  static const Duration animationSlow = Duration(milliseconds: 350);

  // ==================== HELPER METHODS ====================

  /// Get spacing from multiplier (base unit = 4px)
  static double spacing(double multiplier) {
    return baseUnit * multiplier;
  }

  /// Get padding from all sides
  static EdgeInsets paddingAll(double value) {
    return EdgeInsets.all(value);
  }

  /// Get symmetric padding
  static EdgeInsets paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Get padding from LTRB
  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }

  /// Get border radius circular
  static BorderRadius radiusCircular(double value) {
    return BorderRadius.circular(value);
  }

  /// Get border radius only
  static BorderRadius radiusOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}