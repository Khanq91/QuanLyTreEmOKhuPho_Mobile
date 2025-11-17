import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screen/other/xem_anh_screen.dart';
import '../../../models/tab_con_toi.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class ChiTietTreEmScreen extends StatelessWidget {
  final TreEmBasicInfo child;

  const ChiTietTreEmScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMale = child.gioiTinh.toLowerCase() == 'nam';
    final baseUrl = 'http://10.0.2.2:5035';

    // Màu theo giới tính - khác biệt rõ ràng
    final primaryColor = isMale ? const Color(0xFF3949AB) : const Color(0xFFD81B60); // Indigo vs Pink
    final lightColor = isMale ? const Color(0xFF6F74DD) : const Color(0xFFF06292);
    final overlayColor = isMale ? const Color(0x1A3949AB) : const Color(0x1AD81B60);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Thông tin chi tiết',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.elevationXS,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với avatar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppDimensions.spacingXL),
              color: AppColors.background,
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      if (child.anh != null && child.anh!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerScreen(
                              imageUrl: '$baseUrl${child.anh}',
                              title: child.hoTen,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: AppDimensions.avatarXXL,
                      height: AppDimensions.avatarXXL,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: child.anh != null && child.anh!.isNotEmpty
                            ? Image.network(
                          '$baseUrl${child.anh}',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, imageChild, loadingProgress) {
                            if (loadingProgress == null) return imageChild;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              isMale ? Icons.boy_rounded : Icons.girl_rounded,
                              size: 64,
                              color: primaryColor,
                            );
                          },
                        )
                            : Icon(
                          isMale ? Icons.boy_rounded : Icons.girl_rounded,
                          size: 64,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingMD),
                  Text(
                    child.hoTen,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spacingXXS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.chipPaddingH,
                      vertical: AppDimensions.spacingXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                    ),
                    child: Text(
                      'ID: ${child.treEmID}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Thông tin chi tiết
            Padding(
              padding: EdgeInsets.all(AppDimensions.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin cơ bản
                  _buildSectionTitle('Thông tin cơ bản', primaryColor),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoCard(
                    icon: Icons.person_outline_rounded,
                    label: 'Họ và tên',
                    value: child.hoTen,
                    color: primaryColor,
                    overlayColor: overlayColor,
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoCard(
                    icon: Icons.cake_outlined,
                    label: 'Ngày sinh',
                    value: _formatDate(child.ngaySinh),
                    color: primaryColor,
                    overlayColor: overlayColor,
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoCard(
                    icon: isMale ? Icons.male_rounded : Icons.female_rounded,
                    label: 'Giới tính',
                    value: child.gioiTinh,
                    color: primaryColor,
                    overlayColor: overlayColor,
                  ),

                  SizedBox(height: AppDimensions.spacingXL),

                  // Thông tin học tập
                  _buildSectionTitle('Thông tin học tập', primaryColor),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoCard(
                    icon: Icons.school_outlined,
                    label: 'Trường',
                    value: child.tenTruong,
                    color: primaryColor,
                    overlayColor: overlayColor,
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoCard(
                    icon: Icons.auto_stories_outlined,
                    label: 'Cấp học',
                    value: child.capHoc,
                    color: primaryColor,
                    overlayColor: overlayColor,
                  ),

                  SizedBox(height: AppDimensions.spacingXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          ),
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Text(
          title,
          style: AppTextStyles.headingMedium,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color overlayColor,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: color.withOpacity(0.2),
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
          // Icon
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
          // Text
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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