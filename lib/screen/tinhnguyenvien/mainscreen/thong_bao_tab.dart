import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../models/tab_thong_bao_tnv.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../detailsscreen/chi_tiet_su_kien.dart';

class ThongBaoScreen extends StatefulWidget {
  const ThongBaoScreen({Key? key}) : super(key: key);

  @override
  State<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends State<ThongBaoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VolunteerProvider>().loadDanhSachThongBao();
      context.read<VolunteerProvider>().loadSoLuongChuaDoc();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildThongBaoList(),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // APP BAR
  // ==========================================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              Text('Thông báo', style: AppTextStyles.appBarTitle),
              if (provider.soLuongChuaDoc > 0) ...[
                SizedBox(width: AppDimensions.spacingXS),
                Container(
                  padding: AppDimensions.paddingSymmetric(
                    horizontal: AppDimensions.spacingXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.notificationBadge,
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  constraints: BoxConstraints(
                    minWidth: AppDimensions.badgeSize,
                    minHeight: AppDimensions.badgeSize,
                  ),
                  child: Center(
                    child: Text(
                      '${provider.soLuongChuaDoc}',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      elevation: AppDimensions.appBarElevation,
      backgroundColor: AppColors.appBarBackground,
      foregroundColor: AppColors.appBarText,
      actions: [
        Consumer<VolunteerProvider>(
          builder: (context, provider, child) {
            return provider.soLuongChuaDoc > 0
                ? IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Đánh dấu tất cả đã đọc',
              onPressed: () async {
                await provider.danhDauTatCaDaDoc();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã đánh dấu tất cả đã đọc'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusMD,
                        ),
                      ),
                    ),
                  );
                }
              },
            )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // ==========================================================================
  // FILTER CHIPS
  // ==========================================================================
  Widget _buildFilterChips() {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, child) {
        final filters = [
          {'label': 'Tất cả', 'value': 'TatCa', 'icon': Icons.all_inbox},
          {'label': 'Chưa đọc', 'value': 'ChuaDoc', 'icon': Icons.mark_email_unread},
          // {'label': 'Đã đọc', 'value': 'DaDoc', 'icon': Icons.check_circle_outline},
          // {'label': 'Sự kiện', 'value': 'SuKien', 'icon': Icons.event},
          // {'label': 'Vận động', 'value': 'VanDong', 'icon': Icons.directions_run},
        ];

        return Container(
          color: AppColors.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: AppDimensions.paddingSymmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.spacingSM,
            ),
            child: Row(
              children: filters.map((filter) {
                final isSelected = provider.thongBaoFilter == filter['value'];
                return Padding(
                  padding: AppDimensions.paddingOnly(
                    right: AppDimensions.spacingXS,
                  ),
                  child: _buildFilterChip(
                    label: filter['label'] as String,
                    value: filter['value'] as String,
                    icon: filter['icon'] as IconData,
                    isSelected: isSelected,
                    provider: provider,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VolunteerProvider provider,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      child: InkWell(
        onTap: () {
          provider.changeThongBaoFilter(value);
        },
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
        child: Container(
          padding: AppDimensions.paddingSymmetric(
            vertical: AppDimensions.spacingXS,
            horizontal: AppDimensions.spacingSM,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSM,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
              SizedBox(width: AppDimensions.spacingXXS),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // THÔNG BÁO LIST
  // ==========================================================================
  Widget _buildThongBaoList() {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingThongBao) {
          return _buildShimmerLoading();
        }

        if (provider.errorMessageThongBao != null) {
          return _buildErrorState(provider);
        }

        if (provider.danhSachThongBao.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDanhSachThongBao(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
            itemCount: provider.danhSachThongBao.length,
            itemBuilder: (context, index) {
              final thongBao = provider.danhSachThongBao[index];
              return _buildThongBaoCard(thongBao, provider);
            },
          ),
        );
      },
    );
  }

  // ==========================================================================
  // THÔNG BÁO CARD
  // ==========================================================================
  Widget _buildThongBaoCard(ThongBaoDto thongBao, VolunteerProvider provider) {
    final isUnread = !thongBao.daDoc;
    final priorityColor = _getPriorityColor(thongBao.mucDoUuTien);

    return Dismissible(
      key: Key('thongbao_${thongBao.thongBaoId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: AppDimensions.paddingOnly(right: AppDimensions.spacingLG),
        margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_all,
              color: AppColors.textOnPrimary,
              size: AppDimensions.iconLG,
            ),
            SizedBox(height: AppDimensions.spacingXXS),
            Text(
              'Đã đọc',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (isUnread) {
          await provider.danhDauDaDoc(thongBao.thongBaoId);
        }
        return false;
      },
      child: Container(
        margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          border: isUnread
              ? Border.all(
            color: AppColors.primary,
            width: AppDimensions.borderThick,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isUnread ? 0.08 : 0.04),
              blurRadius: isUnread ? 12 : 8,
              offset: Offset(0, isUnread ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (!thongBao.daDoc) {
                await provider.danhDauDaDoc(thongBao.thongBaoId);
              }
              if (thongBao.suKienId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EventDetailScreen(suKienId: thongBao.suKienId!),
                  ),
                );
              }
            },
            borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority indicator bar
                Container(
                  width: AppDimensions.borderExtraThick,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.cardRadius),
                      bottomLeft: Radius.circular(AppDimensions.cardRadius),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicator chấm
                        if (isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            margin: AppDimensions.paddingOnly(
                              top: 4,
                              right: AppDimensions.spacingSM,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(width: 22),

                        // Icon
                        Container(
                          padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                          decoration: BoxDecoration(
                            color: _getLoaiThongBaoColor(thongBao.loaiThongBao)
                                .withOpacity(0.1),
                            borderRadius: AppDimensions.radiusCircular(
                              AppDimensions.radiusMD,
                            ),
                          ),
                          child: Icon(
                            thongBao.icon,
                            color: _getLoaiThongBaoColor(thongBao.loaiThongBao),
                            size: AppDimensions.iconMD,
                          ),
                        ),

                        SizedBox(width: AppDimensions.spacingSM),

                        // Nội dung
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Loại thông báo
                              Row(
                                children: [
                                  Container(
                                    padding: AppDimensions.paddingSymmetric(
                                      horizontal: AppDimensions.spacingXS,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withOpacity(0.1),
                                      borderRadius: AppDimensions.radiusCircular(
                                        AppDimensions.radiusSM,
                                      ),
                                    ),
                                    child: Text(
                                      _getLoaiThongBaoLabel(thongBao.loaiThongBao),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: priorityColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: AppDimensions.iconXS - 2,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: AppDimensions.spacingXXS),
                                      Text(
                                        thongBao.timeAgo,
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: AppDimensions.spacingXS),

                              // Nội dung thông báo
                              Text(
                                thongBao.noiDung,
                                style: (isUnread
                                    ? AppTextStyles.bodyMedium
                                    : AppTextStyles.bodySmall)
                                    .copyWith(
                                  color: isUnread
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: isUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Tên sự kiện (nếu có)
                              if (thongBao.tenSuKien != null) ...[
                                SizedBox(height: AppDimensions.spacingXS),
                                Container(
                                  padding: AppDimensions.paddingSymmetric(
                                    horizontal: AppDimensions.spacingXS,
                                    vertical: AppDimensions.spacingXXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoOverlay,
                                    borderRadius: AppDimensions.radiusCircular(
                                      AppDimensions.radiusSM,
                                    ),
                                    border: Border.all(
                                      color: AppColors.info.withOpacity(0.3),
                                      width: AppDimensions.borderThin,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event,
                                        size: AppDimensions.iconXS,
                                        color: AppColors.info,
                                      ),
                                      SizedBox(width: AppDimensions.spacingXXS),
                                      Flexible(
                                        child: Text(
                                          thongBao.tenSuKien!,
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.info,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(width: AppDimensions.spacingXS),

                        // Arrow icon
                        Icon(
                          Icons.arrow_forward_ios,
                          size: AppDimensions.iconXS,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ERROR STATE
  // ==========================================================================
  Widget _buildErrorState(VolunteerProvider provider) {
    return Center(
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
            provider.errorMessageThongBao!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spacingMD),
          ElevatedButton.icon(
            onPressed: () => provider.loadDanhSachThongBao(),
            icon: const Icon(Icons.refresh),
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
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EMPTY STATE
  // ==========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
            decoration: BoxDecoration(
              color: AppColors.primaryOverlay,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: AppDimensions.iconXXL,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(
            'Chưa có thông báo',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHIMMER LOADING
  // ==========================================================================
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: AppDimensions.paddingOnly(bottom: AppDimensions.cardGap),
          padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: AppDimensions.paddingOnly(
                  top: 4,
                  right: AppDimensions.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusMD,
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusXS,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusXS,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXXS),
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusXS,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'URGENT':
        return AppColors.error;
      case 'IMPORTANT':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  Color _getLoaiThongBaoColor(String loai) {
    switch (loai) {
      case 'SuKien':
        return AppColors.info;
      case 'VanDong':
        return AppColors.secondary;
      case 'HoTro':
        return AppColors.success;
      case 'PhanCong':
        return AppColors.accent;
      case 'KhanCap':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _getLoaiThongBaoLabel(String loai) {
    switch (loai) {
      case 'SuKien':
        return 'SỰ KIỆN';
      case 'VanDong':
        return 'VẬN ĐỘNG';
      case 'HoTro':
        return 'HỖ TRỢ';
      case 'PhanCong':
        return 'PHÂN CÔNG';
      case 'KhanCap':
        return 'KHẨN CẤP';
      default:
        return 'THÔNG TIN';
    }
  }
}