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
import '../../phuhuynh/detailsscreen/doi_mat_khau_dialog.dart';
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
                  SizedBox(height: AppDimensions.spacingMD),
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textOnPrimary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface,
                      backgroundImage: profile.anh != null
                          ? NetworkImage('$baseUrl${profile.anh}')
                          : null,
                      child: profile.anh == null
                          ? Text(
                        profile.hoTen[0].toUpperCase(),
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showChangeAvatarDialog(provider),
                      child: Container(
                        padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textOnPrimary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: AppDimensions.iconSM,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Tên
              Text(
                profile.hoTen,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spacingXS),

              // Vai trò & Chức vụ
              Container(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${profile.chucVu ?? 'Tình nguyện viên'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacingMD),

              // Thông tin ngắn gọn
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoChip(
                    icon: Icons.phone,
                    label: profile.sdt,
                  ),
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
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.2),
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
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
      padding: AppDimensions.paddingSymmetric(horizontal: AppDimensions.spacingMD),
      child: Column(
        children: [
          _buildMenuSection(
            title: 'Thông tin cá nhân',
            items: [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Thông tin tài khoản',
                subtitle: 'Xem chi tiết thông tin cá nhân',
                onTap: () => _showProfileDetail(provider),
              ),
              _MenuItem(
                icon: Icons.calendar_today,
                title: 'Cập nhật lịch trống',
                subtitle: 'Cập nhật thời gian rảnh trong tuần',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LichTrongScreen()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),

          _buildMenuSection(
            title: 'Hoạt động',
            items: [
              _MenuItem(
                icon: Icons.history,
                title: 'Lịch sử hoạt động',
                subtitle: 'Xem lịch sử tham gia sự kiện',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LichSuHoatDongScreen()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),

          _buildMenuSection(
            title: 'Cài đặt',
            items: [
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                subtitle: 'Thay đổi mật khẩu đăng nhập',
                onTap: () => _showDoiMatKhauDialog(provider),
              ),
              _MenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                subtitle: 'Thoát khỏi tài khoản',
                textColor: AppColors.error,
                onTap: () => _logout(),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingXL),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
            child: Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildMenuItem(item),
                if (index < items.length - 1)
                  Divider(height: 1, color: AppColors.divider),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      leading: Container(
        padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
        decoration: BoxDecoration(
          color: (item.textColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
        ),
        child: Icon(
          item.icon,
          color: item.textColor ?? AppColors.primary,
          size: AppDimensions.iconMD,
        ),
      ),
      title: Text(
        item.title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: item.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
        item.subtitle!,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: item.onTap,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn ảnh đại diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, provider);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, provider);
              },
            ),
          ],
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

  // ==========================================================================
  // SHOW ĐỔI MẬT KHẨU DIALOG
  // ==========================================================================
  void _showDoiMatKhauDialog(VolunteerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => const DoiMatKhauDialog(),
    );
  }

  // ==========================================================================
  // LOGOUT
  // ==========================================================================
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Đăng xuất'),
          ),
        ],
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
  final Color? textColor;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });
}