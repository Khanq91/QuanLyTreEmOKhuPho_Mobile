import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/tab_con_toi.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class ChiTietPhieuHocTapScreen extends StatelessWidget {
  final PhieuHocTapInfo phieu;

  const ChiTietPhieuHocTapScreen({Key? key, required this.phieu})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy màu theo xếp loại
    final xepLoaiColor = _getXepLoaiColor(phieu.xepLoai);
    final xepLoaiOverlay = xepLoaiColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Chi tiết phiếu học tập',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.elevationXS,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card - Thông tin lớp
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppDimensions.cardPaddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.chipPaddingH,
                      vertical: AppDimensions.spacingXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOverlay,
                      borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                    ),
                    child: Text(
                      phieu.tenLop,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    phieu.tenTruong,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Stats Cards - 3 cards ngang
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star_rounded,
                    label: 'Điểm TB',
                    value: phieu.diemTrungBinh.toStringAsFixed(1),
                    color: AppColors.accent,
                    overlayColor: AppColors.accentOverlay,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.emoji_events_rounded,
                    label: 'Xếp loại',
                    value: phieu.xepLoai,
                    color: xepLoaiColor,
                    overlayColor: xepLoaiOverlay,
                    isText: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacingSM),

            // Hạnh kiểm - Full width
            _buildStatCard(
              icon: Icons.favorite_rounded,
              label: 'Hạnh kiểm',
              value: phieu.hanhKiem,
              color: AppColors.secondary,
              overlayColor: AppColors.secondaryOverlay,
              fullWidth: true,
              isText: true,
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Nhận xét section
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),
                Text(
                  'Nhận xét của giáo viên',
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacingSM),

            // Nhận xét content
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.2),
                  width: AppDimensions.borderThin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Border trái màu đậm
                  Container(
                    width: AppDimensions.borderExtraThick,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.cardRadius),
                        bottomLeft: Radius.circular(AppDimensions.cardRadius),
                      ),
                    ),
                  ),
                  // Nội dung nhận xét
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.cardPadding),
                      child: Text(
                        phieu.nhanXet.isNotEmpty ? phieu.nhanXet : 'Chưa có nhận xét',
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.6,
                          color: phieu.nhanXet.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontStyle: phieu.nhanXet.isNotEmpty
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Ngày cập nhật
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.cardPadding,
                vertical: AppDimensions.spacingSM,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.update_rounded,
                    size: AppDimensions.iconXS,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    'Cập nhật: ${_formatDate(phieu.ngayCapNhat)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color overlayColor,
    bool fullWidth = false,
    bool isText = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: AppDimensions.borderThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: fullWidth
          ? Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: overlayColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconMD,
              color: color,
            ),
          ),
          SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                Text(
                  value,
                  style: isText
                      ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                      : AppTextStyles.numberMedium.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: overlayColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconMD,
              color: color,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spacingXXS),
          Text(
            value,
            style: isText
                ? AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            )
                : AppTextStyles.numberMedium.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getXepLoaiColor(String xepLoai) {
    final xl = xepLoai.toLowerCase();
    if (xl.contains('xuất sắc') || xl.contains('xuat sac')) {
      return AppColors.xepLoaiXuatSac;
    } else if (xl.contains('giỏi') || xl.contains('gioi')) {
      return AppColors.xepLoaiGioi;
    } else if (xl.contains('khá') || xl.contains('kha')) {
      return AppColors.xepLoaiKha;
    } else if (xl.contains('trung bình') || xl.contains('trung binh')) {
      return AppColors.xepLoaiTrungBinh;
    } else if (xl.contains('yếu') || xl.contains('yeu')) {
      return AppColors.xepLoaiYeu;
    }
    return AppColors.textDisabled;
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }
}