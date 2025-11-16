import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/providers/tinh_nguyen_vien.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// Import các file design pattern
import 'package:mobile/screen/other/app_color.dart';
import 'package:mobile/screen/other/app_text.dart';
import 'package:mobile/screen/other/app_dimension.dart';

class ChiTietTreVanDongScreen extends StatefulWidget {
  final int treEmId;

  const ChiTietTreVanDongScreen({Key? key, required this.treEmId}) : super(key: key);

  @override
  State<ChiTietTreVanDongScreen> createState() => _ChiTietTreVanDongScreenState();
}

class _ChiTietTreVanDongScreenState extends State<ChiTietTreVanDongScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTinhTrang;
  final _ghiChuController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<VolunteerProvider>(context, listen: false);
    await provider.loadChiTietTreVanDong(widget.treEmId);
  }

  @override
  void dispose() {
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chọn ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: AppDimensions.paddingOnly(bottom: AppDimensions.spacingMD),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              Text(
                'Chọn nguồn ảnh',
                style: AppTextStyles.headingMedium,
              ),
              SizedBox(height: AppDimensions.spacingLG),
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Chụp ảnh',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              SizedBox(height: AppDimensions.spacingXS),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: 'Chọn từ thư viện',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Row(
          children: [
            Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Icon(icon, color: AppColors.textOnPrimary, size: AppDimensions.iconMD),
            ),
            SizedBox(width: AppDimensions.spacingMD),
            Text(title, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCapNhat() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTinhTrang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn tình trạng'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final provider = Provider.of<VolunteerProvider>(context, listen: false);
    final chiTiet = provider.chiTietTreVanDong;

    if (chiTiet == null) return;

    final soLanMoi = chiTiet.tongSoLanVanDong + 1;
    final hoanCanhId = chiTiet.hoanCanhID;

    if (hoanCanhId == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin hoàn cảnh'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await provider.capNhatVanDong(
      treEmId: widget.treEmId,
      hoanCanhId: hoanCanhId,
      tinhTrangCapNhat: _selectedTinhTrang!,
      soLan: soLanMoi,
      ghiChuChiTiet: _ghiChuController.text.trim(),
      anhMinhChung: _selectedImage,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật vận động thành công'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Cập nhật thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chi tiết Trẻ cần vận động', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.appBarElevation,
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: AppDimensions.iconXXL, color: AppColors.error),
                    SizedBox(height: AppDimensions.spacingMD),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                    ),
                    SizedBox(height: AppDimensions.spacingLG),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: AppDimensions.paddingSymmetric(
                          horizontal: AppDimensions.buttonPaddingH,
                          vertical: AppDimensions.buttonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final chiTiet = provider.chiTietTreVanDong;
          if (chiTiet == null) {
            return Center(
              child: Text('Không có dữ liệu', style: AppTextStyles.bodyLarge),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(chiTiet),
                SizedBox(height: AppDimensions.spacingMD),
                _buildPhuHuynhSection(chiTiet),
                SizedBox(height: AppDimensions.spacingMD),
                _buildHoanCanhSection(chiTiet),
                SizedBox(height: AppDimensions.spacingMD),
                _buildLichSuSection(chiTiet),
                SizedBox(height: AppDimensions.spacingMD),
                _buildCapNhatForm(chiTiet),
                SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(chiTiet) {
    final age = DateTime.now().year - chiTiet.ngaySinh.year;

    return Container(
      margin: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: AppDimensions.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: AppDimensions.avatarLG / 2,
              backgroundColor: AppColors.primaryOverlay,
              backgroundImage: chiTiet.anh != null
                  ? NetworkImage('$baseUrl${chiTiet.anh}')
                  : null,
              child: chiTiet.anh == null
                  ? Icon(
                chiTiet.gioiTinh == 'Nam' ? Icons.boy : Icons.girl,
                size: AppDimensions.iconLG,
                color: AppColors.primary,
              )
                  : null,
            ),
          ),
          SizedBox(width: AppDimensions.spacingLG),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chiTiet.hoTen,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXS),
                Wrap(
                  spacing: AppDimensions.spacingXS,
                  runSpacing: AppDimensions.spacingXS,
                  children: [
                    _buildInfoChip(
                      icon: Icons.cake_outlined,
                      label: '$age tuổi',
                      color: AppColors.secondary,
                    ),
                    _buildInfoChip(
                      icon: chiTiet.gioiTinh == 'Nam' ? Icons.male : Icons.female,
                      label: chiTiet.gioiTinh,
                      color: AppColors.info,
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingSM),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.chipPaddingH,
                    vertical: AppDimensions.chipPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restart_alt,
                        size: AppDimensions.iconXS,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppDimensions.spacingXXS),
                      Text(
                        'Đã vận động: ${chiTiet.tongSoLanVanDong} lần',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconXS, color: chipColor),
          SizedBox(width: AppDimensions.spacingXXS),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Account Info (nếu cần sử dụng)
  Widget _buildAccountInfo(dynamic account) {
    if (account == null) return const SizedBox.shrink();

    return Container(
      margin: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: AppDimensions.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar với khả năng xem ảnh phóng to
          GestureDetector(
            onTap: account.avatar != null
                ? () {
              // Navigator.push to ImageViewerScreen nếu cần
            }
                : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: AppDimensions.avatarLG / 2,
                backgroundImage: account.avatar != null
                    ? NetworkImage("$baseUrl${account.avatar}")
                    : null,
                backgroundColor: AppColors.primaryOverlay,
                child: account.avatar == null
                    ? Text(
                  account.hoTen[0].toUpperCase(),
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.primary,
                  ),
                )
                    : null,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacingMD),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.hoTen,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXS,
                    vertical: AppDimensions.spacingXXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    account.chucVu,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXS),
                Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: AppDimensions.iconXS,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppDimensions.spacingXXS),
                    Text(
                      account.sdt,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhuHuynhSection(chiTiet) {
    return Container(
      margin: AppDimensions.paddingSymmetric(horizontal: AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOverlay,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(
                  Icons.family_restroom,
                  color: AppColors.secondary,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text('Thông tin Phụ huynh', style: AppTextStyles.headingMedium),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),

          ...chiTiet.danhSachPhuHuynh.map<Widget>((ph) => Container(
            margin: AppDimensions.paddingOnly(bottom: AppDimensions.spacingSM),
            padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.chipPaddingH,
                    vertical: AppDimensions.chipPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Text(
                    ph.moiQuanHe,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSM),
                _buildInfoRow(Icons.person_outline, 'Họ tên', ph.hoTen),
                _buildInfoRow(Icons.phone_outlined, 'SĐT', ph.sdt),
                _buildInfoRow(Icons.work_outline, 'Nghề nghiệp', ph.ngheNghiep),
                _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ', ph.diaChi),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildHoanCanhSection(chiTiet) {
    return Container(
      margin: AppDimensions.paddingSymmetric(horizontal: AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.warningOverlay,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text('Hoàn cảnh', style: AppTextStyles.headingMedium),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Container(
            padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
            decoration: BoxDecoration(
              color: AppColors.warningOverlay,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.warning, width: AppDimensions.borderMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chiTiet.loaiHoanCanh,
                  style: AppTextStyles.headingSmall.copyWith(color: AppColors.warning),
                ),
                if (chiTiet.moTaHoanCanh.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    chiTiet.moTaHoanCanh,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLichSuSection(chiTiet) {
    return Container(
      margin: AppDimensions.paddingSymmetric(horizontal: AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.infoOverlay,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(
                  Icons.history,
                  color: AppColors.info,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Text('Lịch sử vận động', style: AppTextStyles.headingMedium),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),

          if (chiTiet.lichSuVanDong.isEmpty)
            Center(
              child: Padding(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: AppDimensions.iconXL,
                      color: AppColors.textDisabled,
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      'Chưa có lịch sử vận động',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...chiTiet.lichSuVanDong.map<Widget>((ls) => Container(
              margin: AppDimensions.paddingOnly(bottom: AppDimensions.spacingSM),
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border(
                  left: BorderSide(
                    color: _getTinhTrangColor(ls.tinhTrangCapNhat),
                    width: AppDimensions.borderExtraThick,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.chipPaddingH,
                          vertical: AppDimensions.chipPaddingV,
                        ),
                        decoration: BoxDecoration(
                          color: _getTinhTrangColor(ls.tinhTrangCapNhat).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                          border: Border.all(
                            color: _getTinhTrangColor(ls.tinhTrangCapNhat),
                          ),
                        ),
                        child: Text(
                          ls.tinhTrangCapNhat,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _getTinhTrangColor(ls.tinhTrangCapNhat),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(ls.ngayCapNhat),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  if (ls.ghiChuChiTiet.isNotEmpty) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Text(ls.ghiChuChiTiet, style: AppTextStyles.bodyMedium),
                  ],
                  if (ls.anhMinhChung != null) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      child: Image.network(
                        '$baseUrl${ls.anhMinhChung}',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: AppColors.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              size: AppDimensions.iconLG,
                              color: AppColors.textDisabled,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildCapNhatForm(chiTiet) {
    return Container(
      margin: AppDimensions.paddingSymmetric(horizontal: AppDimensions.screenPaddingH),
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.successOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.success,
                    size: AppDimensions.iconMD,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSM),
                Text('Cập nhật tình trạng mới', style: AppTextStyles.headingMedium),
              ],
            ),
            SizedBox(height: AppDimensions.spacingLG),

            // Dropdown tình trạng
            DropdownButtonFormField<String>(
              value: _selectedTinhTrang,
              decoration: InputDecoration(
                labelText: 'Tình trạng *',
                labelStyle: AppTextStyles.bodyMedium,
                prefixIcon: Icon(Icons.info_outline, size: AppDimensions.iconMD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingMD,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Đi học', child: Text('Đi học')),
                DropdownMenuItem(value: 'Nghỉ học', child: Text('Nghỉ học')),
                DropdownMenuItem(value: 'Nguy cơ bỏ học', child: Text('Nguy cơ bỏ học')),
                DropdownMenuItem(value: 'Khác', child: Text('Khác')),
              ],
              onChanged: (value) {
                setState(() => _selectedTinhTrang = value);
              },
              validator: (value) {
                if (value == null) return 'Vui lòng chọn tình trạng';
                return null;
              },
            ),
            SizedBox(height: AppDimensions.formFieldGap),

            // TextArea ghi chú
            TextFormField(
              controller: _ghiChuController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Ghi chú thêm',
                labelStyle: AppTextStyles.bodyMedium,
                hintText: 'Nhập ghi chú về tình trạng của trẻ...',
                hintStyle: AppTextStyles.bodySmallHint,
                prefixIcon: Icon(Icons.note_outlined, size: AppDimensions.iconMD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              ),
            ),
            SizedBox(height: AppDimensions.formFieldGap),

            // Chụp ảnh
            Text(
              'Chụp ảnh minh chứng (Tùy chọn)',
              style: AppTextStyles.labelLarge,
            ),
            SizedBox(height: AppDimensions.spacingXS),

            InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
                child: _selectedImage != null
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: AppDimensions.spacingXS,
                      right: AppDimensions.spacingXS,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedImage = null);
                          },
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          child: Container(
                            padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.textOnPrimary,
                              size: AppDimensions.iconMD,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: AppDimensions.iconXL,
                      color: AppColors.textDisabled,
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      'Chụp hoặc chọn ảnh',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacingXL),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: AppDimensions.paddingSymmetric(
                        vertical: AppDimensions.buttonPaddingV + 4,
                      ),
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: AppTextStyles.button.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitCapNhat,
                    style: ElevatedButton.styleFrom(
                      padding: AppDimensions.paddingSymmetric(
                        vertical: AppDimensions.buttonPaddingV + 4,
                      ),
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: AppDimensions.iconSM),
                        SizedBox(width: AppDimensions.spacingXS),
                        Text('Gửi', style: AppTextStyles.button),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: AppDimensions.paddingOnly(bottom: AppDimensions.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimensions.iconXS, color: AppColors.textSecondary),
          SizedBox(width: AppDimensions.spacingXS),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTinhTrangColor(String tinhTrang) {
    switch (tinhTrang.toLowerCase()) {
      case 'đi học':
        return AppColors.success;
      case 'nghỉ học':
        return AppColors.warning;
      case 'nguy cơ bỏ học':
        return AppColors.error;
      default:
        return AppColors.textDisabled;
    }
  }
}