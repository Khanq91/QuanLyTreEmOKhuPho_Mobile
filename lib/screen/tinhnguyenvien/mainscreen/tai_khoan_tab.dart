// File: screens/tinh_nguyen_vien/tnv_account_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/providers/tinh_nguyen_vien.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import '../../other/app_text.dart';
import '../../auth/doi_mat_khau_dialog.dart';
import '../../other/dangxuat_function.dart';
import '../../other/splash_screen.dart';
import '../detailsscreen/chi_tiet_tinh_nguyen_vien.dart';
import '../detailsscreen/lich_su_hoat_dong.dart';
import '../detailsscreen/lich_trong_screen.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {

  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<VolunteerProvider>();
    try {
      await provider.loadProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.profile == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppDimensions.spacingMD),
                  Text('Không tải được thông tin', style: AppTextStyles.bodyLarge),
                  SizedBox(height: AppDimensions.spacingSM),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(provider),
                  SizedBox(height: AppDimensions.spacingXS),
                  _buildMenuList(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================
  Widget _buildHeader(VolunteerProvider provider) {
    final profile = provider.profile!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => _showChangeAvatarDialog(provider),
                child: Stack(
                  children: [
                    Container(
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
                        backgroundColor: AppColors.surface,
                        backgroundImage: profile.anh != null
                            ? NetworkImage('$baseUrl${profile.anh}')
                            : null,
                        child: profile.anh == null
                            ? Text(
                          profile.hoTen[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                            : null,
                      ),
                    ),
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
                profile.hoTen,
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spacingXXS),

              // Vai trò & Chức vụ
              Container(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.chipPaddingH,
                  vertical: AppDimensions.chipPaddingV,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.chipRadius,
                  ),
                ),
                child: Text(
                  '${profile.chucVu ?? 'Tình nguyện viên'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacingXS),

              // Thông tin ngắn gọn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoChip(
                    icon: Icons.phone,
                    label: profile.sdt,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  _buildInfoChip(
                    icon: Icons.location_on,
                    label: profile.tenKhuPho ?? 'N/A',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.chipPaddingH,
        vertical: AppDimensions.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.2),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: AppDimensions.spacingXXS),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textOnPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MENU LIST
  // ==========================================================================
  Widget _buildMenuList(VolunteerProvider provider) {
    return Padding(
      padding: AppDimensions.paddingSymmetric(horizontal: AppDimensions.screenPaddingH),
      child: Column(
        children: [
          _buildMenuSection(
            title: 'Thông tin cá nhân',
            items: [
              _MenuItem(
                icon: Icons.person,
                title: 'Thông tin tài khoản',
                subtitle: 'Xem và chỉnh sửa thông tin cá nhân',
                color: AppColors.info,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChinhSuaThongTinScreen(),
                    ),
                  );

                  // Nếu có thay đổi (result == true), reload profile
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
              _MenuItem(
                icon: Icons.calendar_today,
                title: 'Cập nhật lịch trống',
                subtitle: 'Cập nhật thời gian rảnh trong tuần',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LichTrongScreen()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.history,
                title: 'Lịch sử hoạt động',
                subtitle: 'Xem lịch sử tham gia sự kiện',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LichSuHoatDongScreen()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.lock,
                title: 'Đổi mật khẩu',
                subtitle: 'Thay đổi mật khẩu đăng nhập',
                color: AppColors.warning,
                onTap: () => _showDoiMatKhauDialog(provider),
              ),
              _MenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                subtitle: 'Thoát khỏi tài khoản',
                color: AppColors.error,
                onTap: () => _showDangXuatDialog(context, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (index < items.length - 1)
                SizedBox(height: 0),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Container(
      margin: AppDimensions.paddingSymmetric(
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
          onTap: item.onTap,
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
                    color: item.color.withOpacity(0.1),
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusMD,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
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
                        item.title,
                        style: AppTextStyles.headingSmall,
                      ),
                      if (item.subtitle != null) ...[
                        SizedBox(height: AppDimensions.spacingXXS),
                        Text(
                          item.subtitle!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
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
  // SHOW PROFILE DETAIL
  // ==========================================================================
  void _showProfileDetail(VolunteerProvider provider) {
    final profile = provider.profile!;
    final dateFormat = DateFormat('dd/MM/yyyy');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.dialogRadius),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOverlay,
                        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: AppDimensions.iconMD,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: Text(
                        'Thông tin tài khoản',
                        style: AppTextStyles.headingMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingXL),

                _buildDetailRow('Họ tên', profile.hoTen),
                _buildDetailRow('Số điện thoại', profile.sdt),
                _buildDetailRow('Email', profile.email),
                _buildDetailRow('Vai trò', profile.vaiTro),
                _buildDetailRow('Chức vụ', profile.chucVu ?? 'N/A'),
                _buildDetailRow(
                  'Ngày sinh',
                  profile.ngaySinh != null ? dateFormat.format(profile.ngaySinh!) : 'N/A',
                ),
                _buildDetailRow('Khu phố', profile.tenKhuPho ?? 'N/A'),
                _buildDetailRow('Địa chỉ khu phố', profile.diaChiKhuPho ?? 'N/A'),
                _buildDetailRow('Quận/Huyện', profile.quanHuyen ?? 'N/A'),
                _buildDetailRow('Thành phố', profile.thanhPho ?? 'N/A'),

                SizedBox(height: AppDimensions.spacingXL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: AppDimensions.paddingSymmetric(vertical: AppDimensions.spacingSM),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
                      ),
                    ),
                    child: Text('Đóng', style: AppTextStyles.labelLarge),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: AppDimensions.paddingSymmetric(vertical: AppDimensions.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHOW CHANGE AVATAR DIALOG
  // ==========================================================================
  void _showChangeAvatarDialog(VolunteerProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (sheetContext) => SafeArea(
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
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera, provider);
                },
              ),
              _buildBottomSheetOption(
                sheetContext,
                icon: Icons.photo_library,
                title: 'Chọn từ thư viện',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery, provider);
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

  Future<void> _pickImage(ImageSource source, VolunteerProvider provider) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image == null) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await provider.capNhatAvatar(File(image.path));

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật ảnh đại diện thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  void _showDoiMatKhauDialog(VolunteerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => const DoiMatKhauDialog(),
    );
  }
  // void _logout() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: AppDimensions.radiusCircular(
  //           AppDimensions.dialogRadius,
  //         ),
  //       ),
  //       backgroundColor: AppColors.surface,
  //       elevation: AppDimensions.elevationLG,
  //       child: Container(
  //         constraints: const BoxConstraints(maxWidth: 400),
  //         child: SingleChildScrollView(
  //           child: Padding(
  //             padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 // Header với icon và title
  //                 Column(
  //                   children: [
  //                     // Icon container
  //                     Container(
  //                       width: AppDimensions.iconXL,
  //                       height: AppDimensions.iconXL,
  //                       decoration: BoxDecoration(
  //                         color: AppColors.errorOverlay,
  //                         borderRadius: AppDimensions.radiusCircular(
  //                           AppDimensions.radiusLG,
  //                         ),
  //                       ),
  //                       child: Icon(
  //                         Icons.logout_rounded,
  //                         color: AppColors.error,
  //                         size: AppDimensions.iconMD,
  //                       ),
  //                     ),
  //
  //                     SizedBox(height: AppDimensions.spacingMD),
  //
  //                     // Title
  //                     Text(
  //                       'Xác nhận đăng xuất',
  //                       style: AppTextStyles.displaySmall,
  //                       textAlign: TextAlign.center,
  //                     ),
  //
  //                     SizedBox(height: AppDimensions.spacingXS),
  //
  //                     // Content
  //                     Text(
  //                       'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
  //                       style: AppTextStyles.bodyMedium.copyWith(
  //                         color: AppColors.textSecondary,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ],
  //                 ),
  //
  //                 SizedBox(height: AppDimensions.spacingXXL),
  //
  //                 // Buttons
  //                 Row(
  //                   children: [
  //                     // Nút Hủy
  //                     Expanded(
  //                       child: OutlinedButton(
  //                         onPressed: () => Navigator.pop(context),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: AppColors.textSecondary,
  //                           side: BorderSide(
  //                             color: AppColors.divider,
  //                             width: AppDimensions.borderMedium,
  //                           ),
  //                           padding: AppDimensions.paddingSymmetric(
  //                             vertical: AppDimensions.spacingMD,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: AppDimensions.radiusCircular(
  //                               AppDimensions.buttonRadius,
  //                             ),
  //                           ),
  //                         ),
  //                         child: Text(
  //                           'Hủy',
  //                           style: AppTextStyles.labelLarge.copyWith(
  //                             color: AppColors.textSecondary,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //
  //                     SizedBox(width: AppDimensions.spacingMD),
  //
  //                     // Nút Đăng xuất
  //                     Expanded(
  //                       flex: 2,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           Navigator.pop(context);
  //                           await context.read<AuthProvider>().logout();
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: AppColors.error,
  //                           foregroundColor: AppColors.textOnPrimary,
  //                           padding: AppDimensions.paddingSymmetric(
  //                             vertical: AppDimensions.spacingMD,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: AppDimensions.radiusCircular(
  //                               AppDimensions.buttonRadius,
  //                             ),
  //                           ),
  //                           elevation: AppDimensions.elevationSM,
  //                         ),
  //                         child: Text(
  //                           'Đăng xuất',
  //                           style: AppTextStyles.labelLarge.copyWith(
  //                             color: AppColors.textOnPrimary,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showDangXuatDialog(BuildContext context, VolunteerProvider provider) {
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
}

// ==========================================================================
// MENU ITEM DATA CLASS
// ==========================================================================
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
}