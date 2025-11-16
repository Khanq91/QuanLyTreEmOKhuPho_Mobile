import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/detailsscreen/xem_anh_screen.dart';
import 'package:provider/provider.dart';

import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../models/tab_tai_khoan_ph.dart';
import '../../../providers/phu_huynh.dart';
import 'chi_tiet_phu_huynh_screen.dart';

class DanhSachPhuHuynhScreen extends StatelessWidget {
  const DanhSachPhuHuynhScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Danh sách phụ huynh', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        elevation: AppDimensions.appBarElevation,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.danhSachPhuHuynh.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadDanhSachPhuHuynh();
            });
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(context, provider);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDanhSachPhuHuynh(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
              itemCount: provider.danhSachPhuHuynh.length,
              itemBuilder: (context, index) {
                return _buildPhuHuynhCard(
                  context,
                  provider.danhSachPhuHuynh[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // ERROR STATE
  // ==========================================================================
  Widget _buildErrorState(BuildContext context, PhuHuynhProvider provider) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.errorOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: AppDimensions.iconXXL,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppDimensions.spacingMD),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXL),
            ElevatedButton.icon(
              onPressed: () => provider.loadDanhSachPhuHuynh(),
              icon: Icon(Icons.refresh, size: AppDimensions.iconSM),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingXL,
                  vertical: AppDimensions.spacingSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.buttonRadius,
                  ),
                ),
                elevation: AppDimensions.elevationSM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PHỤ HUYNH CARD
  // ==========================================================================
  Widget _buildPhuHuynhCard(
      BuildContext context,
      PhuHuynhVoiMoiQuanHe phuHuynh,
      ) {
    const baseUrl = 'http://10.0.2.2:5035';
    final hasAvatar = phuHuynh.anh.isNotEmpty;

    return Container(
      margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với avatar và thông tin cơ bản
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: hasAvatar
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewerScreen(
                          imageUrl: '$baseUrl${phuHuynh.anh}',
                          title: phuHuynh.hoTen,
                        ),
                      ),
                    );
                  }
                      : null,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.info,
                        width: AppDimensions.borderThick,
                      ),
                    ),
                    child: ClipOval(
                      child: hasAvatar
                          ? Image.network(
                        '$baseUrl${phuHuynh.anh}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: AppDimensions.iconLG,
                            color: AppColors.info,
                          );
                        },
                      )
                          : Icon(
                        Icons.person,
                        size: AppDimensions.iconLG,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacingMD),

                // Thông tin cơ bản
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phuHuynh.hoTen,
                        style: AppTextStyles.headingMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimensions.spacingXXS),
                      _buildInfoRow(
                        Icons.phone,
                        phuHuynh.sdt,
                      ),
                      if (phuHuynh.ngheNghiep.isNotEmpty) ...[
                        SizedBox(height: 2),
                        _buildInfoRow(
                          Icons.work,
                          phuHuynh.ngheNghiep,
                        ),
                      ],
                    ],
                  ),
                ),

                // Nút Edit
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
                        await provider.loadChiTietPhuHuynh(phuHuynh.phuHuynhID);
                        Navigator.pop(context);

                        if (provider.chiTietPhuHuynh != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChiTietPhuHuynhScreen(
                                phuHuynh: provider.chiTietPhuHuynh!,
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

            // Divider và mối quan hệ
            if (phuHuynh.danhSachMoiQuanHe.isNotEmpty) ...[
              Divider(
                height: AppDimensions.spacingXL,
                thickness: AppDimensions.dividerThickness,
                color: AppColors.divider,
              ),

              // Header mối quan hệ
              Row(
                children: [
                  Container(
                    padding: AppDimensions.paddingAll(
                      AppDimensions.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successOverlay,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Icon(
                      Icons.family_restroom,
                      size: AppDimensions.iconSM,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    'Mối quan hệ:',
                    style: AppTextStyles.headingSmall,
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacingSM),

              // Danh sách mối quan hệ
              ...phuHuynh.danhSachMoiQuanHe.map((mqh) {
                return Padding(
                  padding: AppDimensions.paddingOnly(
                    bottom: AppDimensions.spacingXS,
                    left: AppDimensions.spacingLG + AppDimensions.spacingXS,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: AppDimensions.paddingOnly(top: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium,
                            children: [
                              TextSpan(
                                text: '${mqh.moiQuanHe} ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              TextSpan(
                                text: 'của ',
                                style: AppTextStyles.bodyMedium,
                              ),
                              TextSpan(
                                text: mqh.tenTreEm,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
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