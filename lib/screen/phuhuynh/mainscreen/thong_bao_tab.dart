import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';
import '../../../models/tab_thong_bao_ph.dart';
import '../../../providers/phu_huynh.dart';
import '../detailsscreen/chi_tiet_su_kien_sk_screen.dart';

/// ============================================================================
/// REDESIGNED THÔNG BÁO SCREEN - Modern Soft & Friendly
/// ============================================================================
class TabThongBaoScreen extends StatefulWidget {
  const TabThongBaoScreen({Key? key}) : super(key: key);

  @override
  State<TabThongBaoScreen> createState() => _TabThongBaoScreenState();
}

class _TabThongBaoScreenState extends State<TabThongBaoScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'all'; // 'all' hoặc 'unread'
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<PhuHuynhProvider>();
    await provider.loadDanhSachThongBao(filter: _selectedFilter);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    // TODO: Implement pagination API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Thông báo', style: AppTextStyles.appBarTitle),
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter Tabs
              _buildFilterTabs(provider),
              // Danh sách thông báo
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadInitialData,
                  color: AppColors.primary,
                  child: _buildThongBaoList(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // FILTER TABS
  // ==========================================================================
  Widget _buildFilterTabs(PhuHuynhProvider provider) {
    final soLuongChuaDoc = provider.thongBaoData?.soLuongChuaDoc ?? 0;

    return Container(
      color: AppColors.surface,
      padding: AppDimensions.paddingSymmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingSM,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(
              label: 'Tất cả',
              value: 'all',
              icon: Icons.notifications,
              isSelected: _selectedFilter == 'all',
              badge: null,
            ),
          ),
          SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: _buildFilterChip(
              label: 'Chưa đọc',
              value: 'unread',
              icon: Icons.mark_email_unread,
              isSelected: _selectedFilter == 'unread',
              badge: soLuongChuaDoc > 0 ? soLuongChuaDoc : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
    int? badge,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = value;
            _currentPage = 1;
          });
          _loadInitialData();
        },
        borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
        child: Container(
          padding: AppDimensions.paddingSymmetric(
            vertical: AppDimensions.spacingSM,
            horizontal: AppDimensions.spacingMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSM,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: AppDimensions.spacingXS),
                Container(
                  padding: AppDimensions.paddingSymmetric(
                    horizontal: AppDimensions.spacingXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.notificationBadge,
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
                      badge.toString(),
                      style: AppTextStyles.badge.copyWith(
                        color: isSelected
                            ? AppColors.error
                            : AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // THÔNG BÁO LIST
  // ==========================================================================
  Widget _buildThongBaoList(PhuHuynhProvider provider) {
    if (provider.isLoading && provider.thongBaoData == null) {
      return _buildShimmerLoading();
    }

    final thongBaoList = provider.thongBaoData?.danhSachThongBao ?? [];

    if (thongBaoList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
      itemCount: thongBaoList.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == thongBaoList.length) {
          return Center(
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }
        return _buildThongBaoCard(thongBaoList[index], provider);
      },
    );
  }

  // ==========================================================================
  // THÔNG BÁO CARD
  // ==========================================================================
  Widget _buildThongBaoCard(ThongBaoInfo thongBao, PhuHuynhProvider provider) {
    final isUnread = !thongBao.daDoc;

    return Dismissible(
      key: Key('thongbao_${thongBao.thongBaoID}'),
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
          await provider.danhDauDaDoc(thongBao.thongBaoID);
        }
        return false; // Không xóa card, chỉ đánh dấu
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
              // Đánh dấu đã đọc
              if (isUnread) {
                await provider.danhDauDaDoc(thongBao.thongBaoID);
              }

              // Mở chi tiết sự kiện nếu có
              if (thongBao.suKienID != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChiTietSuKienScreen(suKienId: thongBao.suKienID!),
                  ),
                );
              } else {
                _showThongBaoDialog(thongBao);
              }
            },
            borderRadius:
            AppDimensions.radiusCircular(AppDimensions.cardRadius),
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
                      color: thongBao.suKienID != null
                          ? AppColors.infoOverlay
                          : AppColors.surfaceVariant,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusMD,
                      ),
                    ),
                    child: Icon(
                      thongBao.suKienID != null
                          ? Icons.event
                          : Icons.notifications,
                      color: thongBao.suKienID != null
                          ? AppColors.info
                          : AppColors.textSecondary,
                      size: AppDimensions.iconMD,
                    ),
                  ),

                  SizedBox(width: AppDimensions.spacingSM),

                  // Nội dung
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên sự kiện (nếu có)
                        if (thongBao.tenSuKien != null) ...[
                          Text(
                            thongBao.tenSuKien!,
                            style: (isUnread
                                ? AppTextStyles.headingSmall
                                : AppTextStyles.bodyMedium)
                                .copyWith(
                              color: AppColors.info,
                              fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppDimensions.spacingXXS),
                        ],

                        // Nội dung
                        Text(
                          thongBao.noiDung,
                          style: (isUnread
                              ? AppTextStyles.bodyMedium
                              : AppTextStyles.bodySmall)
                              .copyWith(
                            color: isUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                            isUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppDimensions.spacingXS),

                        // Thời gian
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppDimensions.iconXS - 2,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: AppDimensions.spacingXXS),
                            Text(
                              thongBao.ngayThongBao,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
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
        ),
      ),
    );
  }

  // ==========================================================================
  // THÔNG BÁO DIALOG
  // ==========================================================================
  void _showThongBaoDialog(ThongBaoInfo thongBao) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusCircular(AppDimensions.dialogRadius),
        ),
        child: Container(
          padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOverlay,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusMD,
                      ),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: AppColors.primary,
                      size: AppDimensions.iconMD,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingSM),
                  Expanded(
                    child: Text(
                      'Thông báo',
                      style: AppTextStyles.headingMedium,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.spacingMD),

              // Nội dung
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppDimensions.radiusCircular(
                    AppDimensions.radiusMD,
                  ),
                ),
                child: Text(
                  thongBao.noiDung,
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              SizedBox(height: AppDimensions.spacingSM),

              // Thời gian
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: AppDimensions.iconXS,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    thongBao.ngayThongBao,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),

              // Warning nếu sự kiện không tồn tại
              if (thongBao.suKienID == null) ...[
                SizedBox(height: AppDimensions.spacingMD),
                Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColors.warningOverlay,
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusSM,
                    ),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                      width: AppDimensions.borderThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: AppDimensions.iconSM,
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                      Expanded(
                        child: Text(
                          'Sự kiện không tồn tại',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppDimensions.spacingMD),

              // Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: AppDimensions.paddingSymmetric(
                      horizontal: AppDimensions.spacingMD,
                      vertical: AppDimensions.spacingXS,
                    ),
                  ),
                  child: Text(
                    'Đóng',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // EMPTY STATE
  // ==========================================================================
  Widget _buildEmptyState() {
    final isUnreadFilter = _selectedFilter == 'unread';
    final icon = isUnreadFilter ? Icons.mark_email_read : Icons.notifications_none;
    final message = isUnreadFilter
        ? 'Không có thông báo chưa đọc'
        : 'Chưa có thông báo nào';

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
              icon,
              size: AppDimensions.iconXXL,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(
            message,
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
            borderRadius:
            AppDimensions.radiusCircular(AppDimensions.cardRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator placeholder
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

              // Icon placeholder
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

              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    SizedBox(height: AppDimensions.spacingXS),
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
                    SizedBox(height: AppDimensions.spacingXS),
                    Container(
                      height: 12,
                      width: 120,
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
}