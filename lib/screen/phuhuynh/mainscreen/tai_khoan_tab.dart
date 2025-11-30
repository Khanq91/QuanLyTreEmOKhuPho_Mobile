import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../models/tab_tai_khoan_ph.dart';
import '../../../providers/phu_huynh.dart';
import '../../auth/auth.dart';
import '../../other/dangxuat_function.dart';
import '../../other/splash_screen.dart';
import '../detailsscreen/danh_sach_con_screen.dart';
import '../detailsscreen/danh_sach_phu_huynh_screen.dart';
import '../../auth/doi_mat_khau_dialog.dart';

class TabTaiKhoanScreen extends StatelessWidget {
  const TabTaiKhoanScreen({Key? key}) : super(key: key);

  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tài khoản', style: AppTextStyles.appBarTitle),
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.thongTinTaiKhoan == null) {
            // Load data nếu chưa có
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadThongTinTaiKhoan();
            });
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final info = provider.thongTinTaiKhoan!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header với avatar
                _buildProfileHeader(context, info, provider),
                SizedBox(height: AppDimensions.spacingXS),
                // Menu options
                _buildMenuSection(context, provider),
                SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // PROFILE HEADER
  // ==========================================================================
  Widget _buildProfileHeader(
      BuildContext context,
      ThongTinTaiKhoanResponse info,
      PhuHuynhProvider provider,
      ) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.primary,
        // gradient: LinearGradient(
        //   colors: AppColors.primaryGradient,
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _showAvatarOptions(context, provider),
            child: Stack(
              children: [
                _buildAvatar(info.anh, info.hoTen),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: AppDimensions.iconSM,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),

          // Tên
          Text(
            info.hoTen,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spacingXXS),

          // Email
          Container(
            padding: AppDimensions.paddingSymmetric(
              horizontal: AppDimensions.spacingSM,
              vertical: AppDimensions.spacingXXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: AppDimensions.radiusCircular(
                AppDimensions.chipRadius,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email,
                  size: AppDimensions.iconXS,
                  color: AppColors.textOnPrimary,
                ),
                SizedBox(width: AppDimensions.spacingXXS),
                Flexible(
                  child: Text(
                    info.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spacingXS),

          // Số điện thoại
          Container(
            padding: AppDimensions.paddingSymmetric(
              horizontal: AppDimensions.spacingSM,
              vertical: AppDimensions.spacingXXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: AppDimensions.radiusCircular(
                AppDimensions.chipRadius,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone,
                  size: AppDimensions.iconXS,
                  color: AppColors.textOnPrimary,
                ),
                SizedBox(width: AppDimensions.spacingXXS),
                Text(
                  info.sdt,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // AVATAR
  // ==========================================================================
  Widget _buildAvatar(String? anh, String hoTen) {
    if (anh != null && anh.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.surface,
            width: AppDimensions.borderExtraThick,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: AppDimensions.avatarXXL / 2,
          backgroundImage: NetworkImage("$baseUrl$anh"),
          backgroundColor: AppColors.surface,
        ),
      );
    }

    // Avatar mặc định với chữ cái đầu
    final initial = hoTen.isNotEmpty ? hoTen[0].toUpperCase() : 'U';
    final colors = [
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.secondary,
      AppColors.error,
      AppColors.primary,
    ];
    final colorIndex = hoTen.codeUnitAt(0) % colors.length;
    final bgColor = colors[colorIndex];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.surface,
          width: AppDimensions.borderExtraThick,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: AppDimensions.avatarXXL / 2,
        backgroundColor: bgColor,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // AVATAR OPTIONS BOTTOM SHEET
  // ==========================================================================
  void _showAvatarOptions(BuildContext context, PhuHuynhProvider provider) {
    // Lưu context của màn hình chính
    final screenContext = context;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (sheetContext) => SafeArea(  // Đổi tên context thành sheetContext
        child: Padding(
          padding: AppDimensions.paddingSymmetric(
            vertical: AppDimensions.spacingLG,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusFull,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Title
              Padding(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                ),
                child: Text(
                  'Thay đổi ảnh đại diện',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Options
              _buildBottomSheetOption(
                sheetContext,
                icon: Icons.camera_alt,
                title: 'Chụp ảnh',
                color: AppColors.info,
                onTap: () {
                  Navigator.pop(sheetContext); // Pop bottom sheet
                  // Dùng screenContext thay vì sheetContext
                  _pickImage(screenContext, ImageSource.camera, provider);
                },
              ),
              _buildBottomSheetOption(
                sheetContext,
                icon: Icons.photo_library,
                title: 'Chọn từ thư viện',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(sheetContext); // Pop bottom sheet
                  // Dùng screenContext thay vì sheetContext
                  _pickImage(screenContext, ImageSource.gallery, provider);
                },
              ),
              _buildBottomSheetOption(
                sheetContext,
                icon: Icons.close,
                title: 'Hủy',
                color: AppColors.textSecondary,
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBottomSheetOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppDimensions.paddingSymmetric(
            horizontal: AppDimensions.spacingMD,
            vertical: AppDimensions.spacingSM,
          ),
          child: Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusMD,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingMD),
              Text(
                title,
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PICK IMAGE
  // ==========================================================================
  Future<void> _pickImage(
      BuildContext context,
      ImageSource source,
      PhuHuynhProvider provider,
      ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      print("Đường dẫn ảnh: ${pickedFile?.path}");
      if (!context.mounted) return;
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
        print("1");

      try {
        print("Bắt đầu upload ảnh...");
        await provider.uploadAnhTaiKhoan(File(pickedFile.path));
        if (!context.mounted) return;
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật ảnh thành công'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(
                AppDimensions.radiusSM,
              ),
            ),
          ),
        );
        print("Kết thúc upload ảnh...");
      } catch (e) {
        Navigator.pop(context); // Close loading
        print(e);
        showErrorDialog(context, 'Không thể tải ảnh lên. Vui lòng thử lại.');
      }
    }
  }

  // ==========================================================================
  // MENU SECTION
  // ==========================================================================
  Widget _buildMenuSection(BuildContext context, PhuHuynhProvider provider) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'Thông tin phụ huynh',
          subtitle: 'Xem và chỉnh sửa thông tin',
          color: AppColors.info,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DanhSachPhuHuynhScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.child_care,
          title: 'Cập nhật thông tin con em',
          subtitle: 'Chỉnh sửa thông tin các con',
          color: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DanhSachConEmScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.lock,
          title: 'Đổi mật khẩu',
          subtitle: 'Thay đổi mật khẩu đăng nhập',
          color: AppColors.warning,
          onTap: () => _showDoiMatKhauDialog(context, provider),
        ),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Đăng xuất',
          subtitle: 'Thoát khỏi tài khoản',
          color: AppColors.error,
          onTap: () => _showDangXuatDialog(context, provider),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          child: Padding(
            padding: AppDimensions.paddingSymmetric(
              horizontal: AppDimensions.cardPadding,
              vertical: AppDimensions.spacingSM,
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusMD,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: AppDimensions.iconLG,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingMD),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headingSmall,
                      ),
                      SizedBox(height: AppDimensions.spacingXXS),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppDimensions.iconXS,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ĐỔI MẬT KHẨU DIALOG
  // ==========================================================================
  void _showDoiMatKhauDialog(BuildContext context, PhuHuynhProvider provider) {
    showDialog(
      context: context,
      builder: (context) => const DoiMatKhauDialog(),
    );
  }

  // ==========================================================================
  // ĐĂNG XUẤT DIALOG
  // ==========================================================================

  void _showDangXuatDialog(BuildContext context, PhuHuynhProvider provider) {
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header với icon và title
                  Column(
                    children: [
                      // Icon container
                      Container(
                        width: AppDimensions.iconXL,
                        height: AppDimensions.iconXL,
                        decoration: BoxDecoration(
                          color: AppColors.errorOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusLG,
                          ),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: AppDimensions.iconMD,
                        ),
                      ),

                      SizedBox(height: AppDimensions.spacingMD),

                      // Title
                      Text(
                        'Xác nhận đăng xuất',
                        style: AppTextStyles.displaySmall,
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppDimensions.spacingXS),

                      // Content
                      Text(
                        'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.spacingXXL),

                  // Buttons
                  Row(
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

                      // Nút Đăng xuất
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close dialog

                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: Container(
                                  padding: AppDimensions.paddingAll(
                                    AppDimensions.spacingXXL,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppDimensions.radiusCircular(
                                      AppDimensions.radiusLG,
                                    ),
                                  ),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            );

                            try {
                              // 1. Đăng xuất từ server
                              await provider.dangXuat();

                              // 2. Clear tất cả providers
                              if (context.mounted) {
                                await clearAllUserData(context, "TNV");
                              }

                              // 3. Close loading
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // 4. RESTART APP - Quay về SplashScreen
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => SplashScreen(
                                      auth: context.read<AuthProvider>(),
                                    ),
                                  ),
                                      (route) => false,
                                );
                              }
                            } catch (e) {
                              // Close loading
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              if (context.mounted) {
                                showErrorDialog(
                                  context,
                                  'Lỗi đăng xuất. Vui lòng thử lại.',
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
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
                            'Đăng xuất',
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
        ),
      ),
    );
  }
  // // ==========================================================================
  // // ERROR DIALOG
  // // ==========================================================================
  // static void _showErrorDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: AppDimensions.radiusCircular(
  //           AppDimensions.dialogRadius,
  //         ),
  //       ),
  //       child: Padding(
  //         padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // Icon
  //             Container(
  //               padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
  //               decoration: BoxDecoration(
  //                 color: AppColors.errorOverlay,
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Icon(
  //                 Icons.error_outline,
  //                 size: AppDimensions.iconXL,
  //                 color: AppColors.error,
  //               ),
  //             ),
  //             SizedBox(height: AppDimensions.spacingMD),
  //
  //             // Title
  //             Text(
  //               'Lỗi',
  //               style: AppTextStyles.headingMedium,
  //             ),
  //             SizedBox(height: AppDimensions.spacingXS),
  //
  //             // Message
  //             Text(
  //               message,
  //               style: AppTextStyles.bodyMedium.copyWith(
  //                 color: AppColors.textSecondary,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: AppDimensions.spacingXL),
  //
  //             // Buttons
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: OutlinedButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     style: OutlinedButton.styleFrom(
  //                       foregroundColor: AppColors.textSecondary,
  //                       side: BorderSide(
  //                         color: AppColors.divider,
  //                         width: AppDimensions.borderThin,
  //                       ),
  //                       padding: AppDimensions.paddingSymmetric(
  //                         vertical: AppDimensions.spacingSM,
  //                       ),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: AppDimensions.radiusCircular(
  //                           AppDimensions.buttonRadius,
  //                         ),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       'Đóng',
  //                       style: AppTextStyles.labelLarge,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: AppDimensions.spacingSM),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       // Retry logic can be added here
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.primary,
  //                       foregroundColor: AppColors.textOnPrimary,
  //                       padding: AppDimensions.paddingSymmetric(
  //                         vertical: AppDimensions.spacingSM,
  //                       ),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: AppDimensions.radiusCircular(
  //                           AppDimensions.buttonRadius,
  //                         ),
  //                       ),
  //                       elevation: AppDimensions.elevationSM,
  //                     ),
  //                     child: Text(
  //                       'Thử lại',
  //                       style: AppTextStyles.labelLarge,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // // CLEAR USER DATA
  //
  // // ==========================================================================
  // // ==========================================================================
  // Future<void> _clearAllUserData(BuildContext context) async {
  //   // Clear PhuHuynhProvider
  //   context.read<PhuHuynhProvider>().clearAll();
  //
  //   // QUAN TRỌNG: Clear AuthProvider
  //   final authProvider = context.read<AuthProvider>();
  //   authProvider.clearAuth();
  // }
}