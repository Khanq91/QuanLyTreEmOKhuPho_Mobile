// screens/tinh_nguyen_vien/tnv_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/dashboard_tnv.dart';
import '../../../providers/tinh_nguyen_vien.dart';
import '../../other/xem_anh_screen.dart';
import '../detailsscreen/lich_trong_screen.dart';
import '../../other/app_color.dart';
import '../../other/app_text.dart';
import '../../other/app_dimension.dart';

class VolunteerHomeTab extends StatefulWidget {
  const VolunteerHomeTab({Key? key}) : super(key: key);

  @override
  State<VolunteerHomeTab> createState() => _VolunteerHomeTabState();
}

class _VolunteerHomeTabState extends State<VolunteerHomeTab> {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<VolunteerProvider>(context, listen: false).loadHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trang chủ', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.homeData == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (provider.errorMessage != null && provider.homeData == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingXXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppDimensions.iconXXL,
                      color: AppColors.errorLight,
                    ),
                    SizedBox(height: AppDimensions.spacingMD),
                    Text(
                      'Không thể tải dữ liệu',
                      style: AppTextStyles.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      provider.errorMessage ?? 'Đã có lỗi xảy ra',
                      style: AppTextStyles.bodyMediumSecondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppDimensions.spacingXL),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        elevation: AppDimensions.elevationSM,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.buttonPaddingH,
                          vertical: AppDimensions.buttonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                        ),
                      ),
                      icon: Icon(Icons.refresh, size: AppDimensions.iconSM),
                      label: Text('Thử lại', style: AppTextStyles.button),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppDimensions.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountInfo(provider),
                  SizedBox(height: AppDimensions.sectionGap),
                  _buildSuKienPhanCong(provider),
                  SizedBox(height: AppDimensions.cardGap),
                  _buildThongKe(provider),
                  SizedBox(height: AppDimensions.cardGap),
                  _buildLichTrong(provider),
                  SizedBox(height: AppDimensions.spacingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget 1: Thông tin tài khoản
  Widget _buildAccountInfo(VolunteerProvider provider) {
    final account = provider.thongTinTaiKhoan;
    if (account == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.cardPaddingLarge),
        child: Row(
          children: [
            GestureDetector(
              onTap: account.avatar != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewerScreen(
                      imageUrl: "$baseUrl${account.avatar}",
                      title: account.hoTen,
                    ),
                  ),
                );
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
                  SizedBox(height: AppDimensions.spacingXS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSM,
                      vertical: AppDimensions.spacingXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOverlay,
                      borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      account.chucVu,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXS),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppDimensions.spacingXXS),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryOverlay,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        ),
                        child: Icon(
                          Icons.phone_rounded,
                          size: AppDimensions.iconXS,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                      Text(
                        account.sdt,
                        style: AppTextStyles.bodyMedium.copyWith(
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
      ),
    );
  }

  // Widget 2: Sự kiện được phân công
  Widget _buildSuKienPhanCong(VolunteerProvider provider) {
    final events = provider.suKienPhanCong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    Icons.event_available,
                    size: AppDimensions.iconMD,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),
                Text(
                  'Sự kiện được phân công',
                  style: AppTextStyles.headingSmall,
                ),
              ],
            ),
            if (events.length >= 3)
              TextButton(
                onPressed: () {
                  DefaultTabController.of(context).animateTo(1);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSM,
                    vertical: AppDimensions.spacingXS,
                  ),
                ),
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.labelMedium,
                ),
              ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMD),
        events.isEmpty
            ? Container(
          padding: EdgeInsets.all(AppDimensions.spacingXXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.divider,
              width: AppDimensions.borderThin,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: AppDimensions.iconXXL,
                  color: AppColors.textDisabled,
                ),
                SizedBox(height: AppDimensions.spacingSM),
                Text(
                  'Chưa có sự kiện nào',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                Text(
                  'Bạn sẽ nhận được thông báo khi được phân công',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
            : Column(
          children: events.take(3).map((event) => _buildEventCard(event)).toList(),
        ),
      ],
    );
  }

  Widget _buildEventCard(SuKienPhanCongModel event) {
    Color statusColor;
    Color backgroundColor;
    IconData statusIcon;
    String statusText;

    switch (event.trangThai) {
      case 'Sắp diễn ra':
        statusColor = AppColors.info;
        backgroundColor = AppColors.infoOverlay;
        statusIcon = Icons.schedule;
        statusText = 'Sắp diễn ra';
        break;
      case 'Đang diễn ra':
        statusColor = AppColors.success;
        backgroundColor = AppColors.successOverlay;
        statusIcon = Icons.play_circle_filled;
        statusText = 'Đang diễn ra';
        break;
      default:
        statusColor = AppColors.textDisabled;
        backgroundColor = AppColors.surfaceVariant;
        statusIcon = Icons.check_circle;
        statusText = 'Đã kết thúc';
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: AppDimensions.borderExtraThick,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to event detail
          },
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spacingXS),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Icon(
                        Icons.event,
                        color: statusColor,
                        size: AppDimensions.iconMD,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.tenSuKien,
                            style: AppTextStyles.headingSmall,
                          ),
                          SizedBox(height: AppDimensions.spacingXXS),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 12,
                                  color: statusColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
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
                SizedBox(height: AppDimensions.spacingMD),
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppDimensions.spacingXS),
                          Expanded(
                            child: Text(
                              event.congViec,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppDimensions.spacingXS),
                          Expanded(
                            child: Text(
                              event.diaDiem,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: AppDimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppDimensions.spacingXS),
                          Text(
                            DateFormat('dd/MM/yyyy').format(event.ngayBatDau),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Widget 3: Thống kê hoạt động
  Widget _buildThongKe(VolunteerProvider provider) {
    final thongKe = provider.thongKe;
    if (thongKe == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.accentOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    size: AppDimensions.iconMD,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),
                Text(
                  'Thống kê hoạt động',
                  style: AppTextStyles.headingSmall,
                ),
              ],
            ),
            if (thongKe.suKienGanDay.length >= 3)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full history
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSM,
                    vertical: AppDimensions.spacingXS,
                  ),
                ),
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.labelMedium,
                ),
              ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMD),

        // Tổng sự kiện tham gia
        Container(
          margin: EdgeInsets.only(bottom: AppDimensions.spacingMD),
          padding: EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border(
              left: BorderSide(
                color: AppColors.accent,
                width: AppDimensions.borderExtraThick,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.accentOverlay,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: AppColors.accent,
                  size: AppDimensions.iconLG,
                ),
              ),
              SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng sự kiện tham gia',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingXXS),
                    Row(
                      children: [
                        Text(
                          '${thongKe.tongSuKienThamGia}',
                          style: AppTextStyles.numberLarge.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacingXS),
                        Text(
                          'sự kiện',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Danh sách sự kiện gần đây
        if (thongKe.suKienGanDay.isNotEmpty)
          Column(
            children: thongKe.suKienGanDay
                .take(3)
                .map((event) => _buildThongKeCard(event))
                .toList(),
          )
        else
          Container(
            padding: EdgeInsets.all(AppDimensions.spacingXXL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.divider,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: AppDimensions.iconXXL,
                    color: AppColors.textDisabled,
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  Text(
                    'Chưa có lịch sử tham gia',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThongKeCard(SuKienDaThamGiaModel event) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: AppColors.success,
            width: AppDimensions.borderExtraThick,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to event detail
          },
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spacingXS),
                      decoration: BoxDecoration(
                        color: AppColors.successOverlay,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: AppDimensions.iconMD,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.tenSuKien,
                            style: AppTextStyles.headingSmall,
                          ),
                          SizedBox(height: AppDimensions.spacingXXS),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successOverlay,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.done,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Đã hoàn thành',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
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
                SizedBox(height: AppDimensions.spacingMD),
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: AppDimensions.iconXS,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppDimensions.spacingXS),
                      Text(
                        DateFormat('dd/MM/yyyy').format(event.ngayBatDau),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget 4: Lịch trống
  Widget _buildLichTrong(VolunteerProvider provider) {
    final lichTrong = provider.lichTrong;
    if (lichTrong == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingXS),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    size: AppDimensions.iconMD,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingXS),
                Text(
                  'Lịch trống trong tuần',
                  style: AppTextStyles.headingSmall,
                ),
                if (lichTrong.isEmpty) ...[
                  SizedBox(width: AppDimensions.spacingXS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingXS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Text(
                      'Chưa cập nhật',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LichTrongScreen(),
                  ),
                ).then((_) => provider.refresh());
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSM,
                  vertical: AppDimensions.spacingXS,
                ),
              ),
              child: Text(
                'Chỉnh sửa',
                style: AppTextStyles.labelMedium,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMD),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.divider,
              width: AppDimensions.borderThin,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: _buildLichTrongGrid(lichTrong),
          ),
        ),
      ],
    );
  }

  Widget _buildLichTrongGrid(LichTrongModel lichTrong) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final fullDayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    final sessions = ['Sáng', 'Chiều', 'Tối'];

    return Column(
      children: [
        // Header row
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                'Buổi',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...days.asMap().entries.map((entry) {
              int idx = entry.key;
              String day = entry.value;
              return Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        Divider(
          height: AppDimensions.spacingMD,
          color: AppColors.divider,
          thickness: AppDimensions.borderMedium,
        ),
        // Grid rows
        ...sessions.map((session) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacingXS),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    session,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...fullDayNames.asMap().entries.map((entry) {
                  String dayName = entry.value;
                  final chiTiet = lichTrong.chiTietLichTrong.firstWhere(
                        (ct) => ct.thu == dayName && ct.buoi == session,
                    orElse: () => ChiTietLichTrongModel(
                      thu: dayName,
                      buoi: session,
                      isAvailable: false,
                    ),
                  );

                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: chiTiet.isAvailable
                              ? AppColors.successOverlay
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                          border: Border.all(
                            color: chiTiet.isAvailable
                                ? AppColors.success
                                : AppColors.divider,
                            width: AppDimensions.borderMedium,
                          ),
                        ),
                        child: chiTiet.isAvailable
                            ? Icon(
                          Icons.check,
                          size: AppDimensions.iconSM,
                          color: AppColors.success,
                        )
                            : Icon(
                          Icons.close,
                          size: AppDimensions.iconXS,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        SizedBox(height: AppDimensions.spacingMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(AppColors.success, AppColors.successOverlay, 'Rảnh'),
            SizedBox(width: AppDimensions.spacingMD),
            _buildLegend(AppColors.divider, AppColors.surfaceVariant, 'Bận'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(Color borderColor, Color backgroundColor, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
            border: Border.all(
              color: borderColor,
              width: AppDimensions.borderMedium,
            ),
          ),
        ),
        SizedBox(width: AppDimensions.spacingXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}