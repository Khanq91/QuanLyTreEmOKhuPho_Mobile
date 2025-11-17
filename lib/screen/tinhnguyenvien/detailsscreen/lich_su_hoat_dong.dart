// File: screens/tinh_nguyen_vien/lich_su_hoat_dong_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/tinh_nguyen_vien.dart';
import '../../other/app_color.dart';
import '../../other/app_dimension.dart';
import '../../other/app_text.dart';

class LichSuHoatDongScreen extends StatefulWidget {
  const LichSuHoatDongScreen({Key? key}) : super(key: key);

  @override
  State<LichSuHoatDongScreen> createState() => _LichSuHoatDongScreenState();
}

class _LichSuHoatDongScreenState extends State<LichSuHoatDongScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<VolunteerProvider>();
      if (!provider.isLoading && provider.hasMoreData) {
        provider.loadLichSuHoatDong();
      }
    }
  }

  Future<void> _loadData() async {
    final provider = context.read<VolunteerProvider>();
    try {
      await provider.loadLichSuHoatDong(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusMD),
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Lịch sử hoạt động',
          style: AppTextStyles.appBarTitle,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingSM,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.radiusCircular(
                      AppDimensions.radiusFull,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên khu phố...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: AppDimensions.iconMD,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                          size: AppDimensions.iconSM,
                        ),
                        onPressed: () {
                          setState(() => _searchController.clear());
                          context.read<VolunteerProvider>().setFilterKhuPho(null);
                        },
                      )
                          : null,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: AppDimensions.paddingSymmetric(
                        horizontal: AppDimensions.spacingMD,
                        vertical: AppDimensions.spacingSM,
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<VolunteerProvider>().setFilterKhuPho(
                        value.isEmpty ? null : value,
                      );
                    },
                  ),
                ),
              ),

              // Tab Bar
              Container(
                margin: AppDimensions.paddingSymmetric(
                  horizontal: AppDimensions.spacingMD,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelMedium,
                  tabs: const [
                    Tab(text: 'Sự kiện'),
                    Tab(text: 'Hỗ trợ PL'),
                    Tab(text: 'Vận động'),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacingSM),
            ],
          ),
        ),
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.lichSuHoatDong == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (provider.lichSuHoatDong == null) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSuKienTab(provider),
              _buildHoTroTab(provider),
              _buildVanDongTab(provider),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // SỰ KIỆN TAB
  // ==========================================================================
  Widget _buildSuKienTab(VolunteerProvider provider) {
    final suKienList = provider.lichSuHoatDong!.suKienDaThamGia;

    if (suKienList.isEmpty) {
      return _buildEmptyState(
        message: 'Chưa tham gia sự kiện nào',
        icon: Icons.event_busy_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: suKienList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == suKienList.length) {
            return _buildLoadingIndicator();
          }

          final suKien = suKienList[index];
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Container(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.primaryOverlay,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          Icons.event_rounded,
                          color: AppColors.primary,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suKien.tenSuKien,
                              style: AppTextStyles.headingSmall,
                            ),
                            if (suKien.tenKhuPho != null) ...[
                              SizedBox(height: AppDimensions.spacingXXS),
                              Text(
                                suKien.tenKhuPho!,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.location_on_rounded,
                    suKien.diaDiem ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    '${suKien.ngayBatDau != null ? dateFormat.format(suKien.ngayBatDau!) : 'N/A'} - ${suKien.ngayKetThuc != null ? dateFormat.format(suKien.ngayKetThuc!) : 'N/A'}',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // HỖ TRỢ PHÚC LỢI TAB
  // ==========================================================================
  Widget _buildHoTroTab(VolunteerProvider provider) {
    final hoTroList = provider.lichSuHoatDong!.hoTroPhucLoiDaPhat;

    if (hoTroList.isEmpty) {
      return _buildEmptyState(
        message: 'Chưa phát hỗ trợ phúc lợi nào',
        icon: Icons.card_giftcard_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: hoTroList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == hoTroList.length) {
            return _buildLoadingIndicator();
          }

          final hoTro = hoTroList[index];
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Container(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.successOverlay,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                        decoration: BoxDecoration(
                          color: AppColors.successOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: AppColors.success,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hoTro.loaiHoTro,
                              style: AppTextStyles.headingSmall,
                            ),
                            if (hoTro.tenTreEm != null) ...[
                              SizedBox(height: AppDimensions.spacingXXS),
                              Row(
                                children: [
                                  Icon(
                                    Icons.child_care_rounded,
                                    size: AppDimensions.iconXS,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppDimensions.spacingXXS),
                                  Expanded(
                                    child: Text(
                                      hoTro.tenTreEm!,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: AppDimensions.paddingSymmetric(
                          horizontal: AppDimensions.spacingSM,
                          vertical: AppDimensions.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Text(
                          hoTro.trangThaiPhat ?? 'N/A',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hoTro.moTa != null) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Container(
                      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusSM,
                        ),
                      ),
                      child: Text(
                        hoTro.moTa!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.location_on_rounded,
                    hoTro.tenKhuPho ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    hoTro.ngayCap != null ? dateFormat.format(hoTro.ngayCap!) : 'N/A',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // VẬN ĐỘNG TRẺ EM TAB
  // ==========================================================================
  Widget _buildVanDongTab(VolunteerProvider provider) {
    final vanDongList = provider.lichSuHoatDong!.treEmDaVanDong;

    if (vanDongList.isEmpty) {
      return _buildEmptyState(
        message: 'Chưa vận động trẻ em nào',
        icon: Icons.child_care_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
        itemCount: vanDongList.length + (provider.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vanDongList.length) {
            return _buildLoadingIndicator();
          }

          final vanDong = vanDongList[index];
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Container(
            margin: AppDimensions.paddingSymmetric(
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.radiusCircular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.warningOverlay,
                width: AppDimensions.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                        decoration: BoxDecoration(
                          color: AppColors.warningOverlay,
                          borderRadius: AppDimensions.radiusCircular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          Icons.child_care_rounded,
                          color: AppColors.warning,
                          size: AppDimensions.iconMD,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vanDong.tenTreEm,
                              style: AppTextStyles.headingSmall,
                            ),
                            SizedBox(height: AppDimensions.spacingXXS),
                            Row(
                              children: [
                                Icon(
                                  vanDong.gioiTinh == 'Nam'
                                      ? Icons.male_rounded
                                      : Icons.female_rounded,
                                  size: AppDimensions.iconXS,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: AppDimensions.spacingXXS),
                                Text(
                                  vanDong.gioiTinh ?? 'N/A',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  ' • ',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Expanded(
                                  child: Text(
                                    vanDong.tenKhuPho ?? 'N/A',
                                    style: AppTextStyles.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (vanDong.tinhTrangCapNhat != null)
                        Container(
                          padding: AppDimensions.paddingSymmetric(
                            horizontal: AppDimensions.spacingSM,
                            vertical: AppDimensions.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: _getTinhTrangColor(vanDong.tinhTrangCapNhat!).withOpacity(0.15),
                            borderRadius: AppDimensions.radiusCircular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            vanDong.tinhTrangCapNhat!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getTinhTrangColor(vanDong.tinhTrangCapNhat!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  Container(
                    padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppDimensions.radiusCircular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.report_problem_rounded,
                          'Hoàn cảnh: ${vanDong.loaiHoanCanh ?? 'N/A'}',
                          compact: true,
                        ),
                        _buildInfoRow(
                          Icons.description_rounded,
                          'Lý do: ${vanDong.lyDo ?? 'N/A'}',
                          compact: true,
                        ),
                        _buildInfoRow(
                          Icons.check_circle_rounded,
                          'Kết quả: ${vanDong.ketQua ?? 'N/A'}',
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    vanDong.ngayVanDong != null
                        ? dateFormat.format(vanDong.ngayVanDong!)
                        : 'N/A',
                  ),
                  if (vanDong.ghiChuChiTiet != null) ...[
                    SizedBox(height: AppDimensions.spacingSM),
                    Container(
                      padding: AppDimensions.paddingAll(AppDimensions.spacingSM),
                      decoration: BoxDecoration(
                        color: AppColors.infoOverlay,
                        borderRadius: AppDimensions.radiusCircular(
                          AppDimensions.radiusSM,
                        ),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.2),
                          width: AppDimensions.borderThin,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: AppDimensions.iconXS,
                            color: AppColors.info,
                          ),
                          SizedBox(width: AppDimensions.spacingXS),
                          Expanded(
                            child: Text(
                              vanDong.ghiChuChiTiet!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildInfoRow(IconData icon, String text, {bool compact = false}) {
    return Padding(
      padding: AppDimensions.paddingSymmetric(
        vertical: compact ? 2 : AppDimensions.spacingXS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconXS,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.spacingXS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: AppDimensions.paddingAll(AppDimensions.spacingMD),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message, IconData? icon}) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingAll(AppDimensions.spacingXL),
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
                icon ?? Icons.inbox_rounded,
                size: AppDimensions.iconXXL,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingLG),
            Text(
              message ?? 'Không có dữ liệu',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingXS),
            Text(
              'Dữ liệu sẽ xuất hiện khi có hoạt động mới',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTinhTrangColor(String tinhTrang) {
    switch (tinhTrang) {
      case 'Đi học':
        return AppColors.success;
      case 'Nghỉ học':
        return AppColors.warning;
      case 'Nguy cơ bỏ học':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}