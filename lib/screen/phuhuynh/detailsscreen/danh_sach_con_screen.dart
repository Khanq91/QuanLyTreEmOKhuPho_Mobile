import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/detailsscreen/xem_anh_screen.dart';
import 'package:provider/provider.dart';

import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../models/tab_con_toi.dart';
import '../../../providers/phu_huynh.dart';
import 'chi_tiet_tre_em_screen.dart';

class DanhSachConEmScreen extends StatelessWidget {
  const DanhSachConEmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Danh sách con em', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.appBarElevation,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.danhSachCon.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadDanhSachCon();
            });
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return ListView.builder(
            padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
            itemCount: provider.danhSachCon.length,
            itemBuilder: (context, index) {
              return _buildConCard(context, provider.danhSachCon[index]);
            },
          );
        },
      ),
    );
  }

  // ==========================================================================
  // CON CARD
  // ==========================================================================
  Widget _buildConCard(BuildContext context, TreEmBasicInfo con) {
    final isMale = con.gioiTinh.toLowerCase() == 'nam';
    final avatarColor = isMale
        ? AppColors.info.withOpacity(0.15)
        : Colors.pink.shade100;
    final iconColor = isMale ? AppColors.info : Colors.pink.shade700;

    const baseUrl = 'http://10.0.2.2:5035';

    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
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
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () {
                if (con.anh != null && con.anh!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        imageUrl: '$baseUrl${con.anh}',
                        title: con.hoTen,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                width: AppDimensions.avatarLG,
                height: AppDimensions.avatarLG,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: AppDimensions.borderThick,
                  ),
                ),
                child: ClipOval(
                  child: con.anh != null && con.anh!.isNotEmpty
                      ? Image.network(
                    '$baseUrl${con.anh}',
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
                          color: iconColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        isMale ? Icons.boy : Icons.girl,
                        size: AppDimensions.iconLG,
                        color: iconColor,
                      );
                    },
                  )
                      : Icon(
                    isMale ? Icons.boy : Icons.girl,
                    size: AppDimensions.iconLG,
                    color: iconColor,
                  ),
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
                    con.hoTen,
                    style: AppTextStyles.headingSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.spacingXXS),
                  _buildInfoRow(
                    Icons.cake,
                    'Ngày sinh: ${con.ngaySinh}',
                  ),
                  SizedBox(height: 2),
                  _buildInfoRow(
                    Icons.school,
                    'Trường: ${con.tenTruong}',
                  ),
                ],
              ),
            ),

            // Edit button
            Container(
              decoration: BoxDecoration(
                color: AppColors.infoOverlay,
                borderRadius: AppDimensions.radiusCircular(
                  AppDimensions.radiusSM,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: AppColors.info,
                  size: AppDimensions.iconSM,
                ),
                onPressed: () async {
                  final provider = context.read<PhuHuynhProvider>();

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );

                  try {
                    await provider.loadThongTinTreEm(con.treEmID);
                    Navigator.pop(context);

                    if (provider.thongTinTreEm != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThongTinTreEmScreen(
                            thongTin: provider.thongTinTreEm!,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusSM,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // INFO ROW
  // ==========================================================================
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXS,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: AppDimensions.spacingXXS),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}