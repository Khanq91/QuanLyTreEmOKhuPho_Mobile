import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth.dart';
import '../../../providers/phu_huynh.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import '../../other/app_text.dart';
import 'main_screen.dart';

class ParentHomeTab extends StatefulWidget {
  const ParentHomeTab({Key? key}) : super(key: key);

  @override
  State<ParentHomeTab> createState() => _ParentHomeTabState();
}

class _ParentHomeTabState extends State<ParentHomeTab> {

  static final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<PhuHuynhProvider>();
    await Future.wait([
      provider.loadDashboard(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final phuHuynhProvider = context.watch<PhuHuynhProvider>();
    final unreadCount = phuHuynhProvider.dashboard?.soThongBaoChuaDoc ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: AppDimensions.appBarElevation,
        title: Text('Trang chủ', style: AppTextStyles.appBarTitle),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                  size: AppDimensions.iconMD,
                  color: AppColors.appBarText,
                ),
                onPressed: () {
                  final parentState = context.findAncestorStateOfType<ParentMainScreenState>();
                  parentState?.navigateToTab(3);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingXXS),
                    decoration: BoxDecoration(
                      color: AppColors.notificationBadge,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.notificationBadge.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      minWidth: AppDimensions.badgeSize,
                      minHeight: AppDimensions.badgeSize,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: AppTextStyles.badge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: AppDimensions.spacingXS),
        ],
      ),
      body: phuHuynhProvider.isLoading
          ? const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ))
          : phuHuynhProvider.errorMessage != null
          ? _buildErrorWidget(phuHuynhProvider)
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDimensions.paddingAll(AppDimensions.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(authProvider, phuHuynhProvider),
              SizedBox(height: AppDimensions.sectionGap),
              if (phuHuynhProvider.dashboard?.thongTinHocTap != null)
                _buildHocTapCard(phuHuynhProvider),
              SizedBox(height: AppDimensions.cardGap),
              _buildHoTroCard(phuHuynhProvider),
              SizedBox(height: AppDimensions.cardGap),
              if (phuHuynhProvider.dashboard?.suKienSapToi.isNotEmpty ?? false)
                _buildSuKienCard(phuHuynhProvider),
              SizedBox(height: AppDimensions.cardGap),
              if (phuHuynhProvider.dashboard?.thongBaoChuaDoc.isNotEmpty ?? false)
                _buildThongBaoChuaDocCard(phuHuynhProvider),
              SizedBox(height: AppDimensions.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(PhuHuynhProvider provider) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
              size: AppDimensions.iconXXL,
              color: AppColors.errorLight,
            ),
            SizedBox(height: AppDimensions.spacingMD),
            Text('Không thể tải dữ liệu', style: AppTextStyles.headingMedium),
            SizedBox(height: AppDimensions.spacingXS),
            Text(
              provider.errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMediumSecondary,
            ),
            SizedBox(height: AppDimensions.spacingXL),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh, size: AppDimensions.iconSM),
              label: Text('Thử lại', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: AppDimensions.elevationSM,
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.buttonPaddingH,
                  vertical: AppDimensions.buttonPaddingV,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.buttonRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
      AuthProvider authProvider, PhuHuynhProvider phuHuynhProvider) {
    final danhSachCon = phuHuynhProvider.dashboard?.danhSachCon ?? [];
    final firstChild = danhSachCon.isNotEmpty ? danhSachCon.first : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: AppDimensions.paddingAll(AppDimensions.cardPaddingLarge),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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
              backgroundImage: firstChild?.anh != null
                  ? NetworkImage("$baseUrl${firstChild!.anh!}")
                  : null,
              child: firstChild?.anh == null
                  ? Icon(Icons.child_care,
                size: AppDimensions.iconLG,
                color: AppColors.primary,
              )
                  : null,
            ),
          ),
          SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ',
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: AppDimensions.spacingXXS),
                Text(
                  '${authProvider.hoTen}',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (firstChild != null) ...[
                  SizedBox(height: AppDimensions.spacingXS),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                        size: AppDimensions.iconXS,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppDimensions.spacingXXS),
                      Expanded(
                        child: Text(
                          '${firstChild.hoTen} • ${firstChild.tuoi} tuổi',
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (danhSachCon.length > 1) ...[
                  SizedBox(height: AppDimensions.spacingXXS),
                  Row(
                    children: [
                      Icon(Icons.family_restroom,
                        size: AppDimensions.iconXS,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: AppDimensions.spacingXXS),
                      Text(
                        'và ${danhSachCon.length - 1} con khác',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHocTapCard(PhuHuynhProvider provider) {
    final thongTin = provider.dashboard!.thongTinHocTap!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: AppColors.info,
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
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.infoOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                ),
                child: Icon(Icons.school_outlined,
                  color: AppColors.info,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Text('Thông tin học tập', style: AppTextStyles.headingSmall),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Text(thongTin.tenTreEm, style: AppTextStyles.headingMedium),
          SizedBox(height: AppDimensions.spacingXXS),
          Text(
            '${thongTin.tenLop} • ${thongTin.tenTruong}',
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Container(
            padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
            decoration: BoxDecoration(
              color: AppColors.primaryOverlay,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Điểm trung bình', style: AppTextStyles.caption),
                    SizedBox(height: AppDimensions.spacingXXS),
                    Text(
                      thongTin.diemTrungBinh.toStringAsFixed(1),
                      style: AppTextStyles.numberMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: AppDimensions.paddingSymmetric(
                    horizontal: AppDimensions.chipPaddingH,
                    vertical: AppDimensions.chipPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getXepLoaiColor(thongTin.xepLoai),
                    borderRadius: AppDimensions.radiusCircular(AppDimensions.chipRadius),
                  ),
                  child: Text(
                    thongTin.xepLoai,
                    style: AppTextStyles.chip,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spacingSM),
          Row(
            children: [
              Icon(Icons.emoji_events_outlined,
                size: AppDimensions.iconXS,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppDimensions.spacingXXS),
              Text(
                'Hạnh kiểm: ${thongTin.hanhKiem}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          if (thongTin.ghiChu != null && thongTin.ghiChu!.isNotEmpty) ...[
            SizedBox(height: AppDimensions.spacingSM),
            Container(
              padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
              decoration: BoxDecoration(
                color: AppColors.warningOverlay,
                borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                border: Border.all(
                  color: AppColors.withBorder(AppColors.warning),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined,
                    size: AppDimensions.iconXS,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Expanded(
                    child: Text(
                      thongTin.ghiChu!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppDimensions.spacingSM),
          Row(
            children: [
              Icon(Icons.update,
                size: AppDimensions.iconXS,
                color: AppColors.textHint,
              ),
              SizedBox(width: AppDimensions.spacingXXS),
              Text(
                'Năm học: ${DateFormat('dd/MM/yyyy').format(thongTin.ngayCapNhat)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoTroCard(PhuHuynhProvider provider) {
    final hoTroDaNhan = provider.dashboard?.hoTroDaNhan ?? [];
    final now = DateTime.now();
    final hoTroThangNay = hoTroDaNhan.where((ht) {
      return ht.ngayCap.month == now.month && ht.ngayCap.year == now.year;
    }).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
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
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.successOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                ),
                child: Icon(Icons.card_giftcard_outlined,
                  color: AppColors.success,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Text('Hỗ trợ đã nhận', style: AppTextStyles.headingSmall),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColors.successOverlay,
                    borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tháng này', style: AppTextStyles.caption),
                      SizedBox(height: AppDimensions.spacingXXS),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$hoTroThangNay',
                            style: AppTextStyles.numberLarge.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingXXS),
                          Padding(
                            padding: EdgeInsets.only(bottom: AppDimensions.spacingXXS),
                            child: Text('lần', style: AppTextStyles.bodySmall),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: Container(
                  padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                  decoration: BoxDecoration(
                    color: AppColors.infoOverlay,
                    borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng cộng', style: AppTextStyles.caption),
                      SizedBox(height: AppDimensions.spacingXXS),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${hoTroDaNhan.length}',
                            style: AppTextStyles.numberMedium.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingXXS),
                          Padding(
                            padding: EdgeInsets.only(bottom: AppDimensions.spacingXXS),
                            child: Text('lần', style: AppTextStyles.bodySmall),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (hoTroDaNhan.isNotEmpty) ...[
            SizedBox(height: AppDimensions.spacingMD),
            Text('Hỗ trợ gần đây', style: AppTextStyles.labelMedium),
            SizedBox(height: AppDimensions.spacingXS),
            ...hoTroDaNhan.take(2).map((ht) => Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.spacingXS),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                    size: AppDimensions.iconXS,
                    color: AppColors.success,
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ht.loaiHoTro, style: AppTextStyles.bodyMedium),
                        Text(
                          ht.ngayCapFormatted,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSuKienCard(PhuHuynhProvider provider) {
    final suKien = provider.dashboard!.suKienSapToi.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
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
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: AppColors.accentOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                ),
                child: Icon(Icons.event_outlined,
                  color: AppColors.accent,
                  size: AppDimensions.iconMD,
                ),
              ),
              SizedBox(width: AppDimensions.spacingXS),
              Text('Sự kiện sắp tới', style: AppTextStyles.headingSmall),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),
          ...suKien.map((sk) => Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacingSM),
            child: InkWell(
              onTap: () {},
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
              child: Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.accentOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: AppColors.withBorder(AppColors.accent),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sk.tenSuKien,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (sk.isDienRaHomNay)
                          Container(
                            padding: AppDimensions.paddingSymmetric(
                              horizontal: AppDimensions.spacingXS,
                              vertical: AppDimensions.spacingXXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: AppDimensions.radiusCircular(
                                AppDimensions.chipRadius,
                              ),
                            ),
                            child: Text('Hôm nay', style: AppTextStyles.chip),
                          ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                          size: AppDimensions.iconXS,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppDimensions.spacingXXS),
                        Text(
                          sk.ngayBatDauFormatted,
                          style: AppTextStyles.bodySmall,
                        ),
                        if (sk.soNgayConLai >= 0) ...[
                          SizedBox(width: AppDimensions.spacingXS),
                          Text(
                            '• ${sk.soNgayConLai} ngày nữa',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingXXS),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                          size: AppDimensions.iconXS,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppDimensions.spacingXXS),
                        Expanded(
                          child: Text(
                            sk.diaDiem,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (sk.moTa != null && sk.moTa!.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        sk.moTa!,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildThongBaoChuaDocCard(PhuHuynhProvider provider) {
    final thongBao = provider.dashboard!.thongBaoChuaDoc.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.radiusCircular(AppDimensions.cardRadius),
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
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
      padding: AppDimensions.paddingAll(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingXS),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOverlay,
                      borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusSM),
                    ),
                    child: Icon(Icons.notifications_active_outlined,
                      color: AppColors.primary,
                      size: AppDimensions.iconMD,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingXS),
                  Text('Thông báo chưa đọc', style: AppTextStyles.headingSmall),
                ],
              ),
              TextButton(
                onPressed: () {
                  final parentState = context.findAncestorStateOfType<ParentMainScreenState>();
                  parentState?.navigateToTab(3);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: AppDimensions.paddingSymmetric(
                    horizontal: AppDimensions.spacingSM,
                    vertical: AppDimensions.spacingXS,
                  ),
                ),
                child: Text('Xem tất cả', style: AppTextStyles.labelMedium),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMD),
          ...thongBao.map((tb) => Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacingSM),
            child: InkWell(
              onTap: () {},
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
              child: Container(
                padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.primaryOverlay,
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: AppColors.withBorder(AppColors.primary),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tb.tenSuKien != null) ...[
                      Container(
                        padding: AppDimensions.paddingSymmetric(
                          horizontal: AppDimensions.spacingXS,
                          vertical: AppDimensions.spacingXXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusSM,
                          ),
                        ),
                        child: Text(
                          tb.tenSuKien!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacingXS),
                    ],
                    Text(
                      tb.noiDung,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                          size: AppDimensions.iconXS,
                          color: AppColors.textHint,
                        ),
                        SizedBox(width: AppDimensions.spacingXXS),
                        Text(
                          tb.thoiGianTuongDoi,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}